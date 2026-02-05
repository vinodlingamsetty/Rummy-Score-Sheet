//
//  Rummy_Score_SheetApp.swift
//  Rummy Scorekeeper
//
//  Main entry point
//

import SwiftUI
import FirebaseCore

@main
struct Rummy_Score_SheetApp: App {
    @State private var gameState: AppGameState

    init() {
        // Initialize Firebase (Auth, Firestore, Analytics, Crashlytics)
        FirebaseConfig.configure()
        
        // Choose RoomService implementation
        // Toggle useMock to switch between Mock (local) and Firebase (multi-device)
        let useMock = true  // Set to true for offline/local testing
        
        let roomService: RoomService = useMock ? MockRoomService() : FirebaseRoomService()
        
        _gameState = State(initialValue: AppGameState(roomService: roomService))
        
        print("🚀 App launched with \(useMock ? "Mock" : "Firebase") RoomService")
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(gameState: gameState)
                .preferredColorScheme(.dark)
        }
    }
}
