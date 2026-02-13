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

    var currentRoom: GameRoom? {
        didSet {
            updateActiveViewModel()
        }
    }
    var selectedTab: AppTab = .home
    var currentUserId: UUID?
    var isLoading = false
    var errorMessage: String?
    
    /// Stable view model for the active game session
    var activeGameViewModel: GameViewModel?

    // MARK: - Game Screen State
    
    enum GameScreenState {
        case lobby(GameLobbyViewModel)
        case playing(GameViewModel)
        case summary(GameRoom)
        case none
    }
    
    var activeGameScreen: GameScreenState {
        guard let room = currentRoom else { return .none }
        
        if room.isCompleted {
            return .summary(room)
        } else if room.isStarted {
            // Should have an active VM if started, or we're waiting for sync
            if let vm = activeGameViewModel {
                return .playing(vm)
            } else {
                // Fallback/loading state - shouldn't happen often if updateActiveViewModel works
                // Could return none or a loading state, but for now let's just create a temporary one if needed or wait
                // Ideally activeGameViewModel is already set by didSet of currentRoom
                 return .none
            }
        } else {
            return .lobby(GameLobbyViewModel(
                room: room,
                currentUserId: currentUserId,
                onRoomChange: { [weak self] in self?.updateRoom($0) },
                onSetReady: { [weak self] in self?.setReady($0) }
            ))
        }
    }

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

    private func updateActiveViewModel() {
        guard let room = currentRoom, room.isStarted else {
            activeGameViewModel = nil
            return
        }
        
        // Only create if we don't have one, or if it's for a different room
        if activeGameViewModel?.room.id != room.id {
            activeGameViewModel = GameViewModel(
                room: room,
                currentUserId: currentUserId,
                roomService: roomService,
                onRoomUpdate: { [weak self] updatedRoom in
                    self?.updateRoom(updatedRoom)
                },
                onGameEndAndExit: { [weak self] in
                    self?.endGame()
                }
            )
        } else {
            // Just update the existing VM's room data
            activeGameViewModel?.room = room
        }
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
