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
    var showEliminationAlert: Bool = false
    var showEndGameConfirmation: Bool = false
    
    private let roomService: RoomService
    private let onRoomUpdate: (GameRoom) -> Void
    private let onGameEndAndExit: (() -> Void)?

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
    
    /// True when all active players have entered a score for the current round.
    /// Used for auto-advance; requires being on latest round.
    var canAdvanceRound: Bool {
        guard selectedRound == room.currentRound else { return false }
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
    
    var isCurrentUserModerator: Bool {
        room.players.first { $0.id == currentUserId }?.isModerator ?? false
    }
    
    var isCurrentUserEliminated: Bool {
        guard let currentUserId = currentUserId,
              let player = room.players.first(where: { $0.id == currentUserId }) else { return false }
        return isEliminated(player)
    }

    init(
        room: GameRoom,
        currentUserId: UUID? = nil,
        roomService: RoomService,
        onRoomUpdate: @escaping (GameRoom) -> Void,
        onGameEndAndExit: (() -> Void)? = nil
    ) {
        self.room = room
        self.currentUserId = currentUserId
        self.roomService = roomService
        self.onRoomUpdate = onRoomUpdate
        self.onGameEndAndExit = onGameEndAndExit
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
    
    /// Player is eliminated when their total score reaches or exceeds the point limit.
    func isEliminated(_ player: Player) -> Bool {
        player.totalScore >= room.pointLimit
    }
    
    /// Player has the lowest score (leader) among active players.
    func isLeader(_ player: Player) -> Bool {
        guard !room.players.isEmpty else { return false }
        let lowestScore = sortedPlayers.first!.totalScore
        return player.totalScore == lowestScore && !isEliminated(player)
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
                
                // Auto-end if only one active player remains (others eliminated at point limit)
                if await checkAndAutoEndIfWinner() {
                    isLoading = false
                    return
                }
                
                // Auto-advance to next round if:
                // 1. We are editing the LATEST round
                // 2. All active players have scores
                if canAdvanceRound {
                    try await Task.sleep(nanoseconds: AppConstants.Timing.autoAdvanceRoundDelay)
                    let nextRoom = try await roomService.nextRound(roomCode: room.id)
                    updateRoomState(nextRoom)
                    selectedRound = nextRoom.currentRound // Auto-follow to new round
                    _ = await checkAndAutoEndIfWinner()
                }
            } catch {
                errorMessage = error.localizedDescription
                #if DEBUG
                print("❌ Failed to update score: \(error.localizedDescription)")
                #endif
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Helper
    
    private func updateRoomState(_ newRoom: GameRoom) {
        // Check if current user was just eliminated (transition: was active, now eliminated)
        if let cid = currentUserId,
           let oldPlayer = room.players.first(where: { $0.id == cid }),
           let newPlayer = newRoom.players.first(where: { $0.id == cid }),
           !isEliminated(oldPlayer),
           isEliminated(newPlayer) {
            showEliminationAlert = true
        }
        
        // Detect game completion transition
        let justCompleted = !room.isCompleted && newRoom.isCompleted
        
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
                _ = await checkAndAutoEndIfWinner()
            } catch {
                errorMessage = error.localizedDescription
                #if DEBUG
                print("❌ Failed to advance round: \(error.localizedDescription)")
                #endif
            }
            
            isLoading = false
        }
    }
    
    /// When only one active player remains (others eliminated), auto-end game and exit.
    /// - Returns: true if game was auto-ended (caller should return early)
    private func checkAndAutoEndIfWinner() async -> Bool {
        guard !room.isCompleted, let w = winner else { return false }
        await endGame(winnerId: w.id)
        onGameEndAndExit?()
        return true
    }
    
    // MARK: - Game End
    
    /// Ends the game, creates friendships, then completes. Callers should await before exiting.
    func endGame(winnerId: UUID? = nil, isVoid: Bool = false) async {
        isLoading = true
        errorMessage = nil
        
        // If voiding, no winner is declared. 
        // Otherwise, use provided winnerId, or auto-detect winner, or fallback to current leader.
        let actualWinnerId: UUID? = isVoid ? nil : (winnerId ?? winner?.id ?? sortedPlayers.first?.id)
        
        do {
            let updatedRoom = try await roomService.endGame(roomCode: room.id, winnerId: actualWinnerId)
            updateRoomState(updatedRoom)
        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("❌ Failed to end game: \(error.localizedDescription)")
            #endif
        }
        
        isLoading = false
    }
}
