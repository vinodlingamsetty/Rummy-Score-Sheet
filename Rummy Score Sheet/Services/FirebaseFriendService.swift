//
//  FirebaseFriendService.swift
//  Rummy Scorekeeper
//
//  Firebase Firestore implementation of FriendService.
//  Friendship IDs use format {userId1}_{userId2} (smaller ID first) for consistency.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

actor FirebaseFriendService: FriendService {
    
    private let db = Firestore.firestore()
    private let friendsCollection = AppConstants.Firestore.friends
    private let settlementsCollection = AppConstants.Firestore.settlements
    
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
    
    func settleFriend(id: String) async throws {
        // Ensure user is authenticated
        await FirebaseConfig.ensureAuthenticated()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseFriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // The 'id' is the friendshipId
        let friendshipId = id
        let friendshipRef = db.collection(friendsCollection).document(friendshipId)
        
        // Get current friendship data to record settlement transaction
        let document = try await friendshipRef.getDocument()
        guard document.exists else {
            throw NSError(domain: "FirebaseFriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friend not found"])
        }
        
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
    
    func recordSettlement(id: String, amount: Double, note: String) async throws {
        // Ensure user is authenticated
        await FirebaseConfig.ensureAuthenticated()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseFriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // The 'id' is the friendshipId
        let friendshipId = id
        let friendshipRef = db.collection(friendsCollection).document(friendshipId)
        
        let document = try await friendshipRef.getDocument()
        guard document.exists else {
            throw NSError(domain: "FirebaseFriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friend not found"])
        }
        
        let friendship = try document.data(as: Friendship.self)
        
        // The balance in the document is: (userId2 owes userId1)
        // We need to move this balance TOWARDS ZERO by the settlement 'amount'.
        
        var adjustment = 0.0
        if currentUserId == friendship.userId1 {
            // I am userId1. 
            // If balance > 0, userId2 owes me. To reduce their debt, we DECREMENT balance.
            // If balance < 0, I owe userId2. To reduce my debt, we INCREMENT balance.
            adjustment = (friendship.balance > 0) ? -amount : amount
        } else {
            // I am userId2.
            // If balance > 0, I owe userId1. To reduce my debt, we DECREMENT balance.
            // If balance < 0, userId1 owes me. To reduce their debt, we INCREMENT balance.
            adjustment = (friendship.balance > 0) ? -amount : amount
        }
        
        // Safety: ensure we don't over-settle (flip the debt)
        if amount > abs(friendship.balance) {
            adjustment = -friendship.balance
        }
        
        // Record the transaction
        let settlement = Settlement(
            friendshipId: friendshipId,
            amount: amount,
            settledBy: currentUserId,
            note: note
        )
        
        try await db.collection(settlementsCollection)
            .document(settlement.id)
            .setData(from: settlement)
        
        // Atomically update balance
        try await friendshipRef.updateData([
            "balance": FieldValue.increment(adjustment)
        ])
    }
    
    func fetchSettlements(friendshipId: String) async throws -> [Settlement] {
        let snapshot = try await db.collection(settlementsCollection)
            .whereField("friendshipId", isEqualTo: friendshipId)
            .order(by: "settledAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Settlement.self) }
    }
    
    func nudgeFriend(id: String) async throws {
        // Ensure user is authenticated
        await FirebaseConfig.ensureAuthenticated()
        
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseFriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // The 'id' is the friendshipId
        let friendshipId = id
        // We need the other user's ID for the nudge
        let doc = try await db.collection(friendsCollection).document(friendshipId).getDocument()
        
        guard doc.exists, let friendship = try? doc.data(as: Friendship.self) else {
             throw NSError(domain: "FirebaseFriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friendship not found"])
        }
        
        let friendUserId = (currentUser.uid == friendship.userId1) ? friendship.userId2 : friendship.userId1
        
        // Get sender's display name (synchronous call)
        let senderName = FirebaseConfig.getUserDisplayName()
        
        let data: [String: Any] = [
            "friendUserId": friendUserId,
            "senderName": senderName
        ]
        
        // Call Cloud Function
        let result = try await Functions.functions().httpsCallable("sendNudge").call(data)
        
        // Check result
        if let response = result.data as? [String: Any],
           let sent = response["sent"] as? Bool,
           sent == false {
            let reason = response["reason"] as? String ?? "Unknown error"
            throw NSError(domain: "FirebaseFriendService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to send nudge: \(reason)"])
        }
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
                            #if DEBUG
                            print("Error fetching friends: \(error)")
                            #endif
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
                            #if DEBUG
                            print("Error fetching friends: \(error)")
                            #endif
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
        user1Email: String? = nil,
        user2Email: String? = nil,
        balanceChange: Double = 0.0
    ) async throws {
        // Ensure friendships are created in a consistent order (smaller userId first)
        let (smallerUserId, largerUserId, smallerName, largerName, smallerEmail, largerEmail, adjustedBalance) = userId1 < userId2
            ? (userId1, userId2, user1Name, user2Name, user1Email, user2Email, balanceChange)
            : (userId2, userId1, user2Name, user1Name, user2Email, user1Email, -balanceChange)
        
        // Consistent ID format ensures one doc per pair regardless of caller order
        let friendshipId = "\(smallerUserId)_\(largerUserId)"
        let friendshipRef = db.collection(friendsCollection).document(friendshipId)
        
        let document = try await friendshipRef.getDocument()
        
        if document.exists {
            // Update existing friendship
            var updateData: [String: Any] = [
                "balance": FieldValue.increment(adjustedBalance),
                "gamesPlayedTogether": FieldValue.increment(Int64(1)),
                "lastPlayedDate": FieldValue.serverTimestamp()
            ]
            
            // Sync names/emails if they were missing or changed
            updateData["user1Name"] = smallerName
            updateData["user2Name"] = largerName
            if let e1 = smallerEmail { updateData["user1Email"] = e1 }
            if let e2 = largerEmail { updateData["user2Email"] = e2 }
            
            try await friendshipRef.updateData(updateData)
        } else {
            // Create new friendship
            let friendship = Friendship(
                userId1: smallerUserId,
                userId2: largerUserId,
                user1Name: smallerName,
                user2Name: largerName,
                user1Email: smallerEmail,
                user2Email: largerEmail,
                balance: adjustedBalance,
                gamesPlayedTogether: 1,
                lastPlayedDate: Date()
            )
            try friendshipRef.setData(from: friendship)
        }
    }
}
