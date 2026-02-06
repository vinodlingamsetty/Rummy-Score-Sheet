//
//  UserProfile.swift
//  Rummy Scorekeeper
//
//  User profile model
//

import Foundation

struct UserProfile: Codable {
    let userId: String
    var displayName: String
    var avatarEmoji: String
    var email: String?
    var phoneNumber: String?
    var createdAt: Date
    
    // Statistics
    var totalGamesPlayed: Int
    var totalGamesWon: Int
    var totalPointsEarned: Double
    var totalPointsLost: Double
    
    init(
        userId: String,
        displayName: String,
        avatarEmoji: String = "👤",
        email: String? = nil,
        phoneNumber: String? = nil,
        createdAt: Date = Date(),
        totalGamesPlayed: Int = 0,
        totalGamesWon: Int = 0,
        totalPointsEarned: Double = 0.0,
        totalPointsLost: Double = 0.0
    ) {
        self.userId = userId
        self.displayName = displayName
        self.avatarEmoji = avatarEmoji
        self.email = email
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.totalGamesPlayed = totalGamesPlayed
        self.totalGamesWon = totalGamesWon
        self.totalPointsEarned = totalPointsEarned
        self.totalPointsLost = totalPointsLost
    }
    
    // MARK: - Computed Properties
    
    var winRate: Double {
        guard totalGamesPlayed > 0 else { return 0.0 }
        return (Double(totalGamesWon) / Double(totalGamesPlayed)) * 100.0
    }
    
    var winRateFormatted: String {
        return String(format: "%.1f%%", winRate)
    }
    
    var netBalance: Double {
        return totalPointsEarned - totalPointsLost
    }
    
    var netBalanceFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        let value = abs(netBalance)
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        return netBalance >= 0 ? "+\(formatted)" : "-\(formatted)"
    }
    
    var initial: String {
        String(displayName.prefix(1)).uppercased()
    }
}

// MARK: - Mock Data

extension UserProfile {
    static let mock = UserProfile(
        userId: "mock-user-123",
        displayName: "John Doe",
        avatarEmoji: "🎮",
        email: "john@example.com",
        totalGamesPlayed: 42,
        totalGamesWon: 18,
        totalPointsEarned: 5420.50,
        totalPointsLost: 3210.25
    )
}
