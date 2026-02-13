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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
        
        #if DEBUG
        print("🚀 App launched with \(useMock ? "Mock" : "Firebase") Services")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                AuthGateView(gameState: gameState, friendService: friendService)
                    .preferredColorScheme(.dark)
                
                OfflineBannerView()
            }
        }
    }
}
