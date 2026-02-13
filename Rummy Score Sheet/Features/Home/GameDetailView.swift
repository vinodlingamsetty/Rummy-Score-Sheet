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
    
    /// The actual number of rounds to display, based on data present in player scores
    private var actualRoundCount: Int {
        let maxScoreCount = game.players.map { $0.scores.count }.max() ?? 0
        return max(game.currentRound, maxScoreCount)
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
                    } else if game.isCompleted {
                        voidGameCard
                    }
                    
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
    
    private var voidGameCard: some View {
        VStack(spacing: AppSpacing._2) {
            Image(systemName: "slash.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Game Voided")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
            
            Text("No winner was declared for this game.")
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._6)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .padding(.horizontal, AppSpacing._4)
    }
    
    // MARK: - Round Scores
    
    private var roundScoresSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Round by Round")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
                .padding(.horizontal, AppSpacing._4)
            
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header row
                    HStack(spacing: 0) {
                        Text("Player")
                            .font(AppTypography.caption1().bold())
                            .foregroundStyle(.secondary)
                            .frame(width: 120, alignment: .leading)
                        
                        ForEach(0..<actualRoundCount, id: \.self) { round in
                            Text("R\(round + 1)")
                                .font(AppTypography.caption1().bold())
                                .foregroundStyle(.secondary)
                                .frame(width: 50)
                        }
                        
                        Text("Total")
                            .font(AppTypography.caption1().bold())
                            .foregroundStyle(.secondary)
                            .frame(width: 70, alignment: .trailing)
                    }
                    .padding(.horizontal, AppSpacing._4)
                    .padding(.vertical, AppSpacing._3)
                    .background(AppTheme.controlMaterial)
                    
                    // Player rows
                    ForEach(sortedPlayers) { player in
                        Divider().background(Color.white.opacity(0.1))
                        
                        HStack(spacing: 0) {
                            // Player name
                            HStack(spacing: 4) {
                                Text(player.name)
                                    .font(AppTypography.body().bold())
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                
                                if game.winnerId == player.id.uuidString {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.yellow)
                                }
                            }
                            .frame(width: 120, alignment: .leading)
                            
                            // Round scores
                            ForEach(0..<actualRoundCount, id: \.self) { round in
                                let score = round < player.scores.count ? player.scores[round] : 0
                                Text("\(score)")
                                    .font(AppTypography.body())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 50)
                            }
                            
                            // Total score
                            Text("\(player.totalScore)")
                                .font(AppTypography.body().bold())
                                .foregroundStyle(game.winnerId == player.id.uuidString ? AppTheme.positiveColor : .primary)
                                .frame(width: 70, alignment: .trailing)
                        }
                        .padding(.horizontal, AppSpacing._4)
                        .padding(.vertical, AppSpacing._3)
                    }
                }
                .background(AppTheme.cardMaterial)
                .cornerRadius(AppRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
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

// MARK: - Preview

#Preview {
    NavigationStack {
        GameDetailView(
            game: GameRoom(
                id: "ABC123",
                pointLimit: 201,
                pointValue: 10,
                players: [
                    Player(id: UUID(), name: "Alice", isReady: true, isModerator: true, scores: [15, 20, 10, 5, 5, 5, 5, 5, 5, 5, 5]),
                    Player(id: UUID(), name: "Bob", isReady: true, isModerator: false, scores: [25, 30, 20, 10, 10, 10, 10, 10, 10, 10, 10]),
                    Player(id: UUID(), name: "Charlie", isReady: true, isModerator: false, scores: [10, 15, 25, 20, 20, 20, 20, 20, 20, 20, 20])
                ],
                currentRound: 11,
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
