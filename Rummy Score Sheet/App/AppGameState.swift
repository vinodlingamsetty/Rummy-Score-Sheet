//
//  AppGameState.swift
//  Rummy Scorekeeper
//
//  App-level game session state — thin coordinator that delegates to RoomService.
//  Does not perform authorization; moderator-only checks are UI-level. Firestore
//  security rules should enforce server-side (see backend repo).
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

    let roomService: RoomService // Internal access for GameViewModel
    let friendService: FriendService // Internal access for creating friendships
    private var roomObserverTask: Task<Void, Never>?

    // MARK: - Init

    init(roomService: RoomService, friendService: FriendService) {
        self.roomService = roomService
        self.friendService = friendService
    }
    
    deinit {
        roomObserverTask?.cancel()
    }

    // MARK: - Room Actions

    func createRoom(pointLimit: Int, pointValue: Int) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            do {
                let result = try await roomService.createRoom(
                    pointLimit: pointLimit,
                    pointValue: pointValue
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
        let normalizedCode = code.uppercased().trimmingCharacters(in: .whitespaces)
        guard normalizedCode.count == AppConstants.RoomCode.length else {
            errorMessage = "Room code must be \(AppConstants.RoomCode.length) characters"
            return
        }
        
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            do {
                let result = try await roomService.joinRoom(code: normalizedCode, playerName: playerName)
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
                // Intentionally ignore leave errors — user is leaving; clear local state regardless
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
                // Don't clear room on transient nil (e.g. decode error); preserve state so tab switching doesn't kick user out
                if let room = room {
                    currentRoom = room
                }
            }
        }
    }
    
    /// Stop observing room updates
    private func stopObservingRoom() {
        roomObserverTask?.cancel()
        roomObserverTask = nil
    }
}
