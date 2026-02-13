//
//  Settlement.swift
//  Rummy Scorekeeper
//
//  Model for tracking settlement transactions
//

import Foundation

struct Settlement: Identifiable, Codable {
    let id: String
    let friendshipId: String // Reference to the friendship
    let amount: Double // Amount that was settled
    let settledAt: Date
    let settledBy: String // User ID who marked it as settled
    let note: String? // Optional note
    
    init(
        id: String = UUID().uuidString,
        friendshipId: String,
        amount: Double,
        settledAt: Date = Date(),
        settledBy: String,
        note: String? = nil
    ) {
        self.id = id
        self.friendshipId = friendshipId
        self.amount = amount
        self.settledAt = settledAt
        self.settledBy = settledBy
        self.note = note
    }
    
    // MARK: - Computed Properties
    
    /// Formatted amount as currency
    var amountFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    /// Relative time display
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: settledAt, relativeTo: Date())
    }
}
