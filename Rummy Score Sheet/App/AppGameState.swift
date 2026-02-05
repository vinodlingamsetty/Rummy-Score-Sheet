//
//  AppGameState.swift
//  Rummy Scorekeeper
//
//  App-level game session state — thin coordinator that delegates to RoomService
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

    func createRoom(pointLimit: Int, pointValue: Int, playerCount: Int) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            do {
                let result = try await roomService.createRoom(
                    pointLimit: pointLimit,
                    pointValue: pointValue,
                    playerCount: playerCount
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
                // Ignore error on leave — clear local state anyway
            }
            currentRoom = nil
            currentUserId = nil
            selectedTab = .home
        }
    }

    func endGame() {
        leaveGame()
    }
    
    /// Create or update friendships between all players after a game ends
    func createFriendshipsFromGame(_ room: GameRoom) async {
        guard room.isCompleted, let winner = room.winner else {
            print("⚠️ Cannot create friendships: Game not completed or no winner")
            return
        }
        
        print("🤝 Creating friendships from completed game...")
        
        // Only works with Firebase service
        guard let firebaseFriendService = friendService as? FirebaseFriendService else {
            print("⚠️ Friendships only supported with Firebase service")
            return
        }
        
        // Calculate balances: winner receives, losers pay based on their scores
        let winnerTotalScore = winner.totalScore
        
        for player in room.players {
            // Skip winner vs winner
            if player.id == winner.id { continue }
            
            // Calculate how much this player owes the winner
            // Formula: (loser's total score - winner's total score) * pointValue
            let scoreDifference = player.totalScore - winnerTotalScore
            let amountOwed = Double(scoreDifference) * Double(room.pointValue)
            
            // Create/update friendship: winner's perspective (positive balance = they owe winner)
            do {
                try await firebaseFriendService.createOrUpdateFriendship(
                    userId1: winner.id.uuidString,
                    userId2: player.id.uuidString,
                    user1Name: winner.name,
                    user2Name: player.name,
                    balanceChange: amountOwed
                )
                print("✅ Updated friendship: \(winner.name) ↔ \(player.name), balance change: $\(amountOwed)")
            } catch {
                print("❌ Failed to create friendship: \(error.localizedDescription)")
            }
        }
        
        // Also create friendships between all other players (0 balance change, just tracking games played)
        for i in 0..<room.players.count {
            for j in (i+1)..<room.players.count {
                let player1 = room.players[i]
                let player2 = room.players[j]
                
                // Skip if one of them is the winner (already handled above)
                if player1.id == winner.id || player2.id == winner.id { continue }
                
                do {
                    try await firebaseFriendService.createOrUpdateFriendship(
                        userId1: player1.id.uuidString,
                        userId2: player2.id.uuidString,
                        user1Name: player1.name,
                        user2Name: player2.name,
                        balanceChange: 0.0 // No money exchange between non-winners
                    )
                    print("✅ Updated friendship: \(player1.name) ↔ \(player2.name)")
                } catch {
                    print("❌ Failed to create friendship: \(error.localizedDescription)")
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
                currentRoom = room
            }
        }
    }
    
    /// Stop observing room updates
    private func stopObservingRoom() {
        roomObserverTask?.cancel()
        roomObserverTask = nil
    }
}
