//
//  WinnerDeclarationView.swift
//  Rummy Scorekeeper
//
//  Celebratory winner declaration screen
//

import SwiftUI

struct WinnerDeclarationView: View {
    let game: GameRoom
    let onDismiss: () -> Void
    
    @State private var animateWinner = false
    @State private var animateTrophy = false
    
    private var sortedPlayers: [Player] {
        game.players.sorted { $0.totalScore < $1.totalScore }
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppSpacing._8) {
                    // Trophy & Winner
                    winnerSection
                    
                    // Final Standings
                    standingsSection
                    
                    // Game Stats
                    gameStatsSection
                    
                    // Action Button
                    doneButton
                }
                .padding(AppSpacing._4)
                .padding(.bottom, AppSpacing._8)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateTrophy = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                animateWinner = true
            }
        }
    }
    
    // MARK: - Winner Section
    
    private var winnerSection: some View {
        VStack(spacing: AppSpacing._4) {
            // Trophy
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(animateTrophy ? 1 : 0.5)
                .rotationEffect(.degrees(animateTrophy ? 0 : -180))
                .shadow(color: .yellow.opacity(0.5), radius: 20, x: 0, y: 10)
            
            // Winner Badge
            Text("WINNER")
                .font(AppTypography.title3())
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(2)
            
            // Winner Name
            if let winner = game.winner {
                VStack(spacing: AppSpacing._2) {
                    Text(winner.name)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .opacity(animateWinner ? 1 : 0)
                        .offset(y: animateWinner ? 0 : 20)
                    
                    Text("Final Score: \(winner.totalScore)")
                        .font(AppTypography.title2())
                        .foregroundStyle(AppTheme.positiveColor)
                        .opacity(animateWinner ? 1 : 0)
                }
            }
            
            // Celebration Message
            Text("🎉 Congratulations! 🎉")
                .font(AppTypography.headline())
                .foregroundStyle(.secondary)
                .padding(.top, AppSpacing._2)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._6)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(
                    LinearGradient(
                        colors: [.yellow.opacity(0.5), .orange.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
    
    // MARK: - Standings Section
    
    private var standingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Final Standings")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
            
            VStack(spacing: AppSpacing._2) {
                ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                    PlayerStandingRow(
                        rank: index + 1,
                        player: player,
                        isWinner: game.winnerId == player.id.uuidString,
                        pointValue: game.pointValue
                    )
                }
            }
        }
    }
    
    // MARK: - Game Stats
    
    private var gameStatsSection: some View {
        VStack(spacing: AppSpacing._3) {
            Text("Game Summary")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: AppSpacing._3) {
                StatCard(
                    icon: "number.circle.fill",
                    label: "Room Code",
                    value: "#\(game.id)"
                )
                
                StatCard(
                    icon: "arrow.clockwise.circle.fill",
                    label: "Rounds Played",
                    value: "\(game.currentRound)"
                )
            }
            
            HStack(spacing: AppSpacing._3) {
                StatCard(
                    icon: "flag.checkered.circle.fill",
                    label: "Point Limit",
                    value: "\(game.pointLimit)"
                )
                
                StatCard(
                    icon: "dollarsign.circle.fill",
                    label: "Point Value",
                    value: "$\(game.pointValue)"
                )
            }
        }
    }
    
    // MARK: - Done Button
    
    private var doneButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onDismiss()
        } label: {
            Text("Back to Home")
                .font(AppTypography.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing._4)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryColor.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .glassEffect(in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Player Standing Row

private struct PlayerStandingRow: View {
    let rank: Int
    let player: Player
    let isWinner: Bool
    let pointValue: Int
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return .secondary
        }
    }
    
    private var medalIcon: String {
        switch rank {
        case 1: return "trophy.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
    
    private var winnings: Int {
        // Winner takes pot, others lose based on their score
        isWinner ? calculateWinnings() : -player.totalScore * pointValue
    }
    
    private func calculateWinnings() -> Int {
        let totalLosses = game.players.filter { $0.id != player.id }
            .reduce(0) { $0 + $1.totalScore * pointValue }
        return totalLosses
    }
    
    private var game: GameRoom {
        // This is a hack for the preview; in real usage, pass game as parameter
        GameRoom(id: "", pointLimit: 0, pointValue: pointValue, players: [player], currentRound: 0, isStarted: false)
    }
    
    var body: some View {
        HStack(spacing: AppSpacing._3) {
            // Rank Badge
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 44, height: 44)
                    
                    if !medalIcon.isEmpty {
                        Image(systemName: medalIcon)
                            .font(.system(size: 20))
                            .foregroundStyle(rank == 1 ? .black : .white)
                    }
                } else {
                    Text("\(rank)")
                        .font(AppTypography.headline())
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.controlMaterial, in: Circle())
                }
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(AppTypography.headline())
                    .foregroundStyle(.primary)
                
                Text("Total: \(player.totalScore) pts")
                    .font(AppTypography.footnote())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Winnings/Losses
            VStack(alignment: .trailing, spacing: 2) {
                Text(winnings >= 0 ? "+$\(winnings)" : "-$\(-winnings)")
                    .font(AppTypography.title3())
                    .fontWeight(.semibold)
                    .foregroundStyle(winnings >= 0 ? AppTheme.positiveColor : AppTheme.negativeColor)
                
                if isWinner {
                    Text("Winner!")
                        .font(AppTypography.caption1())
                        .foregroundStyle(AppTheme.positiveColor)
                }
            }
        }
        .padding(AppSpacing._3)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(isWinner ? rankColor.opacity(0.5) : Color.white.opacity(0.1), lineWidth: isWinner ? 2 : 1)
        )
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: AppSpacing._2) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(AppTheme.primaryColor)
            
            Text(label)
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(AppTypography.headline())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._3)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

// MARK: - Preview

#Preview {
    WinnerDeclarationView(
        game: GameRoom(
            id: "ABC123",
            pointLimit: 201,
            pointValue: 10,
            players: [
                Player(id: UUID(), name: "Alice", isReady: true, isModerator: true, scores: [15, 20, 10]),
                Player(id: UUID(), name: "Bob", isReady: true, isModerator: false, scores: [25, 30, 20]),
                Player(id: UUID(), name: "Charlie", isReady: true, isModerator: false, scores: [35, 40, 30])
            ],
            currentRound: 3,
            isStarted: true,
            createdAt: Date(),
            createdBy: "user123",
            isCompleted: true,
            endedAt: Date(),
            winnerId: UUID().uuidString
        ),
        onDismiss: {}
    )
}
