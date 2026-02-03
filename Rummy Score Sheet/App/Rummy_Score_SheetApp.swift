//
//  Rummy_Score_SheetApp.swift
//  Rummy Scorekeeper
//
//  Main entry point
//

import SwiftUI

@main
struct Rummy_Score_SheetApp: App {
    @State private var gameState: AppGameState

    init() {
        // Inject MockRoomService — swap for FirebaseRoomService when ready
        #if DEBUG
        let roomService: RoomService = MockRoomService()
        #else
        let roomService: RoomService = MockRoomService() // Replace with real backend
        #endif
        _gameState = State(initialValue: AppGameState(roomService: roomService))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(gameState: gameState)
        }
    }
}
