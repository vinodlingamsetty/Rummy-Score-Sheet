//
//  GameHistoryView.swift
//  Rummy Scorekeeper
//
//  Full list of past games
//

import SwiftUI

struct GameHistoryView: View {
    @State private var games: [GameRoom] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let historyService = GameHistoryService()
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(AppTheme.primaryColor)
            } else if games.isEmpty {
                ContentUnavailableView(
                    "No Games Found",
                    systemImage: "gamecontroller.slash",
                    description: Text("You haven't played any games yet.")
                )
            } else {
                List {
                    ForEach(games) { game in
                        NavigationLink {
                            GameDetailView(game: game)
                        } label: {
                            GameHistoryCard(game: game)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await loadGames()
                }
            }
        }
        .navigationTitle("Game History")
        .task {
            await loadGames()
        }
    }
    
    private func loadGames() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch more games for the full history view (e.g., 50)
            games = try await historyService.fetchUserGameHistory(limit: 50)
        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("❌ Failed to load full history: \(error.localizedDescription)")
            #endif
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        GameHistoryView()
    }
    .preferredColorScheme(.dark)
}
