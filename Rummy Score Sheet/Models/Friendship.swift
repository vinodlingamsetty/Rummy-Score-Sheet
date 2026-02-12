//
//  Friendship.swift
//  Rummy Scorekeeper
//
//  Firestore document model for friend relationships
//

import Foundation

/// Firestore document structure for friendships.
/// userId1 is ALWAYS the smaller ID alphabetically, userId2 is the larger.
struct Friendship: Codable {
    let userId1: String // Smaller user ID alphabetically
    let userId2: String // Larger user ID alphabetically
    let user1Name: String // Name of user with smaller ID
    let user2Name: String // Name of user with larger ID
    var user1Email: String? // Email of user with smaller ID
    var user2Email: String? // Email of user with larger ID
    var balance: Double // Positive = user2 owes user1, Negative = user1 owes user2
    var gamesPlayedTogether: Int
    var lastPlayedDate: Date?
    let createdAt: Date
    
    init(
        userId1: String,
        userId2: String,
        user1Name: String,
        user2Name: String,
        user1Email: String? = nil,
        user2Email: String? = nil,
        balance: Double = 0.0,
        gamesPlayedTogether: Int = 0,
        lastPlayedDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.userId1 = userId1
        self.userId2 = userId2
        self.user1Name = user1Name
        self.user2Name = user2Name
        self.user1Email = user1Email
        self.user2Email = user2Email
        self.balance = balance
        self.gamesPlayedTogether = gamesPlayedTogether
        self.lastPlayedDate = lastPlayedDate
        self.createdAt = createdAt
    }
    
    // MARK: - Helper Methods
    
    /// Get the friend's info from the perspective of the given user
    func friendInfo(for currentUserId: String) -> (userId: String, name: String, email: String?) {
        if currentUserId == userId1 {
            return (userId2, user2Name, user2Email)
        } else {
            return (userId1, user1Name, user1Email)
        }
    }
    
    /// Get the balance from the perspective of the given user
    func balanceFor(userId: String) -> Double {
        if userId == userId1 {
            return balance // Positive = user2 owes user1
        } else {
            return -balance // Negative = user1 owes user2
        }
    }
    
    /// Convert to Friend model from the perspective of the given user
    func toFriend(for currentUserId: String, friendshipId: String) -> Friend {
        let friendInfo = friendInfo(for: currentUserId)
        let userBalance = balanceFor(userId: currentUserId)
        
        return Friend(
            friendshipId: friendshipId,
            userId: friendInfo.userId,
            name: friendInfo.name,
            email: friendInfo.email,
            balance: userBalance,
            gamesPlayedTogether: gamesPlayedTogether,
            lastPlayedDate: lastPlayedDate
        )
    }
}
