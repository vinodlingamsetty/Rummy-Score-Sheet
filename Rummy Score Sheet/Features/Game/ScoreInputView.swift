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
    @Environment(\.dismiss) private var dismiss
    
    private var score: Int? {
        Int(scoreText)
    }
    
    private var canSubmit: Bool {
        score != nil && score! >= 0
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing._6) {
                // Header
                header
                
                Spacer()
                
                // Score Display
                scoreDisplay
                
                Spacer()
                
                // Numeric Keypad
                numericKeypad
                
                // Action Buttons
                actionButtons
            }
            .padding(AppSpacing._4)
            .padding(.bottom, AppSpacing._4)
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
            Text(scoreText.isEmpty ? "0" : scoreText)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primaryColor)
                .contentTransition(.numericText())
            
            Text("points")
                .font(AppTypography.subheadline())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._6)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(AppTheme.primaryColor.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Numeric Keypad
    
    private var numericKeypad: some View {
        VStack(spacing: AppSpacing._3) {
            // Row 1: 7, 8, 9
            HStack(spacing: AppSpacing._3) {
                NumberButton(number: "7", action: appendDigit)
                NumberButton(number: "8", action: appendDigit)
                NumberButton(number: "9", action: appendDigit)
            }
            
            // Row 2: 4, 5, 6
            HStack(spacing: AppSpacing._3) {
                NumberButton(number: "4", action: appendDigit)
                NumberButton(number: "5", action: appendDigit)
                NumberButton(number: "6", action: appendDigit)
            }
            
            // Row 3: 1, 2, 3
            HStack(spacing: AppSpacing._3) {
                NumberButton(number: "1", action: appendDigit)
                NumberButton(number: "2", action: appendDigit)
                NumberButton(number: "3", action: appendDigit)
            }
            
            // Row 4: 0, Delete
            HStack(spacing: AppSpacing._3) {
                // Empty spacer
                Color.clear
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                
                NumberButton(number: "0", action: appendDigit)
                
                DeleteButton(action: deleteDigit)
            }
        }
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
                    .background(AppTheme.controlMaterial, in: Capsule())
                    .glassEffect(in: .capsule)
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
                    .background(
                        canSubmit ?
                        AnyShapeStyle(
                            LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.primaryColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ) :
                        AnyShapeStyle(AppTheme.controlMaterial),
                        in: Capsule()
                    )
                    .glassEffect(in: .capsule)
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
        }
    }
    
    // MARK: - Actions
    
    private func appendDigit(_ digit: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Limit to 3 digits
        guard scoreText.count < 3 else { return }
        
        scoreText += digit
    }
    
    private func deleteDigit() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard !scoreText.isEmpty else { return }
        scoreText.removeLast()
    }
}

// MARK: - Number Button

private struct NumberButton: View {
    let number: String
    let action: (String) -> Void
    
    var body: some View {
        Button {
            action(number)
        } label: {
            Text(number)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Delete Button

private struct DeleteButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "delete.left.fill")
                .font(.system(size: 24))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
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
