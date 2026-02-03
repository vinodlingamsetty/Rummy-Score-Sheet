//
//  HomeView.swift
//  Rummy Scorekeeper
//
//  Home tab — Welcome, Create/Join Room, Recent Games
//

import SwiftUI

// MARK: - Data Model

struct GameHistoryItem: Identifiable {
    let id: String
    let date: Date
    let pointValue: Int
    let winnerName: String
    let players: [String]
    let currentUserName: String
}

// MARK: - HomeView

struct HomeView: View {
    @Bindable var gameState: AppGameState
    @State private var isGameSetupPresented = false
    @State private var isJoinRoomPresented = false

    // Sample data for preview
    private let sampleGames: [GameHistoryItem] = [
        GameHistoryItem(
            id: "A7K3M9",
            date: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 29))!,
            pointValue: 10,
            winnerName: "John Doe",
            players: ["John", "Jane", "Mike", "Sarah"],
            currentUserName: "John"
        ),
        GameHistoryItem(
            id: "B2M5N8",
            date: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 28))!,
            pointValue: 5,
            winnerName: "Alex Brown",
            players: ["John", "Alex", "Emma"],
            currentUserName: "John"
        )
    ]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing._6) {
                    welcomeHeader
                    actionCards
                    recentGamesSection
                }
                .padding(.top, AppSpacing._6)
                .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._4)
            }
        }
        .sheet(isPresented: $isGameSetupPresented) {
            GameSetupView(gameState: gameState)
        }
        .sheet(isPresented: $isJoinRoomPresented) {
            JoinRoomView(gameState: gameState)
        }
    }

    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing._1) {
            Text("Welcome Back")
                .font(AppTypography.largeTitle())
                .foregroundStyle(AppTheme.textPrimary)
            Text("John")
                .font(AppTypography.body())
                .foregroundStyle(AppTheme.textSecondary)
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
                style: .gradient,
                action: { isGameSetupPresented = true }
            )
            ActionCard(
                title: "Join Room",
                subtitle: "Enter a room code",
                icon: "qrcode",
                style: .glass,
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
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button {
                    // View all action
                } label: {
                    HStack(spacing: AppSpacing._1) {
                        Text("View All")
                            .font(AppTypography.subheadline())
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(AppTheme.iosBlue)
                }
            }
            .padding(.horizontal, AppSpacing._4)
            
            // Game cards
            VStack(spacing: AppSpacing._3) {
                ForEach(sampleGames) { game in
                    GameHistoryCard(game: game)
                }
            }
            .padding(.horizontal, AppSpacing._4)
        }
    }
}

// MARK: - Action Card Style

private enum ActionCardStyle {
    case gradient
    case glass
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
                        .foregroundStyle(style == .gradient ? .white : AppTheme.textPrimary)
                    Text(subtitle)
                        .font(AppTypography.footnote())
                        .foregroundStyle(style == .gradient ? .white.opacity(0.8) : AppTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style == .gradient ? .white.opacity(0.8) : AppTheme.textSecondary)
            }
            .padding(AppComponent.Card.padding)
            .background {
                if style == .gradient {
                    RoundedRectangle(cornerRadius: AppRadius.iosCard)
                        .fill(AppTheme.gradientPrimary)
                } else {
                    RoundedRectangle(cornerRadius: AppRadius.iosCard)
                        .fill(AppTheme.glassBackground)
                }
            }
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
            .foregroundStyle(style == .gradient ? .white : AppTheme.primaryColor)
            .frame(width: iconSize, height: iconSize)
            .background {
                if style == .gradient {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(Color.white.opacity(0.2))
                } else {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(AppTheme.glassBackground)
                }
            }
    }
}

// MARK: - GameHistoryCard

private struct GameHistoryCard: View {
    let game: GameHistoryItem
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: game.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            // Top row: Game code + Point value
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing._1) {
                    Text("#\(game.id)")
                        .font(AppTypography.headline())
                        .foregroundStyle(AppTheme.primaryColor)
                    Text(formattedDate)
                        .font(AppTypography.footnote())
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppSpacing._1) {
                    Text("$\(game.pointValue)")
                        .font(AppTypography.headline())
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(game.winnerName)
                        .font(AppTypography.footnote())
                        .foregroundStyle(AppTheme.positiveColor)
                }
            }
            
            // Player chips row
            HStack(spacing: AppSpacing._2) {
                ForEach(game.players, id: \.self) { player in
                    PlayerChip(
                        name: player,
                        isHighlighted: player == game.currentUserName
                    )
                }
            }
        }
        .padding(AppComponent.Card.padding)
        .background(AppTheme.glassBackground, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - PlayerChip

private struct PlayerChip: View {
    let name: String
    let isHighlighted: Bool
    
    var body: some View {
        Text(name)
            .font(AppTypography.caption1())
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing._3)
            .padding(.vertical, AppSpacing._1 + 2)
            .background(
                Capsule()
                    .fill(isHighlighted ? AnyShapeStyle(AppTheme.iosBlue) : AnyShapeStyle(AppTheme.glassBackground))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(isHighlighted ? 0 : 0.1), lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview {
    HomeView(gameState: AppGameState())
}
