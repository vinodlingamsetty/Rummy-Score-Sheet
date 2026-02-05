//
//  GameSetupView.swift
//  Rummy Scorekeeper
//
//  Host modal — Point limit, value, player count, Create Room
//

import SwiftUI

struct GameSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var gameState: AppGameState
    @State private var pointLimit: Int = 500
    @State private var pointValueText: String = "10"
    @State private var playerCount: Int = 4

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing._8) {
                header
                controlPanel
                Spacer(minLength: 0)
            }
            .padding(.top, AppSpacing._6)

            VStack {
                Spacer()
                createRoomButton
            }
        }
    }

    private var header: some View {
        VStack(spacing: AppSpacing._2) {
            Text("Create Room")
                .font(AppTypography.title1())
                .foregroundStyle(.primary)
            Text("Set your game parameters")
                .font(AppTypography.subheadline())
                .foregroundStyle(.secondary)
        }
    }

    private var controlPanel: some View {
        VStack(spacing: AppSpacing._6) {
            pointLimitSelector
            pointValueInput
            playerCountControl
        }
        .padding(.horizontal, AppSpacing._6)
    }

    private var pointLimitSelector: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Point Limit")
                .font(AppTypography.headline())
                .foregroundStyle(.primary)

            HStack(spacing: AppSpacing._4) {
                Text("\(pointLimit)")
                    .font(AppTypography.title1())
                    .foregroundStyle(AppTheme.primaryColor)
                    .frame(minWidth: 52, alignment: .center)

                Slider(value: Binding(
                    get: { Double(pointLimit) },
                    set: { newValue in
                        let rounded = Int(newValue.rounded())
                        if rounded != pointLimit {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        pointLimit = min(900, max(100, rounded))
                    }
                ), in: 100...900, step: 1)
                .tint(AppTheme.primaryColor)
            }
            .padding(AppSpacing._5)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        }
    }

    private var pointValueInput: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Point Value ($)")
                .font(AppTypography.headline())
                .foregroundStyle(.primary)

            TextField("10", text: $pointValueText)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryColor)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .padding(AppSpacing._5)
                .background(AppTheme.controlMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosDefault))
                .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosDefault))
        }
    }

    private var playerCountControl: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Players")
                .font(AppTypography.headline())
                .foregroundStyle(.primary)

            HStack(spacing: AppSpacing._4) {
                Text("\(playerCount)")
                    .font(AppTypography.title1())
                    .foregroundStyle(AppTheme.primaryColor)
                    .frame(minWidth: AppComponent.Avatar.sizeMd, alignment: .center)

                Slider(value: Binding(
                    get: { Double(playerCount) },
                    set: { newValue in
                        let rounded = Int(newValue.rounded())
                        if rounded != playerCount {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        playerCount = min(10, max(2, rounded))
                    }
                ), in: 2...10, step: 1)
                .tint(AppTheme.primaryColor)
            }
            .padding(AppSpacing._5)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        }
    }

    private var createRoomButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            let pointValue = Int(pointValueText) ?? 10
            gameState.createRoom(pointLimit: pointLimit, pointValue: pointValue, playerCount: playerCount)
            dismiss()
        } label: {
            Text("Create Room")
                .font(AppTypography.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppComponent.Button.heightLg)
                .background(AppTheme.controlMaterial, in: Capsule())
                .glassEffect(in: .capsule)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing._6)
        .padding(.bottom, AppSpacing._6 + 10)
    }
}

#Preview {
    GameSetupView(gameState: AppGameState(roomService: MockRoomService(), friendService: MockFriendService()))
}
