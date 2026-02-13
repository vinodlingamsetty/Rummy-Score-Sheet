//
//  GameLobbyViewModel.swift
//  Rummy Scorekeeper
//
//  Manages lobby state, player list, and ready states — routes through AppGameState
//

import Foundation

@Observable
final class GameLobbyViewModel {
    var room: GameRoom
    var currentUserId: UUID?
    var isQRCodePresented = false

    /// Callback to update room in AppGameState
    var onRoomChange: ((GameRoom) -> Void)?

    /// Callback to set ready via AppGameState (which calls RoomService)
    var onSetReady: ((Bool) -> Void)?

    var isModerator: Bool {
        currentUserId.map { id in room.players.contains { $0.id == id && $0.isModerator } } ?? false
    }

    var allPlayersReady: Bool {
        room.players.count >= 2 && room.players.allSatisfy { $0.isReady }
    }

    init(
        room: GameRoom,
        currentUserId: UUID? = nil,
        onRoomChange: ((GameRoom) -> Void)? = nil,
        onSetReady: ((Bool) -> Void)? = nil
    ) {
        self.room = room
        self.currentUserId = currentUserId
        self.onRoomChange = onRoomChange
        self.onSetReady = onSetReady
    }

    func toggleReady(for playerId: UUID) {
        guard let index = room.players.firstIndex(where: { $0.id == playerId }) else { return }
        let newReady = !room.players[index].isReady

        // Update local state immediately for responsiveness
        room.players[index].isReady = newReady
        onRoomChange?(room)

        // Route through AppGameState -> RoomService
        if playerId == currentUserId {
            onSetReady?(newReady)
        }
    }
}
