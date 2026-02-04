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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        tabContent(for: gameState.selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                FloatingTabBar(selectedTab: Binding(
                    get: { gameState.selectedTab },
                    set: { gameState.selectedTab = $0 }
                ))
            }
            .ignoresSafeArea(edges: .bottom)
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
                    viewModel: GameViewModel(room: room, currentUserId: gameState.currentUserId)
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
                    )
                ) {
                    gameState.startGame()
                }
            }
        } else {
            TabPlaceholderView(title: "Game")
        }
    }
}

private struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(reduceMotion ? .default : AppAnimation.springBouncy) {
                        selectedTab = tab
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }
        .padding(.horizontal, AppSpacing._2)
        .padding(.vertical, AppSpacing._2)
        .background(reduceTransparency ? AnyShapeStyle(Color.black.opacity(0.6)) : AnyShapeStyle(AppTheme.glassMaterial), in: Capsule())
        .padding(.horizontal, AppSpacing._6)
        .padding(.bottom, AppSpacing._6)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(AppTheme.glassMaterial)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                }
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AppTheme.primaryColor : .white)
                    .shadow(color: isSelected ? AppTheme.primaryColor.opacity(0.5) : .clear, radius: 6)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

#Preview {
    MainTabView(gameState: AppGameState(roomService: MockRoomService()))
}
