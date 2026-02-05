//
//  Friendship.swift
//  Rummy Scorekeeper
//
//  Firestore document model for friend relationships
//

import Foundation

/// Firestore document structure for friendships
struct Friendship: Codable {
    let userId1: String // Current user ID
    let userId2: String // Friend's user ID
    let user1Name: String // Current user's name
    let user2Name: String // Friend's name
    var balance: Double // Positive = user2 owes user1, Negative = user1 owes user2
    var gamesPlayedTogether: Int
    var lastPlayedDate: Date?
    let createdAt: Date
    
    init(
        userId1: String,
        userId2: String,
        user1Name: String,
        user2Name: String,
        balance: Double = 0.0,
        gamesPlayedTogether: Int = 0,
        lastPlayedDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.userId1 = userId1
        self.userId2 = userId2
        self.user1Name = user1Name
        self.user2Name = user2Name
        self.balance = balance
        self.gamesPlayedTogether = gamesPlayedTogether
        self.lastPlayedDate = lastPlayedDate
        self.createdAt = createdAt
    }
    
    // MARK: - Helper Methods
    
    /// Get the friend's info from the perspective of the given user
    func friendInfo(for currentUserId: String) -> (userId: String, name: String) {
        if currentUserId == userId1 {
            return (userId2, user2Name)
        } else {
            return (userId1, user1Name)
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
            balance: userBalance,
            gamesPlayedTogether: gamesPlayedTogether,
            lastPlayedDate: lastPlayedDate
        )
    }
}
