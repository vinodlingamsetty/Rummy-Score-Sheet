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
    @State private var friendService: FriendService

    init() {
        // Initialize Firebase (Auth, Firestore, Analytics, Crashlytics)
        FirebaseConfig.configure()
        
        // Choose service implementations
        // Toggle useMock to switch between Mock (local) and Firebase (multi-device)
        let useMock = false  // Set to true for offline/local testing
        
        let roomService: RoomService = useMock ? MockRoomService() : FirebaseRoomService()
        let friendServiceImpl: FriendService = useMock ? MockFriendService() : FirebaseFriendService()
        
        _gameState = State(initialValue: AppGameState(roomService: roomService, friendService: friendServiceImpl))
        _friendService = State(initialValue: friendServiceImpl)
        
        print("🚀 App launched with \(useMock ? "Mock" : "Firebase") Services")
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(gameState: gameState, friendService: friendService)
                .preferredColorScheme(.dark)
        }
    }
}
