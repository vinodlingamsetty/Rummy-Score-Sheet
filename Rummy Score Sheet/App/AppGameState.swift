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

    private let roomService: RoomService

    // MARK: - Init

    init(roomService: RoomService) {
        self.roomService = roomService
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

    // MARK: - Room Updates

    /// Update room from external source (e.g. GameLobbyViewModel)
    func updateRoom(_ room: GameRoom) {
        currentRoom = room
    }
}
