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
    var isSettlementsLoading: Bool = false
    var isSharedGamesLoading: Bool = false
    var errorMessage: String?
    var settlements: [Settlement] = []
    var sharedGames: [GameRoom] = []
    
    private let friendService: FriendService
    private let historyService: GameHistoryService
    private var friendsObserverTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(friendService: FriendService = MockFriendService(), historyService: GameHistoryService = GameHistoryService()) {
        self.friendService = friendService
        self.historyService = historyService
    }
    
    deinit {
        friendsObserverTask?.cancel()
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
    func startObservingFriends() {
        friendsObserverTask?.cancel()
        friendsObserverTask = Task { @MainActor in
            for await updatedFriends in friendService.observeFriends() {
                self.friends = updatedFriends
            }
        }
    }
    
    func stopObservingFriends() {
        friendsObserverTask?.cancel()
        friendsObserverTask = nil
    }
    
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
            
            // Reload friends and settlements to get updated state
            await loadFriends()
            await loadSettlements(for: friend)
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            errorMessage = "Failed to record settlement: \(error.localizedDescription)"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        isLoading = false
    }
    
    @MainActor
    func loadSettlements(for friend: Friend) async {
        isSettlementsLoading = true
        do {
            settlements = try await friendService.fetchSettlements(friendshipId: friend.id)
        } catch {
            #if DEBUG
            print("❌ Failed to load settlements: \(error.localizedDescription)")
            #endif
        }
        isSettlementsLoading = false
    }
    
    @MainActor
    func loadSharedGames(friendUserId: String) async {
        isSharedGamesLoading = true
        do {
            sharedGames = try await historyService.fetchGamesWithFriend(friendUserId: friendUserId)
        } catch {
            #if DEBUG
            print("❌ Failed to load shared games: \(error.localizedDescription)")
            #endif
        }
        isSharedGamesLoading = false
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
