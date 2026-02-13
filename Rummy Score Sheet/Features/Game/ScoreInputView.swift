//
//  ScoreInputView.swift
//  Rummy Scorekeeper
//
//  Large numeric keypad for score entry with haptic feedback
//

import SwiftUI

struct ScoreInputView: View {
    let player: Player
    let currentRound: Int
    let onSubmit: (Int) -> Void
    let onCancel: () -> Void
    
    @State private var scoreText = ""
    @FocusState private var isScoreFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    /// Parsed score from input (nil if invalid or empty)
    private var score: Int? {
        Int(scoreText)
    }
    
    /// Submit allowed only when score is valid and non-negative
    private var canSubmit: Bool {
        guard let s = score else { return false }
        return s >= 0
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing._6) {
                // Header
                header
                
                Spacer()

                // Score Display + Entry
                scoreDisplay

                Spacer()
                
                // Action Buttons
                actionButtons
            }
            .padding(AppSpacing._4)
            .padding(.bottom, AppSpacing._4)
            .onAppear {
                // Show the system number pad immediately.
                isScoreFieldFocused = true
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: AppSpacing._2) {
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                    onCancel()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            VStack(spacing: AppSpacing._1) {
                Text("Round \(currentRound)")
                    .font(AppTypography.headline())
                    .foregroundStyle(.secondary)
                
                Text(player.name)
                    .font(AppTypography.largeTitle())
                    .foregroundStyle(.primary)
            }
        }
    }
    
    // MARK: - Score Display
    
    private var scoreDisplay: some View {
        VStack(spacing: AppSpacing._2) {
            TextField("0", text: $scoreText)
                .keyboardType(.numberPad)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primaryColor)
                .multilineTextAlignment(.center)
                .focused($isScoreFieldFocused)
                .onChange(of: scoreText) { _, newValue in
                    let digitsOnly = newValue.filter { $0.isNumber }
                    // Cap at max digits per round (e.g. 999 points)
                    if digitsOnly.count > AppConstants.ScoreInput.maxDigits {
                        scoreText = String(digitsOnly.prefix(AppConstants.ScoreInput.maxDigits))
                    } else if digitsOnly != newValue {
                        scoreText = digitsOnly
                    }
                }
            
            Text("points")
                .font(AppTypography.subheadline())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._6)
        .glassEffect(.regular.tint(AppTheme.primaryColor.opacity(0.25)), in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(AppTheme.primaryColor.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: AppSpacing._3) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
                onCancel()
            } label: {
                Text("Cancel")
                    .font(AppTypography.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing._4)
                    .glassEffect(.regular, in: .capsule)
            }
            .buttonStyle(.plain)
            
            Button {
                if canSubmit, let score = score {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onSubmit(score)
                    dismiss()
                }
            } label: {
                Text("Submit")
                    .font(AppTypography.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing._4)
                    .glassEffect(.regular.tint(AppTheme.primaryColor.opacity(0.25)), in: .capsule)
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
        }
    }
}

// MARK: - Preview

#Preview {
    ScoreInputView(
        player: Player(id: UUID(), name: "Alice", isReady: true, isModerator: true, scores: [15, 20]),
        currentRound: 3,
        onSubmit: { score in
            print("Submitted score: \(score)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}
