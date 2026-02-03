//
//  GameView.swift
//  Rummy Scorekeeper
//
//  Active game screen — rounds, player scores, Add Scores, Edit
//

import SwiftUI

struct GameView: View {
    @Bindable var viewModel: GameViewModel
    let onEndGame: () -> Void
    let onLeaveGame: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing._6) {
                    header
                    roundSelector
                    playerCards
                    actionButtons
                }
                .padding(.top, AppSpacing._4)
                .padding(.horizontal, AppSpacing._4)
                .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._6)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Room \(viewModel.room.id)")
                    .font(AppTypography.headline())
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Target: \(viewModel.room.pointLimit)")
                    .font(AppTypography.footnote())
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onEndGame()
            } label: {
                Text("End Game")
                    .font(AppTypography.subheadline())
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing._4)
                    .padding(.vertical, AppSpacing._2)
                    .background(AppTheme.destructiveColor, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var roundSelector: some View {
        VStack(spacing: AppSpacing._2) {
            HStack(spacing: AppSpacing._2) {
                ForEach(1...viewModel.roundCount, id: \.self) { round in
                    let isSelected = viewModel.room.currentRound == round
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        viewModel.selectRound(round)
                    } label: {
                        Text("R\(round)")
                            .font(AppTypography.subheadline())
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(minWidth: 44)
                            .padding(.vertical, AppSpacing._2)
                            .background(
                                Capsule()
                                    .fill(isSelected ? AppTheme.primaryColor : Color.clear)
                                    .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                    Capsule()
                        .fill(AppTheme.positiveColor)
                        .frame(width: geo.size.width * CGFloat(viewModel.room.currentRound) / CGFloat(viewModel.roundCount), height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    private var playerCards: some View {
        VStack(spacing: AppSpacing._3) {
            ForEach(viewModel.sortedPlayers) { player in
                PlayerScoreCard(
                    player: player,
                    roundScore: viewModel.score(for: player.id, round: viewModel.room.currentRound - 1)
                )
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: AppSpacing._3) {
            HStack(spacing: AppSpacing._3) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    // TODO: Edit scores
                } label: {
                    HStack(spacing: AppSpacing._2) {
                        Image(systemName: "pencil")
                        Text("Edit")
                            .font(AppTypography.headline())
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing._4)
                    .background(AppTheme.glassBackground, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    // TODO: Add scores sheet
                } label: {
                    Text("Add Scores")
                        .font(AppTypography.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing._4)
                        .background(AppTheme.gradientPrimary, in: Capsule())
                }
                .buttonStyle(.plain)
            }

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onLeaveGame()
            } label: {
                HStack(spacing: AppSpacing._2) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Leave Game")
                        .font(AppTypography.headline())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing._4)
                .background(AppTheme.destructiveColor.opacity(0.8), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

private struct PlayerScoreCard: View {
    let player: Player
    let roundScore: Int

    var body: some View {
        HStack(spacing: AppSpacing._4) {
            Circle()
                .fill(AppTheme.primaryColor.opacity(0.3))
                .frame(width: AppComponent.Avatar.sizeLg, height: AppComponent.Avatar.sizeLg)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(AppTypography.title3())
                        .foregroundStyle(AppTheme.primaryColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(AppTypography.headline())
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Total: \(player.totalScore)")
                    .font(AppTypography.footnote())
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Text("\(roundScore)")
                .font(AppTypography.title2())
                .foregroundStyle(.white)
                .frame(minWidth: 48)
                .padding(.vertical, AppSpacing._2)
                .background(AppTheme.glassBackground, in: RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .padding(AppComponent.Card.padding)
        .background(AppTheme.glassBackground, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
