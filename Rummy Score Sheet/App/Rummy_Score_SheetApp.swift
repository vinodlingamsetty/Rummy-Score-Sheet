//
//  Rummy_Score_SheetApp.swift
//  Rummy Scorekeeper
//
//  Main entry point
//

import SwiftUI

@main
struct Rummy_Score_SheetApp: App {
    @State private var gameState = AppGameState()

    var body: some Scene {
        WindowGroup {
            MainTabView(gameState: gameState)
        }
    }
}
