//
//  PlayerScoreCard.swift
//  Rummy Scorekeeper
//
//  Component for displaying a player's status and score in the active game.
//

import SwiftUI

struct PlayerScoreCard: View {
    let player: Player
    let scoreDisplay: String
    let isEliminated: Bool
    let isLeader: Bool
    let isModerator: Bool
    let isTotal: Bool
    let hasScore: Bool
    let pointLimit: Int
    let onTapScore: () -> Void
    
    private var remainingPoints: Int {
        max(0, pointLimit - player.totalScore)
    }
    
    // Computed colors to avoid complex ternary expressions
    private var scoreColor: Color {
        if isEliminated { return .secondary }
        if isTotal { return AppTheme.positiveColor }
        if hasScore { return .primary }
        return .secondary.opacity(0.5)
    }
    
    private var scoreBorderColor: Color {
        if isTotal { return AppTheme.positiveColor.opacity(0.5) }
        if hasScore { return Color.white.opacity(0.2) }
        return Color.white.opacity(0.1)
    }
    
    var body: some View {
        HStack(spacing: AppSpacing._4) {
            // Avatar
            Circle()
                .fill(isEliminated ? AppTheme.destructiveColor.opacity(0.3) : AppTheme.primaryColor.opacity(0.3))
                .frame(width: AppComponent.Avatar.sizeLg, height: AppComponent.Avatar.sizeLg)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(AppTypography.title3())
                        .foregroundStyle(isEliminated ? AppTheme.destructiveColor : AppTheme.primaryColor)
                )
            
            // Player Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing._2) {
                    Text(player.name)
                        .font(AppTypography.headline())
                        .foregroundStyle(isEliminated ? .secondary : .primary)
                    
                    if isLeader {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.yellow)
                    }
                    if isModerator {
                        Image(systemName: "person.badge.key.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.primaryColor)
                    }
                    
                    if isEliminated {
                        Text("ELIMINATED")
                            .font(AppTypography.caption2())
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing._2)
                            .padding(.vertical, 2)
                            .background(AppTheme.destructiveColor, in: Capsule())
                    }
                }
                
                Text(isTotal ? "Running Total" : "Total: \(player.totalScore)")
                    .font(AppTypography.footnote())
                    .foregroundStyle(.secondary)
                
                if !isEliminated {
                    Text("Remaining: \(remainingPoints)")
                        .font(AppTypography.caption2())
                        .foregroundStyle(.secondary.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Score Display (Tappable if not total mode)
            Button(action: onTapScore) {
                Text(scoreDisplay)
                    .font(AppTypography.title2())
                    .foregroundStyle(scoreColor)
                    .frame(minWidth: 60)
                    .padding(.vertical, AppSpacing._2)
                    .padding(.horizontal, AppSpacing._3)
                    .background(
                        hasScore ? AnyShapeStyle(AppTheme.controlMaterial) : AnyShapeStyle(AppTheme.controlMaterial.opacity(0.5)),
                        in: RoundedRectangle(cornerRadius: AppRadius.md)
                    )
                    .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(scoreBorderColor, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(isEliminated || isTotal)
        }
        .padding(AppComponent.Card.padding)
        .background(
            isEliminated ? AnyShapeStyle(AppTheme.destructiveColor.opacity(0.1)) : AnyShapeStyle(AppTheme.cardMaterial),
            in: RoundedRectangle(cornerRadius: AppRadius.iosCard)
        )
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(isEliminated ? AppTheme.destructiveColor.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
        )
        .opacity(isEliminated ? 0.6 : 1)
    }
}
