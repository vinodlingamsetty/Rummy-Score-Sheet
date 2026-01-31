//
//  GameSetupView.swift
//  Rummy Scorekeeper
//
//  Host modal — Point limit, value, player count, Create Room
//

import SwiftUI

struct GameSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pointLimit: Int = 500
    @State private var pointValueText: String = "10"
    @State private var playerCount: Int = 4

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                header
                controlPanel
                Spacer(minLength: 0)
            }
            .padding(.top, 24)

            VStack {
                Spacer()
                createRoomButton
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Create Room")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Set your game parameters")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var controlPanel: some View {
        VStack(spacing: 24) {
            pointLimitSelector
            pointValueInput
            playerCountControl
        }
        .padding(.horizontal, 24)
    }

    private var pointLimitSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Point Limit")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 16) {
                Text("\(pointLimit)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
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
            .padding(20)
            .background(AppTheme.glassMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var pointValueInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Point Value ($)")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            TextField("10", text: $pointValueText)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryColor)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .padding(20)
                .background(AppTheme.glassMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var playerCountControl: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Players")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 16) {
                Text("\(playerCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryColor)
                    .frame(minWidth: 44, alignment: .center)

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
            .padding(20)
            .background(AppTheme.glassMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var createRoomButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            dismiss()
        } label: {
            Text("Create Room")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
    }
}

#Preview {
    GameSetupView()
}
