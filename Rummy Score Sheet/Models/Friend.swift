//
//  Friend.swift
//  Rummy Scorekeeper
//
//  Friend model for tracking balances and settlements
//

import Foundation

struct Friend: Identifiable, Codable {
    let id: UUID
    let name: String
    let avatarEmoji: String // For future avatar support
    var balance: Double // Positive = they owe you, Negative = you owe them
    var gamesPlayedTogether: Int
    var lastPlayedDate: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        avatarEmoji: String = "👤",
        balance: Double = 0.0,
        gamesPlayedTogether: Int = 0,
        lastPlayedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.balance = balance
        self.gamesPlayedTogether = gamesPlayedTogether
        self.lastPlayedDate = lastPlayedDate
    }
    
    // MARK: - Computed Properties
    
    /// Formatted balance as currency string
    var balanceFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let absValue = abs(balance)
        let formattedAmount = formatter.string(from: NSNumber(value: absValue)) ?? "$0.00"
        
        if balance > 0 {
            return "+\(formattedAmount)"
        } else if balance < 0 {
            return "-\(formattedAmount)"
        } else {
            return formattedAmount
        }
    }
    
    /// Whether this friend owes you money
    var isToCollect: Bool {
        balance > 0
    }
    
    /// Whether you owe this friend money
    var isToSettle: Bool {
        balance < 0
    }
    
    /// Whether the balance is settled (zero)
    var isSettled: Bool {
        balance == 0
    }
    
    /// First letter of name for avatar
    var initial: String {
        String(name.prefix(1)).uppercased()
    }
}

// MARK: - Mock Data

extension Friend {
    static let mockFriends: [Friend] = [
        Friend(
            name: "Alice Johnson",
            avatarEmoji: "🎮",
            balance: 45.50,
            gamesPlayedTogether: 3,
            lastPlayedDate: Date().addingTimeInterval(-86400 * 2)
        ),
        Friend(
            name: "Bob Smith",
            avatarEmoji: "🎯",
            balance: -23.00,
            gamesPlayedTogether: 5,
            lastPlayedDate: Date().addingTimeInterval(-86400)
        ),
        Friend(
            name: "Charlie Davis",
            avatarEmoji: "🏆",
            balance: 12.75,
            gamesPlayedTogether: 2,
            lastPlayedDate: Date().addingTimeInterval(-86400 * 7)
        ),
        Friend(
            name: "Diana Prince",
            avatarEmoji: "👑",
            balance: -67.25,
            gamesPlayedTogether: 8,
            lastPlayedDate: Date().addingTimeInterval(-86400 * 3)
        ),
        Friend(
            name: "Ethan Hunt",
            avatarEmoji: "🎲",
            balance: 89.00,
            gamesPlayedTogether: 12,
            lastPlayedDate: Date().addingTimeInterval(-3600)
        ),
        Friend(
            name: "Fiona Carter",
            avatarEmoji: "🌟",
            balance: 0.0,
            gamesPlayedTogether: 1,
            lastPlayedDate: Date().addingTimeInterval(-86400 * 14)
        )
    ]
}
