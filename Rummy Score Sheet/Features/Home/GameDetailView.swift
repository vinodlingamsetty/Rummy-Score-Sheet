//
//  GameDetailView.swift
//  Rummy Scorekeeper
//
//  Readonly view for completed game details
//

import SwiftUI

struct GameDetailView: View {
    let game: GameRoom
    @Environment(\.dismiss) private var dismiss
    
    // Sorted players by final score (ascending)
    private var sortedPlayers: [Player] {
        game.players.sorted { $0.totalScore < $1.totalScore }
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppSpacing._6) {
                    // Game Header
                    gameHeader
                    
                    // Winner Card
                    if let winner = game.winner {
                        winnerCard(winner: winner)
                    }
                    
                    // Final Standings
                    finalStandingsSection
                    
                    // Round by Round Scores
                    roundScoresSection
                }
                .padding(.top, AppSpacing._4)
                .padding(.bottom, AppSpacing._8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Game #\(game.id)")
                        .font(AppTypography.headline())
                        .foregroundStyle(.primary)
                    if let endedAt = game.endedAt {
                        Text(endedAt, format: .dateTime.month().day().hour().minute())
                            .font(AppTypography.caption1())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Game Header
    
    private var gameHeader: some View {
        VStack(spacing: AppSpacing._3) {
            HStack(spacing: AppSpacing._4) {
                // Point Limit
                StatBadge(
                    icon: "flag.checkered",
                    label: "Point Limit",
                    value: "\(game.pointLimit)"
                )
                
                // Point Value
                StatBadge(
                    icon: "dollarsign.circle",
                    label: "Point Value",
                    value: "$\(game.pointValue)"
                )
            }
            
            HStack(spacing: AppSpacing._4) {
                // Total Rounds
                StatBadge(
                    icon: "list.number",
                    label: "Rounds",
                    value: "\(game.currentRound)"
                )
                
                // Players
                StatBadge(
                    icon: "person.2",
                    label: "Players",
                    value: "\(game.players.count)"
                )
            }
        }
        .padding(.horizontal, AppSpacing._4)
    }
    
    // MARK: - Winner Card
    
    private func winnerCard(winner: Player) -> some View {
        VStack(spacing: AppSpacing._3) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Winner")
                .font(AppTypography.subheadline())
                .foregroundStyle(.secondary)
            
            Text(winner.name)
                .font(AppTypography.title1())
                .foregroundStyle(.primary)
            
            Text("Final Score: \(winner.totalScore)")
                .font(AppTypography.body())
                .foregroundStyle(AppTheme.positiveColor)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._6)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(AppTheme.primaryColor.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, AppSpacing._4)
    }
    
    // MARK: - Final Standings
    
    private var finalStandingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Final Standings")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
                .padding(.horizontal, AppSpacing._4)
            
            VStack(spacing: AppSpacing._2) {
                ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                    PlayerStandingRow(
                        rank: index + 1,
                        player: player,
                        isWinner: game.winnerId == player.id.uuidString
                    )
                }
            }
            .padding(.horizontal, AppSpacing._4)
        }
    }
    
    // MARK: - Round Scores
    
    private var roundScoresSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Round by Round")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
                .padding(.horizontal, AppSpacing._4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing._2) {
                    // Header row
                    HStack(spacing: AppSpacing._2) {
                        // Player name column
                        Text("Player")
                            .font(AppTypography.caption1())
                            .foregroundStyle(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        // Round columns
                        ForEach(0..<game.currentRound, id: \.self) { round in
                            Text("R\(round + 1)")
                                .font(AppTypography.caption1())
                                .foregroundStyle(.secondary)
                                .frame(width: 50)
                        }
                        
                        // Total column
                        Text("Total")
                            .font(AppTypography.caption1())
                            .foregroundStyle(.secondary)
                            .frame(width: 60)
                    }
                    .padding(.horizontal, AppSpacing._3)
                    .padding(.vertical, AppSpacing._2)
                    .background(AppTheme.controlMaterial, in: RoundedRectangle(cornerRadius: AppRadius.sm))
                    
                    // Player rows
                    ForEach(sortedPlayers) { player in
                        HStack(spacing: AppSpacing._2) {
                            // Player name
                            Text(player.name)
                                .font(AppTypography.footnote())
                                .foregroundStyle(.primary)
                                .frame(width: 100, alignment: .leading)
                                .lineLimit(1)
                            
                            // Round scores
                            ForEach(0..<game.currentRound, id: \.self) { round in
                                let score = round < player.scores.count ? player.scores[round] : 0
                                Text("\(score)")
                                    .font(AppTypography.footnote())
                                    .foregroundStyle(.primary)
                                    .frame(width: 50)
                            }
                            
                            // Total score
                            Text("\(player.totalScore)")
                                .font(AppTypography.footnote())
                                .fontWeight(.semibold)
                                .foregroundStyle(game.winnerId == player.id.uuidString ? AppTheme.positiveColor : .primary)
                                .frame(width: 60)
                        }
                        .padding(.horizontal, AppSpacing._3)
                        .padding(.vertical, AppSpacing._2)
                        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.sm))
                        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.sm))
                    }
                }
                .padding(.horizontal, AppSpacing._4)
            }
        }
    }
}

// MARK: - Supporting Views

private struct StatBadge: View {
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

private struct PlayerStandingRow: View {
    let rank: Int
    let player: Player
    let isWinner: Bool
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return .secondary
        }
    }
    
    var body: some View {
        HStack(spacing: AppSpacing._3) {
            // Rank badge
            Text("\(rank)")
                .font(AppTypography.headline())
                .foregroundStyle(rank <= 3 ? .black : .primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(rank <= 3 ? AnyShapeStyle(rankColor) : AnyShapeStyle(AppTheme.controlMaterial))
                )
            
            // Player name
            Text(player.name)
                .font(AppTypography.body())
                .foregroundStyle(.primary)
            
            Spacer()
            
            // Score
            Text("\(player.totalScore)")
                .font(AppTypography.title3())
                .fontWeight(.semibold)
                .foregroundStyle(isWinner ? AppTheme.positiveColor : .primary)
        }
        .padding(AppSpacing._3)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(isWinner ? AppTheme.primaryColor.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GameDetailView(
            game: GameRoom(
                id: "ABC123",
                pointLimit: 201,
                pointValue: 10,
                players: [
                    Player(id: UUID(), name: "Alice", isReady: true, isModerator: true, scores: [15, 20, 10]),
                    Player(id: UUID(), name: "Bob", isReady: true, isModerator: false, scores: [25, 30, 20]),
                    Player(id: UUID(), name: "Charlie", isReady: true, isModerator: false, scores: [10, 15, 25])
                ],
                currentRound: 3,
                isStarted: true,
                createdAt: Date(),
                createdBy: "user123",
                isCompleted: true,
                endedAt: Date(),
                winnerId: UUID().uuidString
            )
        )
    }
}
