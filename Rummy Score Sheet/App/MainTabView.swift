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
    let friendService: FriendService

    var body: some View {
        TabView(selection: $gameState.selectedTab) {
            HomeView(gameState: gameState)
                .tabItem { Label("Home", systemImage: AppTab.home.icon) }
                .tag(AppTab.home)

            GameTabContent(gameState: gameState)
                .tabItem { Label("Game", systemImage: AppTab.game.icon) }
                .tag(AppTab.game)

            FriendsView(friendService: friendService, selectedTab: $gameState.selectedTab)
                .tabItem { Label("Friends", systemImage: AppTab.friends.icon) }
                .tag(AppTab.friends)

            RulesView()
                .tabItem { Label("Rules", systemImage: AppTab.rules.icon) }
                .tag(AppTab.rules)

            ProfileView(friendService: friendService)
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
}

private struct GameTabContent: View {
    @Bindable var gameState: AppGameState

    var body: some View {
        switch gameState.activeGameScreen {
        case .summary(let room):
            WinnerDeclarationView(game: room) {
                gameState.leaveGame()
            }
        case .playing(let viewModel):
            GameView(
                viewModel: viewModel,
                onLeaveGame: {
                    gameState.leaveGame()
                }
            )
        case .lobby(let viewModel):
            GameLobbyView(
                viewModel: viewModel,
                onStartGame: {
                    gameState.startGame()
                },
                onLeave: {
                    gameState.leaveGame()
                }
            )
        case .none:
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
    MainTabView(
        gameState: AppGameState(roomService: MockRoomService(), friendService: MockFriendService()),
        friendService: MockFriendService()
    )
}
