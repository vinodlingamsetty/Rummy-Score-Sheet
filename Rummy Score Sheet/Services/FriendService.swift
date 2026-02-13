//
//  FriendService.swift
//  Rummy Scorekeeper
//
//  Service for managing friend relationships and settlements
//

import Foundation

// MARK: - Protocol

protocol FriendService {
    func fetchFriends() async throws -> [Friend]
    func settleFriend(id: String) async throws
    func recordSettlement(id: String, amount: Double, note: String) async throws
    func fetchSettlements(friendshipId: String) async throws -> [Settlement]
    func nudgeFriend(id: String) async throws
    func searchFriends(query: String) async throws -> [Friend]
    func observeFriends() -> AsyncStream<[Friend]>
}

// MARK: - Mock Implementation

actor MockFriendService: FriendService {
    
    // In-memory storage
    private var friends: [Friend] = Friend.mockFriends
    private var settlements: [String: [Settlement]] = [:]
    
    func fetchFriends() async throws -> [Friend] {
        // Simulate very brief network delay (for testing loading state)
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        return friends
    }
    
    func settleFriend(id: String) async throws {
        if let index = friends.firstIndex(where: { $0.id == id }) {
            friends[index].balance = 0.0
        }
    }
    
    func recordSettlement(id: String, amount: Double, note: String) async throws {
        if let index = friends.firstIndex(where: { $0.id == id }) {
            let currentBalance = friends[index].balance
            if currentBalance > 0 {
                friends[index].balance = max(0, currentBalance - amount)
            } else {
                friends[index].balance = min(0, currentBalance + amount)
            }
            
            let settlement = Settlement(
                friendshipId: id,
                amount: amount,
                settledBy: "mock-user",
                note: note
            )
            var currentSettlements = settlements[id] ?? []
            currentSettlements.append(settlement)
            settlements[id] = currentSettlements
            
            print("📝 Settlement recorded for friend: \(id), amount: $\(amount), note: \(note)")
        }
    }
    
    func fetchSettlements(friendshipId: String) async throws -> [Settlement] {
        return (settlements[friendshipId] ?? []).sorted { $0.settledAt > $1.settledAt }
    }
    
    func nudgeFriend(id: String) async throws {
        // Simulate sending notification
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        print("📬 Nudge sent to friend: \(id)")
    }
    
    func searchFriends(query: String) async throws -> [Friend] {
        if query.isEmpty {
            return friends
        }
        return friends.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func observeFriends() -> AsyncStream<[Friend]> {
        AsyncStream { continuation in
            continuation.yield(friends)
            continuation.finish()
        }
    }
}
