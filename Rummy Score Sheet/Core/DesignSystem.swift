//
//  DesignSystem.swift
//  Rummy Scorekeeper
//
//  Liquid Glass design system — dark mode, premium aesthetics
//

import SwiftUI

/// Central theme for the app: dark radial background, glass materials, neon accents
struct AppTheme {
    
    // MARK: - Background
    
    /// Radial gradient from dark blue to black (Liquid Glass foundation)
    static let background: RadialGradient = RadialGradient(
        colors: [Color.darkBlue, Color.black],
        center: .center,
        startRadius: 0,
        endRadius: 600
    )
    
    // MARK: - Materials
    
    /// Ultra-thin glass material for frosted overlays
    static var glassMaterial: Material { .ultraThin }
    
    // MARK: - Colors
    
    /// Primary neon blue accent
    static let primaryColor: Color = Color.neonBlue
}

// MARK: - Theme Colors

private extension Color {
    static let darkBlue = Color(red: 0.05, green: 0.08, blue: 0.18)
    static let neonBlue = Color(red: 0.0, green: 0.75, blue: 1.0)
}
