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

            ProfileView()
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
        if let room = gameState.currentRoom {
            if room.isCompleted {
                WinnerDeclarationView(game: room) {
                    gameState.leaveGame()
                }
            } else if room.isStarted {
                GameView(
                    viewModel: GameViewModel(
                        room: room,
                        currentUserId: gameState.currentUserId,
                        roomService: gameState.roomService,
                        onRoomUpdate: { gameState.updateRoom($0) },
                        onGameCompleted: { completedRoom in
                            await gameState.createFriendshipsFromGame(completedRoom)
                        },
                        onGameEndAndExit: { 
                            // No-op here; we handle transition to winner view via room.isCompleted
                        }
                    ),
                    onLeaveGame: {
                        gameState.leaveGame()
                    }
                )
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
    MainTabView(
        gameState: AppGameState(roomService: MockRoomService(), friendService: MockFriendService()),
        friendService: MockFriendService()
    )
}
