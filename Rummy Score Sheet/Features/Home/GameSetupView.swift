//
//  GameSetupView.swift
//  Rummy Scorekeeper
//
//  Host modal — Point limit, value, player count, Create Room
//  All inputs are validated before createRoom is called.
//

import SwiftUI

struct GameSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var gameState: AppGameState
    @State private var pointLimit: Int = AppConstants.GameSetup.pointLimitDefault
    @State private var pointValueText: String = "\(AppConstants.GameSetup.pointValueDefault)"
    @State private var playerCount: Int = AppConstants.GameSetup.playerCountDefault

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
                        // Clamp to valid range (100-350)
                        pointLimit = min(AppConstants.GameSetup.pointLimitMax, max(AppConstants.GameSetup.pointLimitMin, rounded))
                    }
                ), in: Double(AppConstants.GameSetup.pointLimitMin)...Double(AppConstants.GameSetup.pointLimitMax), step: 1)
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
            Text("For fun tracking only; no real money")
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)

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
                        playerCount = min(AppConstants.GameSetup.playerCountMax, max(AppConstants.GameSetup.playerCountMin, rounded))
                    }
                ), in: Double(AppConstants.GameSetup.playerCountMin)...Double(AppConstants.GameSetup.playerCountMax), step: 1)
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
            // Validate point value: clamp to valid range, fallback to default if invalid
            let rawValue = Int(pointValueText) ?? AppConstants.GameSetup.pointValueDefault
            let pointValue = min(AppConstants.GameSetup.pointValueMax, max(AppConstants.GameSetup.pointValueMin, rawValue))
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
