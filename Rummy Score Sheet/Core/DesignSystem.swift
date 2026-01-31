//
//  DesignSystem.swift
//  Rummy Scorekeeper
//
//  Liquid Glass design system — dark mode, purple-centric premium aesthetics
//

import SwiftUI

/// Central theme for the app: dark purple radial background, glass materials, neon purple accents
struct AppTheme {

    // MARK: - Background

    /// Radial gradient from rich dark purple (center) to deep purple-black (edges)
    static let background: RadialGradient = RadialGradient(
        colors: [Color.backgroundCenter, Color.backgroundEdge],
        center: .center,
        startRadius: 0,
        endRadius: 600
    )

    // MARK: - Materials

    /// Ultra-thin glass material for frosted overlays (cards, tab bar, inputs)
    static var glassMaterial: Material { .ultraThin }

    // MARK: - Primary Accent

    /// Neon purple — selected tabs, icons, highlights, toggles
    static let primaryColor: Color = Color.neonPurple

    // MARK: - Semantic Colors

    /// Primary text — white for strong contrast on purple
    static let textPrimary: Color = .white

    /// Muted text, placeholders, descriptions
    static let textSecondary: Color = Color.textMuted

    /// Positive / winners / "they owe you" / success
    static let positiveColor: Color = Color.accentGreen

    /// Negative / "you owe" / destructive / logout
    static let destructiveColor: Color = Color.accentRed
}

// MARK: - Theme Colors

private extension Color {
    static let backgroundCenter = Color(red: 0.29, green: 0.18, blue: 0.48)   // #4A2E7A
    static let backgroundEdge = Color(red: 0.10, green: 0.10, blue: 0.18)     // #1A1A2E
    static let neonPurple = Color(red: 0.70, green: 0.57, blue: 0.94)         // #B392F0
    static let accentGreen = Color(red: 0.40, green: 0.85, blue: 0.50)        // ~#66D980
    static let accentRed = Color(red: 1.0, green: 0.25, blue: 0.51)           // #FF4081
    static let textMuted = Color(red: 0.80, green: 0.78, blue: 0.85)          // light gray, high contrast on purple
}
