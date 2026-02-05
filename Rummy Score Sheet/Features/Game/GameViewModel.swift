//
//  GameViewModel.swift
//  Rummy Scorekeeper
//
//  Manages active game state, rounds, and scores
//

import Foundation

@Observable
final class GameViewModel {
    var room: GameRoom
    var currentUserId: UUID?
    var isLoading = false
    var errorMessage: String?
    var isScoreInputPresented = false
    var selectedPlayerForScore: Player?
    
    // UI State
    var showTotalsView: Bool = false
    var selectedRound: Int // The round currently being viewed/edited
    
    private let roomService: RoomService
    private let onRoomUpdate: (GameRoom) -> Void
    private let onGameCompleted: ((GameRoom) async -> Void)?

    var currentRoundScore: Int {
        selectedRound - 1
    }

    var roundCount: Int {
        room.currentRound // Dynamic: shows actual game progress
    }

    var sortedPlayers: [Player] {
        room.players.sorted { $0.totalScore < $1.totalScore } // Ascending (lowest score wins)
    }
    
    var activePlayers: [Player] {
        room.players.filter { !isEliminated($0) }
    }
    
    var canAdvanceRound: Bool {
        // Only allow advancing if we are on the latest round
        guard selectedRound == room.currentRound else { return false }
        
        // All active (non-eliminated) players must have a score entered for current round
        return activePlayers.allSatisfy { player in
            let roundIndex = room.currentRound - 1
            return roundIndex < player.scores.count
        }
    }
    
    var winner: Player? {
        let activePlayers = self.activePlayers
        guard activePlayers.count == 1 else { return nil }
        return activePlayers.first
    }

    init(
        room: GameRoom,
        currentUserId: UUID? = nil,
        roomService: RoomService,
        onRoomUpdate: @escaping (GameRoom) -> Void,
        onGameCompleted: ((GameRoom) async -> Void)? = nil
    ) {
        self.room = room
        self.currentUserId = currentUserId
        self.roomService = roomService
        self.onRoomUpdate = onRoomUpdate
        self.onGameCompleted = onGameCompleted
        self.selectedRound = room.currentRound // Default to current active round
    }

    func score(for playerId: UUID, round: Int) -> Int? {
        guard let player = room.players.first(where: { $0.id == playerId }),
              round >= 0, round < player.scores.count else { return nil }
        return player.scores[round]
    }
    
    func hasScore(for playerId: UUID, round: Int) -> Bool {
        guard let player = room.players.first(where: { $0.id == playerId }) else { return false }
        return round >= 0 && round < player.scores.count
    }

    func selectRound(_ round: Int) {
        selectedRound = min(max(1, round), roundCount)
        // Turn off totals view when selecting a specific round
        showTotalsView = false
    }
    
    // MARK: - Player State
    
    func isEliminated(_ player: Player) -> Bool {
        player.totalScore >= room.pointLimit
    }
    
    // MARK: - Score Entry
    
    func presentScoreInput(for player: Player) {
        selectedPlayerForScore = player
        isScoreInputPresented = true
    }
    
    func submitScore(for playerId: UUID, score: Int) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                // Update score for the CURRENTLY SELECTED round
                let updatedRoom = try await roomService.updatePlayerScore(
                    roomCode: room.id,
                    playerId: playerId,
                    score: score,
                    round: selectedRound
                )
                
                // If the update was for the latest round, update room state
                // If it was for a past round, the room state update will handle it via observe
                updateRoomState(updatedRoom)
                
                isScoreInputPresented = false
                
                // Auto-advance to next round if:
                // 1. We are editing the LATEST round
                // 2. All active players have scores
                if canAdvanceRound {
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay for UX
                    let nextRoom = try await roomService.nextRound(roomCode: room.id)
                    updateRoomState(nextRoom)
                    selectedRound = nextRoom.currentRound // Auto-follow to new round
                }
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Failed to update score: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Helper
    
    private func updateRoomState(_ newRoom: GameRoom) {
        // Check if we should auto-follow round updates (if user was on latest round)
        let wasOnLatestRound = selectedRound == room.currentRound
        room = newRoom
        onRoomUpdate(newRoom)
        
        if wasOnLatestRound {
            selectedRound = newRoom.currentRound
        }
    }
    
    // MARK: - Round Progression
    
    func advanceToNextRound() {
        guard canAdvanceRound else {
            errorMessage = "All players must have scores before advancing"
            return
        }
        
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                let updatedRoom = try await roomService.nextRound(roomCode: room.id)
                updateRoomState(updatedRoom)
                selectedRound = updatedRoom.currentRound // Explicitly follow on manual advance
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Failed to advance round: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Game End
    
    func endGame(winnerId: UUID) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                let updatedRoom = try await roomService.endGame(roomCode: room.id, winnerId: winnerId)
                updateRoomState(updatedRoom)
                
                // Create friendships after game completes
                if let onGameCompleted = onGameCompleted {
                    await onGameCompleted(updatedRoom)
                }
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Failed to end game: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}
