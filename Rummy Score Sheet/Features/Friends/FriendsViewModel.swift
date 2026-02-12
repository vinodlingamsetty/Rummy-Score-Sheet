//
//  FriendsViewModel.swift
//  Rummy Scorekeeper
//
//  ViewModel for Friends list
//

import SwiftUI

@Observable
class FriendsViewModel {
    
    // MARK: - State
    
    var friends: [Friend] = []
    var searchQuery: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let friendService: FriendService
    
    // MARK: - Initialization
    
    init(friendService: FriendService = MockFriendService()) {
        self.friendService = friendService
    }
    
    // MARK: - Computed Properties
    
    var filteredFriends: [Friend] {
        if searchQuery.isEmpty {
            return friends
        }
        return friends.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }
    
    var friendsToCollect: [Friend] {
        filteredFriends
            .filter { $0.isToCollect }
            .sorted { $0.balance > $1.balance }
    }
    
    var friendsToSettle: [Friend] {
        filteredFriends
            .filter { $0.isToSettle }
            .sorted { $0.balance < $1.balance }
    }
    
    var settledFriends: [Friend] {
        filteredFriends
            .filter { $0.isSettled }
            .sorted { $0.name < $1.name }
    }
    
    var totalToCollect: Double {
        friends.filter { $0.isToCollect }.reduce(0) { $0 + $1.balance }
    }
    
    var totalToSettle: Double {
        abs(friends.filter { $0.isToSettle }.reduce(0) { $0 + $1.balance })
    }
    
    // MARK: - Actions
    
    @MainActor
    func loadFriends() async {
        isLoading = true
        errorMessage = nil
        
        do {
            friends = try await friendService.fetchFriends()
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func settleFriend(_ friend: Friend) async {
        do {
            try await friendService.settleFriend(id: friend.id)
            
            // Update local state
            if let index = friends.firstIndex(where: { $0.id == friend.id }) {
                friends[index].balance = 0.0
            }
            
            // Haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
        } catch {
            errorMessage = "Failed to settle: \(error.localizedDescription)"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    @MainActor
    func recordSettlement(friend: Friend, amount: Double, note: String) async {
        isLoading = true
        do {
            try await friendService.recordSettlement(id: friend.id, amount: amount, note: note)
            
            // Reload friends to get updated balance
            await loadFriends()
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            errorMessage = "Failed to record settlement: \(error.localizedDescription)"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        isLoading = false
    }
    
    @MainActor
    func nudgeFriend(_ friend: Friend) async {
        do {
            try await friendService.nudgeFriend(id: friend.id)
            
            // Show success feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
        } catch {
            errorMessage = "Failed to send nudge: \(error.localizedDescription)"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
