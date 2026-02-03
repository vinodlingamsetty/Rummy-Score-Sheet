//
//  AppGameState.swift
//  Rummy Scorekeeper
//
//  App-level game session state — current room, tab selection
//

import Foundation
import SwiftUI

@Observable
final class AppGameState {
    var currentRoom: GameRoom?
    var selectedTab: AppTab = .home
    var currentUserId: UUID?

    func createRoom(pointLimit: Int, pointValue: Int, playerCount: Int) {
        let code = generateRoomCode()
        let moderatorId = UUID()
        currentUserId = moderatorId
        let moderator = Player(
            id: moderatorId,
            name: "You",
            isReady: true,
            isModerator: true,
            scores: []
        )
        currentRoom = GameRoom(
            id: code,
            pointLimit: pointLimit,
            pointValue: pointValue,
            players: [moderator],
            currentRound: 1,
            isStarted: false
        )
        selectedTab = .game
    }

    func joinRoom(code: String, playerName: String = "Player") {
        let playerId = UUID()
        currentUserId = playerId
        let player = Player(
            id: playerId,
            name: playerName,
            isReady: false,
            isModerator: false,
            scores: []
        )
        // TODO: Integrate with backend — for now create room with joiner
        currentRoom = GameRoom(
            id: code.uppercased(),
            pointLimit: 500,
            pointValue: 10,
            players: [player],
            currentRound: 1,
            isStarted: false
        )
        selectedTab = .game
    }

    func startGame() {
        guard var room = currentRoom else { return }
        room.isStarted = true
        room.players = room.players.map { p in
            var copy = p
            copy.scores = [Int](repeating: 0, count: 6)
            return copy
        }
        currentRoom = room
    }

    func leaveGame() {
        currentRoom = nil
        selectedTab = .home
    }

    func endGame() {
        currentRoom = nil
        selectedTab = .home
    }

    private func generateRoomCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
