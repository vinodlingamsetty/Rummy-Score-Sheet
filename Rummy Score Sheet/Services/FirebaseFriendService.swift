//
//  FirebaseFriendService.swift
//  Rummy Scorekeeper
//
//  Firebase Firestore implementation of FriendService
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

actor FirebaseFriendService: FriendService {
    
    private let db = Firestore.firestore()
    private let friendsCollection = "friends"
    private let settlementsCollection = "settlements"
    
    // MARK: - FriendService Protocol
    
    func fetchFriends() async throws -> [Friend] {
        // Ensure user is authenticated
        await FirebaseConfig.ensureAuthenticated()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseFriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // Query friendships where current user is either userId1 or userId2
        let snapshot1 = try await db.collection(friendsCollection)
            .whereField("userId1", isEqualTo: currentUserId)
            .getDocuments()
        
        let snapshot2 = try await db.collection(friendsCollection)
            .whereField("userId2", isEqualTo: currentUserId)
            .getDocuments()
        
        var friends: [Friend] = []
        
        // Process friendships where current user is userId1
        for document in snapshot1.documents {
            let friendship = try document.data(as: Friendship.self)
            let friend = friendship.toFriend(for: currentUserId, friendshipId: document.documentID)
            friends.append(friend)
        }
        
        // Process friendships where current user is userId2
        for document in snapshot2.documents {
            let friendship = try document.data(as: Friendship.self)
            let friend = friendship.toFriend(for: currentUserId, friendshipId: document.documentID)
            friends.append(friend)
        }
        
        return friends
    }
    
    func settleFriend(id: UUID) async throws {
        // Ensure user is authenticated
        await FirebaseConfig.ensureAuthenticated()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseFriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // First, fetch all friends to find the one with matching UUID
        let friends = try await fetchFriends()
        guard let friend = friends.first(where: { $0.id == id }),
              let friendshipId = friend.friendshipId else {
            throw NSError(domain: "FirebaseFriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friend not found"])
        }
        
        let friendshipRef = db.collection(friendsCollection).document(friendshipId)
        
        // Get current friendship data
        let document = try await friendshipRef.getDocument()
        let friendship = try document.data(as: Friendship.self)
        
        // Record the settlement transaction before clearing balance
        if friendship.balance != 0 {
            let settlement = Settlement(
                friendshipId: friendshipId,
                amount: abs(friendship.balance),
                settledBy: currentUserId,
                note: "Marked as settled"
            )
            
            try await db.collection(settlementsCollection)
                .document(settlement.id)
                .setData(from: settlement)
        }
        
        // Clear the balance
        try await friendshipRef.updateData([
            "balance": 0.0
        ])
    }
    
    func nudgeFriend(id: UUID) async throws {
        // Ensure user is authenticated
        await FirebaseConfig.ensureAuthenticated()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseFriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // Fetch friend info
        let friends = try await fetchFriends()
        guard let friend = friends.first(where: { $0.id == id }) else {
            throw NSError(domain: "FirebaseFriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friend not found"])
        }
        
        // TODO: Send push notification to friend
        // For now, just log it
        print("📬 Nudge sent to friend: \(friend.name) (userId: \(friend.userId))")
        
        // In production, you would call a Cloud Function here to send a push notification
        // Example:
        // try await Functions.functions().httpsCallable("sendNudge").call(["friendUserId": friend.userId])
    }
    
    func searchFriends(query: String) async throws -> [Friend] {
        let allFriends = try await fetchFriends()
        if query.isEmpty {
            return allFriends
        }
        return allFriends.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func observeFriends() -> AsyncStream<[Friend]> {
        AsyncStream { continuation in
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                continuation.finish()
                return
            }
            
            // Listen to friendships where current user is userId1
            let listener1 = db.collection(friendsCollection)
                .whereField("userId1", isEqualTo: currentUserId)
                .addSnapshotListener { snapshot, error in
                    guard error == nil, let snapshot = snapshot else {
                        return
                    }
                    
                    Task {
                        do {
                            let friends = try await self.fetchFriends()
                            continuation.yield(friends)
                        } catch {
                            print("Error fetching friends: \(error)")
                        }
                    }
                }
            
            // Listen to friendships where current user is userId2
            let listener2 = db.collection(friendsCollection)
                .whereField("userId2", isEqualTo: currentUserId)
                .addSnapshotListener { snapshot, error in
                    guard error == nil, let snapshot = snapshot else {
                        return
                    }
                    
                    Task {
                        do {
                            let friends = try await self.fetchFriends()
                            continuation.yield(friends)
                        } catch {
                            print("Error fetching friends: \(error)")
                        }
                    }
                }
            
            continuation.onTermination = { _ in
                listener1.remove()
                listener2.remove()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Create or update a friendship between two users
    func createOrUpdateFriendship(
        userId1: String,
        userId2: String,
        user1Name: String,
        user2Name: String,
        balanceChange: Double = 0.0
    ) async throws {
        // Ensure friendships are created in a consistent order (smaller userId first)
        let (smallerUserId, largerUserId, smallerName, largerName, adjustedBalance) = userId1 < userId2
            ? (userId1, userId2, user1Name, user2Name, balanceChange)
            : (userId2, userId1, user2Name, user1Name, -balanceChange)
        
        // Generate a consistent friendship ID based on both user IDs
        let friendshipId = "\(smallerUserId)_\(largerUserId)"
        let friendshipRef = db.collection(friendsCollection).document(friendshipId)
        
        let document = try await friendshipRef.getDocument()
        
        if document.exists {
            // Update existing friendship
            try await friendshipRef.updateData([
                "balance": FieldValue.increment(adjustedBalance),
                "gamesPlayedTogether": FieldValue.increment(Int64(1)),
                "lastPlayedDate": FieldValue.serverTimestamp()
            ])
        } else {
            // Create new friendship
            let friendship = Friendship(
                userId1: smallerUserId,
                userId2: largerUserId,
                user1Name: smallerName,
                user2Name: largerName,
                balance: adjustedBalance,
                gamesPlayedTogether: 1,
                lastPlayedDate: Date()
            )
            try friendshipRef.setData(from: friendship)
        }
    }
}
