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
    private var roomObserverTask: Task<Void, Never>?

    // MARK: - Init

    init(roomService: RoomService) {
        self.roomService = roomService
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
