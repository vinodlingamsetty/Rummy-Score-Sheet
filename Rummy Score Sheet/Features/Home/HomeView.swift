//
//  HomeView.swift
//  Rummy Scorekeeper
//
//  Home tab — Welcome, Create/Join Room, Recent Games
//

import SwiftUI


// MARK: - HomeView

struct HomeView: View {
    @Bindable var gameState: AppGameState
    @State private var isGameSetupPresented = false
    @State private var isJoinRoomPresented = false
    
    // Game history state
    @State private var gameHistory: [GameRoom] = []
    @State private var isLoadingHistory = false
    @State private var historyError: String?
    
    private let historyService = GameHistoryService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing._6) {
                    welcomeHeader
                    actionCards
                    recentGamesSection
                }
                .padding(.top, AppSpacing._6)
                .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._4)
            }
            .background(AppTheme.background)
            .sheet(isPresented: $isGameSetupPresented) {
                GameSetupView(gameState: gameState)
            }
            .sheet(isPresented: $isJoinRoomPresented) {
                JoinRoomView(gameState: gameState)
            }
            .onAppear {
                loadGameHistory()
            }
            .refreshable {
                loadGameHistory()
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadGameHistory() {
        Task {
            isLoadingHistory = true
            historyError = nil
            
            do {
                gameHistory = try await historyService.fetchUserGameHistory(limit: 5)
            } catch {
                historyError = error.localizedDescription
                print("❌ Failed to load game history: \(error.localizedDescription)")
            }
            
            isLoadingHistory = false
        }
    }

    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing._1) {
            Text("Welcome Back")
                .font(AppTypography.largeTitle())
                .foregroundStyle(.primary)
            Text(FirebaseConfig.getUserDisplayName())
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing._4)
    }

    // MARK: - Action Cards
    
    private var actionCards: some View {
        VStack(spacing: AppSpacing._3) {
            ActionCard(
                title: "Create Room",
                subtitle: "Start a new game session",
                icon: "plus",
                style: .prominent,
                action: { isGameSetupPresented = true }
            )
            ActionCard(
                title: "Join Room",
                subtitle: "Enter a room code",
                icon: "qrcode",
                style: .standard,
                action: { isJoinRoomPresented = true }
            )
        }
        .padding(.horizontal, AppSpacing._4)
    }

    // MARK: - Recent Games Section
    
    private var recentGamesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._4) {
            // Section header
            HStack {
                Text("Recent Games")
                    .font(AppTypography.title2())
                    .foregroundStyle(.primary)
                Spacer()
                if !gameHistory.isEmpty {
                    Button {
                        // TODO: Navigate to full history view
                    } label: {
                        Label {
                            Text("View All")
                                .font(AppTypography.subheadline())
                        } icon: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .accessibilityHidden(true)
                        }
                    }
                    .foregroundStyle(.tint)
                }
            }
            .padding(.horizontal, AppSpacing._4)
            
            // Content: Loading, Empty, or Games
            if isLoadingHistory {
                loadingView
            } else if gameHistory.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: AppSpacing._3) {
                    ForEach(gameHistory) { game in
                        NavigationLink {
                            GameDetailView(game: game)
                        } label: {
                            GameHistoryCard(game: game)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing._4)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing._3) {
            ProgressView()
                .tint(AppTheme.primaryColor)
            Text("Loading games...")
                .font(AppTypography.footnote())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing._3) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Games Yet")
                .font(AppTypography.headline())
                .foregroundStyle(.primary)
            
            Text("Start by creating or joining a room")
                .font(AppTypography.footnote())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._8)
        .padding(.horizontal, AppSpacing._4)
    }
}

// MARK: - Action Card Style

private enum ActionCardStyle {
    case prominent
    case standard
}

// MARK: - ActionCard

private struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let style: ActionCardStyle
    let action: () -> Void

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: AppSpacing._4) {
                // Icon container
                iconView
                
                // Text content
                VStack(alignment: .leading, spacing: AppSpacing._1) {
                    Text(title)
                        .font(AppTypography.headline())
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(AppTypography.footnote())
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(AppComponent.Card.padding)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.iosCard)
                    .fill(AppTheme.cardMaterial)
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.iosCard)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var iconView: some View {
        let iconSize: CGFloat = 48
        let iconFontSize: CGFloat = 24
        
        Image(systemName: icon)
            .font(.system(size: iconFontSize, weight: .medium))
            .foregroundStyle(AppTheme.primaryColor)
            .frame(width: iconSize, height: iconSize)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppTheme.controlMaterial)
            }
    }
}

// MARK: - Preview

#Preview {
    HomeView(gameState: AppGameState(roomService: MockRoomService(), friendService: MockFriendService()))
}
