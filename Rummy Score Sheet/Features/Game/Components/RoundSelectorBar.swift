//
//  RoundSelectorBar.swift
//  Rummy Scorekeeper
//
//  Component for navigating between rounds and toggling totals view.
//

import SwiftUI

struct RoundSelectorBar: View {
    let roundCount: Int
    let selectedRound: Int
    let showTotalsView: Bool
    let onSelectRound: (Int) -> Void
    let onToggleTotals: () -> Void
    
    var body: some View {
        HStack(spacing: AppSpacing._3) {
            // Horizontal scroll for rounds
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing._2) {
                    ForEach(1...roundCount, id: \.self) { round in
                        RoundButton(
                            round: round,
                            isSelected: selectedRound == round,
                            action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                onSelectRound(round)
                            }
                        )
                    }
                }
            }
            
            // Totals button
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onToggleTotals()
            } label: {
                Text("T")
                    .font(AppTypography.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(showTotalsView ? AnyShapeStyle(AppTheme.primaryColor) : AnyShapeStyle(AppTheme.controlMaterial))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing._4)
        .padding(.vertical, AppSpacing._2)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.lg))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.lg))
    }
}

// MARK: - Round Button

private struct RoundButton: View {
    let round: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("R\(round)")
                .font(AppTypography.subheadline())
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(minWidth: 44)
                .padding(.horizontal, AppSpacing._2)
                .padding(.vertical, AppSpacing._2)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(AppTheme.primaryColor) : AnyShapeStyle(AppTheme.controlMaterial))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
