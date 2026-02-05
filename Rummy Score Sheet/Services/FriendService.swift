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
    func settleFriend(id: UUID) async throws
    func nudgeFriend(id: UUID) async throws
    func searchFriends(query: String) async throws -> [Friend]
    func observeFriends() -> AsyncStream<[Friend]>
}

// MARK: - Mock Implementation

actor MockFriendService: FriendService {
    
    // In-memory storage
    private var friends: [Friend] = Friend.mockFriends
    
    func fetchFriends() async throws -> [Friend] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return friends
    }
    
    func settleFriend(id: UUID) async throws {
        if let index = friends.firstIndex(where: { $0.id == id }) {
            friends[index].balance = 0.0
        }
    }
    
    func nudgeFriend(id: UUID) async throws {
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
