//
//  MainTabView.swift
//  Rummy Scorekeeper
//
//  Custom floating tab bar — Liquid Glass style
//

import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case game
    case friends
    case rules
    case profile

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .game: return "list.bullet.clipboard.fill"
        case .friends: return "person.2.fill"
        case .rules: return "book.fill"
        case .profile: return "person.crop.circle"
        }
    }
}

struct MainTabView: View {
    @Bindable var gameState: AppGameState

    var body: some View {
        TabView(selection: $gameState.selectedTab) {
            HomeView(gameState: gameState)
                .tabItem { Label("Home", systemImage: AppTab.home.icon) }
                .tag(AppTab.home)

            GameTabContent(gameState: gameState)
                .tabItem { Label("Game", systemImage: AppTab.game.icon) }
                .tag(AppTab.game)

            TabPlaceholderView(title: "Friends")
                .tabItem { Label("Friends", systemImage: AppTab.friends.icon) }
                .tag(AppTab.friends)

            TabPlaceholderView(title: "Rules")
                .tabItem { Label("Rules", systemImage: AppTab.rules.icon) }
                .tag(AppTab.rules)

            TabPlaceholderView(title: "Profile")
                .tabItem { Label("Profile", systemImage: AppTab.profile.icon) }
                .tag(AppTab.profile)
        }
        .tint(AppTheme.primaryColor)
        .alert("Error", isPresented: Binding(
            get: { gameState.errorMessage != nil },
            set: { if !$0 { gameState.errorMessage = nil } }
        )) {
            Button("OK") { gameState.errorMessage = nil }
        } message: {
            Text(gameState.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView(gameState: gameState)
        case .game:
            GameTabContent(gameState: gameState)
        case .friends:
            TabPlaceholderView(title: "Friends")
        case .rules:
            TabPlaceholderView(title: "Rules")
        case .profile:
            TabPlaceholderView(title: "Profile")
        }
    }
}

private struct GameTabContent: View {
    @Bindable var gameState: AppGameState

    var body: some View {
        if let room = gameState.currentRoom {
            if room.isStarted {
                GameView(
                    viewModel: GameViewModel(
                        room: room,
                        currentUserId: gameState.currentUserId,
                        roomService: gameState.roomService,
                        onRoomUpdate: { gameState.updateRoom($0) }
                    )
                ) {
                    gameState.endGame()
                } onLeaveGame: {
                    gameState.leaveGame()
                }
            } else {
                GameLobbyView(
                    viewModel: GameLobbyViewModel(
                        room: room,
                        currentUserId: gameState.currentUserId,
                        onRoomChange: { gameState.updateRoom($0) },
                        onSetReady: { gameState.setReady($0) }
                    ),
                    onStartGame: {
                        gameState.startGame()
                    },
                    onLeave: {
                        gameState.leaveGame()
                    }
                )
            }
        } else {
            TabPlaceholderView(title: "Game")
        }
    }
}

private struct TabPlaceholderView: View {
    let title: String

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()
            Text(title)
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MainTabView(gameState: AppGameState(roomService: MockRoomService()))
}
