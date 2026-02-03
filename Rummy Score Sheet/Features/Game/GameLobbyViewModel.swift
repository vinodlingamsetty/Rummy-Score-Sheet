//
//  GameLobbyViewModel.swift
//  Rummy Scorekeeper
//
//  Manages lobby state, player list, and ready states
//

import Foundation

@Observable
final class GameLobbyViewModel {
    var room: GameRoom
    var currentUserId: UUID?
    var isQRCodePresented = false
    var onRoomChange: ((GameRoom) -> Void)?

    var isModerator: Bool {
        currentUserId.map { id in room.players.contains { $0.id == id && $0.isModerator } } ?? false
    }

    var allPlayersReady: Bool {
        room.players.count >= 2 && room.players.allSatisfy { $0.isReady }
    }

    init(room: GameRoom, currentUserId: UUID? = nil, onRoomChange: ((GameRoom) -> Void)? = nil) {
        self.room = room
        self.currentUserId = currentUserId
        self.onRoomChange = onRoomChange
    }

    func toggleReady(for playerId: UUID) {
        guard let index = room.players.firstIndex(where: { $0.id == playerId }) else { return }
        room.players[index].isReady.toggle()
        onRoomChange?(room)
    }

    func startGame() {
        var updated = room
        updated.isStarted = true
        updated.players = updated.players.map { p in
            var copy = p
            copy.scores = [Int](repeating: 0, count: 6)
            return copy
        }
        room = updated
        onRoomChange?(updated)
    }
}
