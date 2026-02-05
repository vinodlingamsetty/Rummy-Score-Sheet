//
//  MockRoomService.swift
//  Rummy Scorekeeper
//
//  In-memory mock implementation of RoomService for local development and testing
//

import Foundation

/// In-memory mock implementation — no multi-device sync, data lives only on this device
actor MockRoomService: @preconcurrency RoomService {

    // MARK: - Storage

    private var rooms: [String: GameRoom] = [:]

    // MARK: - RoomService

    func createRoom(pointLimit: Int, pointValue: Int, playerCount: Int) async throws -> RoomServiceResult {
        let code = generateRoomCode()
        let moderatorId = UUID()
        let moderator = Player(
            id: moderatorId,
            name: "You",
            isReady: true,
            isModerator: true,
            scores: []
        )
        let room = GameRoom(
            id: code,
            pointLimit: pointLimit,
            pointValue: pointValue,
            players: [moderator],
            currentRound: 1,
            isStarted: false
        )
        rooms[code] = room
        return RoomServiceResult(room: room, currentUserId: moderatorId)
    }

    func joinRoom(code: String, playerName: String) async throws -> RoomServiceResult {
        let normalizedCode = code.uppercased()
        let playerId = UUID()
        let player = Player(
            id: playerId,
            name: playerName,
            isReady: false,
            isModerator: false,
            scores: []
        )

        if var existingRoom = rooms[normalizedCode] {
            existingRoom.players.append(player)
            rooms[normalizedCode] = existingRoom
            return RoomServiceResult(room: existingRoom, currentUserId: playerId)
        } else {
            // Mock: create room for the joiner (simulates joining)
            let room = GameRoom(
                id: normalizedCode,
                pointLimit: 500,
                pointValue: 10,
                players: [player],
                currentRound: 1,
                isStarted: false
            )
            rooms[normalizedCode] = room
            return RoomServiceResult(room: room, currentUserId: playerId)
        }
    }

    func leaveRoom(roomCode: String, playerId: UUID) async throws {
        guard var room = rooms[roomCode] else {
            throw RoomServiceError.roomNotFound
        }
        room.players.removeAll { $0.id == playerId }
        if room.players.isEmpty {
            rooms.removeValue(forKey: roomCode)
        } else {
            rooms[roomCode] = room
        }
    }

    func setReady(roomCode: String, playerId: UUID, ready: Bool) async throws -> GameRoom {
        guard var room = rooms[roomCode] else {
            throw RoomServiceError.roomNotFound
        }
        guard let index = room.players.firstIndex(where: { $0.id == playerId }) else {
            throw RoomServiceError.playerNotFound
        }
        room.players[index].isReady = ready
        rooms[roomCode] = room
        return room
    }

    func startGame(roomCode: String) async throws -> GameRoom {
        guard var room = rooms[roomCode] else {
            throw RoomServiceError.roomNotFound
        }
        room.isStarted = true
        room.players = room.players.map { player in
            var copy = player
            copy.scores = [] // Start with empty scores - user must enter explicitly
            return copy
        }
        rooms[roomCode] = room
        return room
    }
    
    func updatePlayerScore(roomCode: String, playerId: UUID, score: Int, round: Int) async throws -> GameRoom {
        guard var room = rooms[roomCode] else {
            throw RoomServiceError.roomNotFound
        }
        guard let playerIndex = room.players.firstIndex(where: { $0.id == playerId }) else {
            throw RoomServiceError.playerNotFound
        }
        
        // round is 1-based, index is 0-based
        let roundIndex = round - 1
        guard roundIndex >= 0 else { throw RoomServiceError.networkError(NSError(domain: "InvalidRound", code: 400)) }
        
        // Ensure scores array is large enough
        if room.players[playerIndex].scores.count <= roundIndex {
            room.players[playerIndex].scores.append(contentsOf: [Int](repeating: 0, count: roundIndex - room.players[playerIndex].scores.count + 1))
        }
        
        // Update score for the specific round
        room.players[playerIndex].scores[roundIndex] = score
        
        rooms[roomCode] = room
        return room
    }
    
    func nextRound(roomCode: String) async throws -> GameRoom {
        guard var room = rooms[roomCode] else {
            throw RoomServiceError.roomNotFound
        }
        
        room.currentRound += 1
        rooms[roomCode] = room
        return room
    }
    
    func endGame(roomCode: String, winnerId: UUID) async throws -> GameRoom {
        guard var room = rooms[roomCode] else {
            throw RoomServiceError.roomNotFound
        }
        
        room.isCompleted = true
        room.endedAt = Date()
        room.winnerId = winnerId.uuidString
        
        rooms[roomCode] = room
        return room
    }

    nonisolated func observeRoom(code: String) -> AsyncStream<GameRoom?> {
        AsyncStream { continuation in
            // Hop to the actor to read state safely
            Task { [weak self] in
                guard let self else {
                    continuation.yield(nil)
                    continuation.finish()
                    return
                }
                let snapshot = await self.roomSnapshot(for: code)
                continuation.yield(snapshot)
                continuation.finish()
            }
        }
    }

    // MARK: - Helpers

    private func roomSnapshot(for code: String) async -> GameRoom? {
        return rooms[code]
    }

    private func generateRoomCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}

