//
//  MockRoomService.swift
//  Rummy Scorekeeper
//
//  In-memory mock implementation of RoomService for local development and testing
//

import Foundation

/// In-memory mock implementation — no multi-device sync, data lives only on this device
final class MockRoomService: RoomService, @unchecked Sendable {

    // MARK: - Storage

    private var rooms: [String: GameRoom] = [:]
    private let lock = NSLock()

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
        lock.lock()
        rooms[code] = room
        lock.unlock()
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

        lock.lock()
        defer { lock.unlock() }

        // In mock mode, if room doesn't exist, create it with the joiner
        // (Real backend would throw .roomNotFound)
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
        lock.lock()
        defer { lock.unlock() }

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
        lock.lock()
        defer { lock.unlock() }

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
        lock.lock()
        defer { lock.unlock() }

        guard var room = rooms[roomCode] else {
            throw RoomServiceError.roomNotFound
        }
        room.isStarted = true
        room.players = room.players.map { player in
            var copy = player
            copy.scores = [Int](repeating: 0, count: 6)
            return copy
        }
        rooms[roomCode] = room
        return room
    }

    func observeRoom(code: String) -> AsyncStream<GameRoom?> {
        AsyncStream { continuation in
            lock.lock()
            let room = rooms[code]
            lock.unlock()
            continuation.yield(room)
            continuation.finish()
        }
    }

    // MARK: - Helpers

    private func generateRoomCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
