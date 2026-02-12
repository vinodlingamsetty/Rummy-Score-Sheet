//
//  GameHistoryCard.swift
//  Rummy Scorekeeper
//
//  Reusable card for displaying a past game in a list
//

import SwiftUI

struct GameHistoryCard: View {
    let game: GameRoom
    
    private var currentUserId: String? {
        FirebaseConfig.getCurrentUserId()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            // Top row: Game code + Point value
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing._1) {
                    Text("#\(game.id)")
                        .font(AppTypography.headline())
                        .foregroundStyle(AppTheme.primaryColor)
                    if let endedAt = game.endedAt {
                        Text(endedAt, format: .dateTime.year().month().day().hour().minute())
                            .font(AppTypography.footnote())
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppSpacing._1) {
                    Text("$\(game.pointValue)")
                        .font(AppTypography.headline())
                        .foregroundStyle(.primary)
                    if let winner = game.winner {
                        Text(winner.name)
                            .font(AppTypography.footnote())
                            .foregroundStyle(AppTheme.positiveColor)
                    } else {
                        Text("No winner")
                            .font(AppTypography.footnote())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Player chips row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing._2) {
                    ForEach(game.players) { player in
                        PlayerChip(
                            name: player.name,
                            isHighlighted: game.createdBy == currentUserId || game.winnerId == player.id.uuidString
                        )
                    }
                }
            }
        }
        .padding(AppComponent.Card.padding)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PlayerChip: View {
    let name: String
    let isHighlighted: Bool
    
    var body: some View {
        Text(name)
            .font(AppTypography.caption1())
            .foregroundStyle(.primary)
            .padding(.horizontal, AppSpacing._3)
            .padding(.vertical, AppSpacing._1 + 2)
            .background(
                Capsule()
                    .fill(isHighlighted ? AnyShapeStyle(AppTheme.iosBlue) : AnyShapeStyle(AppTheme.controlMaterial))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(isHighlighted ? 0 : 0.1), lineWidth: 1)
            )
    }
}
