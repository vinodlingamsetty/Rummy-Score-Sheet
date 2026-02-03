//
//  GameLobbyView.swift
//  Rummy Scorekeeper
//
//  Pre-game lobby for moderator and players — Show QR, ready states, Start Game
//

import SwiftUI

struct GameLobbyView: View {
    @Bindable var viewModel: GameLobbyViewModel
    let onStartGame: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing._6) {
                    header
                    showQRCodeButton
                    playersSection
                    startGameButton
                }
                .padding(.top, AppSpacing._6)
                .padding(.horizontal, AppSpacing._4)
                .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._6)
            }
        }
        .sheet(isPresented: $viewModel.isQRCodePresented) {
            QRCodeDisplayView(roomCode: viewModel.room.id)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing._1) {
            Text("Room \(viewModel.room.id)")
                .font(AppTypography.title2())
                .foregroundStyle(AppTheme.textPrimary)
            Text("Target: \(viewModel.room.pointLimit)")
                .font(AppTypography.subheadline())
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var showQRCodeButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            viewModel.isQRCodePresented = true
        } label: {
            HStack(spacing: AppSpacing._2) {
                Image(systemName: "qrcode")
                    .font(.system(size: 20, weight: .medium))
                Text("Show QR Code")
                    .font(AppTypography.headline())
            }
            .foregroundStyle(AppTheme.primaryColor)
            .frame(maxWidth: .infinity)
            .padding(AppComponent.Card.padding)
            .background(AppTheme.glassBackground, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.iosCard)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Players (\(viewModel.room.players.count))")
                .font(AppTypography.headline())
                .foregroundStyle(AppTheme.textPrimary)

            ForEach(viewModel.room.players) { player in
                PlayerLobbyRow(
                    player: player,
                    isCurrentUser: player.id == viewModel.currentUserId,
                    onReadyTapped: { viewModel.toggleReady(for: player.id) }
                )
            }
        }
    }

    private var startGameButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onStartGame()
        } label: {
            Text("Start Game")
                .font(AppTypography.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppComponent.Button.heightLg)
                .background(
                    viewModel.allPlayersReady
                        ? AnyShapeStyle(AppTheme.gradientPrimary)
                        : AnyShapeStyle(AppTheme.glassBackground),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.allPlayersReady)
    }
}

private struct PlayerLobbyRow: View {
    let player: Player
    let isCurrentUser: Bool
    let onReadyTapped: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing._4) {
            Circle()
                .fill(AppTheme.primaryColor.opacity(0.3))
                .frame(width: AppComponent.Avatar.sizeMd, height: AppComponent.Avatar.sizeMd)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(AppTypography.headline())
                        .foregroundStyle(AppTheme.primaryColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing._1) {
                    Text(player.name)
                        .font(AppTypography.headline())
                        .foregroundStyle(AppTheme.textPrimary)
                    if player.isModerator {
                        Text("Host")
                            .font(AppTypography.caption2())
                            .foregroundStyle(AppTheme.textTertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(AppTheme.glassBackground))
                    }
                }
            }

            Spacer()

            if isCurrentUser && !player.isModerator {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onReadyTapped()
                } label: {
                    Text(player.isReady ? "Ready" : "Ready?")
                        .font(AppTypography.subheadline())
                        .fontWeight(.semibold)
                        .foregroundStyle(player.isReady ? .white : AppTheme.primaryColor)
                        .padding(.horizontal, AppSpacing._4)
                        .padding(.vertical, AppSpacing._2)
                        .background(
                            Capsule()
                                .fill(player.isReady ? AppTheme.positiveColor : Color.clear)
                                .overlay(Capsule().stroke(AppTheme.primaryColor, lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
            } else if player.isReady {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.positiveColor)
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
