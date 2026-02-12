//
//  RoomService.swift
//  Rummy Scorekeeper
//
//  Protocol defining room operations — abstraction for mock and real backends
//

import Foundation

// MARK: - RoomServiceError

/// Unified errors for room operations (mock and real backends)
enum RoomServiceError: Error, LocalizedError {
    case roomNotFound
    case roomFull
    case notModerator
    case playerNotFound
    case invalidRoomCode
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .roomNotFound:
            return "Room not found"
        case .roomFull:
            return "Room is full"
        case .notModerator:
            return "Only the moderator can perform this action"
        case .playerNotFound:
            return "Player not found in room"
        case .invalidRoomCode:
            return "Invalid room code"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - RoomServiceResult

/// Result of createRoom/joinRoom — includes room and the current user's ID
struct RoomServiceResult {
    let room: GameRoom
    let currentUserId: UUID
}

// MARK: - RoomService Protocol

/// Abstraction for room operations — swap MockRoomService for FirebaseRoomService later
protocol RoomService: Sendable {

    /// Create a new room with the given settings. Returns the created room and moderator ID.
    func createRoom(pointLimit: Int, pointValue: Int) async throws -> RoomServiceResult

    /// Join an existing room by code. Returns the room and player ID.
    func joinRoom(code: String, playerName: String) async throws -> RoomServiceResult

    /// Leave a room.
    func leaveRoom(roomCode: String, playerId: UUID) async throws

    /// Set player ready state.
    func setReady(roomCode: String, playerId: UUID, ready: Bool) async throws -> GameRoom

    /// Start the game (moderator only).
    func startGame(roomCode: String) async throws -> GameRoom
    
    /// Update player score for a specific round
    func updatePlayerScore(roomCode: String, playerId: UUID, score: Int, round: Int) async throws -> GameRoom
    
    /// Advance to the next round
    func nextRound(roomCode: String) async throws -> GameRoom
    
    /// End the game and declare winner
    func endGame(roomCode: String, winnerId: UUID?) async throws -> GameRoom

    /// Observe room updates (real-time stream). Mock emits once; Firebase will stream.
    func observeRoom(code: String) -> AsyncStream<GameRoom?>
}
