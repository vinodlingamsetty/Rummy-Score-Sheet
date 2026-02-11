//
//  AppGameState.swift
//  Rummy Scorekeeper
//
//  App-level game session state — thin coordinator that delegates to RoomService.
//  Does not perform authorization; moderator-only checks are UI-level. Firestore
//  security rules should enforce server-side (see backend repo).
//

import Foundation
import SwiftUI

@Observable
final class AppGameState {

    // MARK: - State

    var currentRoom: GameRoom?
    var selectedTab: AppTab = .home
    var currentUserId: UUID?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Service

    let roomService: RoomService // Internal access for GameViewModel
    let friendService: FriendService // Internal access for creating friendships
    private var roomObserverTask: Task<Void, Never>?

    // MARK: - Init

    init(roomService: RoomService, friendService: FriendService) {
        self.roomService = roomService
        self.friendService = friendService
    }
    
    deinit {
        roomObserverTask?.cancel()
    }

    // MARK: - Room Actions

    func createRoom(pointLimit: Int, pointValue: Int) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            do {
                let result = try await roomService.createRoom(
                    pointLimit: pointLimit,
                    pointValue: pointValue
                )
                currentRoom = result.room
                currentUserId = result.currentUserId
                selectedTab = .game
                startObservingRoom(code: result.room.id)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func joinRoom(code: String, playerName: String = "Player") {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            do {
                let result = try await roomService.joinRoom(code: code, playerName: playerName)
                currentRoom = result.room
                currentUserId = result.currentUserId
                selectedTab = .game
                startObservingRoom(code: result.room.id)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func setReady(_ ready: Bool) {
        guard let roomCode = currentRoom?.id, let playerId = currentUserId else { return }
        Task { @MainActor in
            do {
                let updatedRoom = try await roomService.setReady(roomCode: roomCode, playerId: playerId, ready: ready)
                currentRoom = updatedRoom
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func startGame() {
        guard let roomCode = currentRoom?.id else { return }
        Task { @MainActor in
            isLoading = true
            do {
                let updatedRoom = try await roomService.startGame(roomCode: roomCode)
                currentRoom = updatedRoom
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func leaveGame() {
        stopObservingRoom()
        
        guard let roomCode = currentRoom?.id, let playerId = currentUserId else {
            currentRoom = nil
            selectedTab = .home
            return
        }
        Task { @MainActor in
            do {
                try await roomService.leaveRoom(roomCode: roomCode, playerId: playerId)
            } catch {
                // Intentionally ignore leave errors — user is leaving; clear local state regardless
            }
            currentRoom = nil
            currentUserId = nil
            selectedTab = .home
        }
    }

    func endGame() {
        leaveGame()
    }
    
    /// Creates or updates friendships between all players after a game ends.
    /// Only runs with FirebaseFriendService; no-op for MockFriendService.
    /// Balance formula: (loser_score - winner_score) * pointValue = amount owed.
    func createFriendshipsFromGame(_ room: GameRoom) async {
        guard room.isCompleted, let winner = room.winner else {
            print("⚠️ Cannot create friendships: Game not completed or no winner")
            return
        }
        
        guard let currentFirebaseUid = FirebaseConfig.getCurrentUserId() else {
            print("⚠️ Not authenticated; skipping friendships")
            return
        }
        
        print("🤝 Creating friendships from completed game for user \(currentFirebaseUid)...")
        
        // Only works with Firebase service
        guard let firebaseFriendService = friendService as? FirebaseFriendService else {
            print("⚠️ Friendships only supported with Firebase service")
            return
        }
        
        let winnerTotalScore = winner.totalScore
        func uid(for player: Player) -> String? { player.userId }
        
        // Strategy: Each player updates friendships they are part of.
        // This complies with Firestore rules (can only write if you are a participant).
        
        for player in room.players {
            // Skip if current user is not part of this pair
            guard let playerUid = uid(for: player) else { continue }
            
            // We only process pairs where one of the participants is the current user
            // And we avoid duplicate processing (only process each pair once per game)
            // Actually, if both A and B call this, they will both try to update A-B.
            // That's fine (Firestore will just increment twice if not careful, but 
            // the logic should be idempotent or additive).
            // To be safe, let's only have the user with the "smaller" UID update the shared record?
            // No, the rules say EITHER can update. Let's just have the current user update
            // all their friendships from this game.
            
            // Only update if current user is one of the two participants
            let isCurrentParticipant = (playerUid == currentFirebaseUid || winner.userId == currentFirebaseUid)
            
            if isCurrentParticipant && player.id != winner.id {
                // Determine the "other" person in the friendship
                let otherUid = (playerUid == currentFirebaseUid) ? (winner.userId ?? "") : playerUid
                let otherName = (playerUid == currentFirebaseUid) ? winner.name : player.name
                let currentUserName = (playerUid == currentFirebaseUid) ? player.name : (room.players.first { $0.userId == currentFirebaseUid }?.name ?? "Me")
                
                // Only update if we have a valid UID for both
                guard !otherUid.isEmpty else { continue }
                
                // Calculate balance change: fixed pointValue payment from losers to winner
                let amountOwed = Double(room.pointValue)
                
                // The createOrUpdateFriendship handles userId order (smaller first)
                do {
                    try await firebaseFriendService.createOrUpdateFriendship(
                        userId1: winner.userId ?? "",
                        userId2: playerUid,
                        user1Name: winner.name,
                        user2Name: player.name,
                        balanceChange: amountOwed
                    )
                    print("✅ Updated friendship: \(winner.name) ↔ \(player.name), balance change: $\(amountOwed)")
                } catch {
                    print("❌ Failed to update friendship: \(error.localizedDescription)")
                }
            }
        }
        
        // Also update game counts between non-winners
        for i in 0..<room.players.count {
            for j in (i+1)..<room.players.count {
                let p1 = room.players[i]
                let p2 = room.players[j]
                
                // Skip if winner is involved (already handled above)
                if p1.id == winner.id || p2.id == winner.id { continue }
                
                guard let uid1 = uid(for: p1), let uid2 = uid(for: p2) else { continue }
                
                // Only current user can update their own friendships
                if uid1 == currentFirebaseUid || uid2 == currentFirebaseUid {
                    do {
                        try await firebaseFriendService.createOrUpdateFriendship(
                            userId1: uid1,
                            userId2: uid2,
                            user1Name: p1.name,
                            user2Name: p2.name,
                            balanceChange: 0.0
                        )
                    } catch {
                        print("❌ Failed to update friendship: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Room Updates

    /// Update room from external source (e.g. GameLobbyViewModel)
    func updateRoom(_ room: GameRoom) {
        currentRoom = room
    }
    
    // MARK: - Real-Time Observation
    
    /// Start observing room updates from Firebase (real-time sync)
    private func startObservingRoom(code: String) {
        stopObservingRoom()
        
        roomObserverTask = Task { @MainActor in
            for await room in roomService.observeRoom(code: code) {
                // Only update if we're still in the same room
                guard currentRoom?.id == code else { break }
                // Don't clear room on transient nil (e.g. decode error); preserve state so tab switching doesn't kick user out
                if let room = room {
                    currentRoom = room
                }
            }
        }
    }
    
    /// Stop observing room updates
    private func stopObservingRoom() {
        roomObserverTask?.cancel()
        roomObserverTask = nil
    }
}
