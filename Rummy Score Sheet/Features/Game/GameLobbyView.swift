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
    let onLeave: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing._6) {
                header
                showQRCodeButton
                playersSection
                actionButtons
            }
            .padding(.top, AppSpacing._6)
            .padding(.horizontal, AppSpacing._4)
            .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._6)
        }
        .background(AppTheme.background)
        .sheet(isPresented: $viewModel.isQRCodePresented) {
            QRCodeDisplayView(roomCode: viewModel.room.id)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing._1) {
            Text("Room \(viewModel.room.id)")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
            Text("Target: \(viewModel.room.pointLimit)")
                .font(AppTypography.subheadline())
                .foregroundStyle(.secondary)
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
            .foregroundStyle(.tint)
            .frame(maxWidth: .infinity)
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

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Players (\(viewModel.room.players.count))")
                .font(AppTypography.headline())
                .foregroundStyle(AppTheme.textPrimary)

            GlassEffectContainer(spacing: AppSpacing._3) {
                ForEach(viewModel.room.players) { player in
                    PlayerLobbyRow(
                        player: player,
                        isCurrentUser: player.id == viewModel.currentUserId,
                        onReadyTapped: { viewModel.toggleReady(for: player.id) }
                    )
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: AppSpacing._3) {
            // Start Game Button (Moderator only)
            if viewModel.isModerator {
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
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [AppTheme.primaryColor, AppTheme.primaryColor.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                : AnyShapeStyle(AppTheme.controlMaterial.opacity(0.3)),
                            in: Capsule()
                        )
                        .glassEffect(in: .capsule)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.allPlayersReady)
            }
            
            // Leave Button
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onLeave()
            } label: {
                HStack(spacing: AppSpacing._2) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Leave Lobby")
                        .font(AppTypography.headline())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppComponent.Button.heightLg)
                .background(AppTheme.controlMaterial, in: Capsule())
                .glassEffect(in: .capsule)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct PlayerLobbyRow: View {
    let player: Player
    let isCurrentUser: Bool
    let onReadyTapped: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing._4) {
            avatar
            nameRow
            Spacer()
            readinessControl
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

    private var avatar: some View {
        Circle()
            .fill(AppTheme.primaryColor.opacity(0.3))
            .frame(width: AppComponent.Avatar.sizeMd, height: AppComponent.Avatar.sizeMd)
            .overlay(
                Text(String(player.name.prefix(1)).uppercased())
                    .font(AppTypography.headline())
                    .foregroundStyle(AppTheme.primaryColor)
            )
    }

    private var nameRow: some View {
        HStack(spacing: AppSpacing._1) {
            Text(player.name)
                .font(AppTypography.headline())
                .foregroundStyle(.primary)
            if player.isModerator {
                Text("Host")
                    .font(AppTypography.caption2())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.controlMaterial, in: Capsule())
                    .glassEffect(in: .capsule)
            }
        }
    }

    @ViewBuilder
    private var readinessControl: some View {
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
                            .fill(player.isReady
                                  ? AnyShapeStyle(AppTheme.positiveColor)
                                  : AnyShapeStyle(AppTheme.controlMaterial))
                            .overlay(Capsule().stroke(AppTheme.primaryColor, lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        } else if player.isReady {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.positiveColor)
        } else {
            EmptyView()
        }
    }
}
