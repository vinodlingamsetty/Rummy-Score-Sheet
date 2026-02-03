//
//  DesignSystem.swift
//  Rummy Scorekeeper
//
//  Liquid Glass design system — iOS 26 aesthetic
//  Aligned with figma-design-tokens-export/design-tokens.json
//

import SwiftUI

// MARK: - AppTheme (Colors)

/// Central theme for the app: dark purple radial background, glass materials, neon purple accents
struct AppTheme {

    // MARK: - Background

    /// Figma cosmic gradient — linear, deep space theme (default)
    static let background: LinearGradient = LinearGradient(
        colors: [
            Color(hex: "0a0015"),
            Color(hex: "1a0b2e"),
            Color(hex: "0f0520")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Gradients

    /// Purple gradient for primary actions (#8B5CF6 → #6366F1)
    static let gradientPrimary: LinearGradient = LinearGradient(
        colors: [Color(hex: "8B5CF6"), Color(hex: "6366F1")],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Blue gradient for secondary actions (#3B82F6 → #1D4ED8)
    static let gradientSecondary: LinearGradient = LinearGradient(
        colors: [Color(hex: "3B82F6"), Color(hex: "1D4ED8")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Materials

    /// Ultra-thin glass material for frosted overlays (cards, tab bar, inputs)
    static var glassMaterial: Material { .ultraThin }

    /// Thin material
    static var glassMaterialThin: Material { .thin }

    /// Regular material
    static var glassMaterialRegular: Material { .regular }

    /// Thick material
    static var glassMaterialThick: Material { .thick }
    
    /// Glass card background color — matches Figma rgba(44, 44, 46, 0.75)
    static let glassBackground: Color = Color(hex: "2C2C2E").opacity(0.75)

    // MARK: - Primary Accent

    /// Neon purple — selected tabs, icons, highlights, toggles
    static let primaryColor: Color = Color.neonPurple

    // MARK: - iOS System Colors (Dark Mode)

    static let iosBlue: Color = Color(hex: "0A84FF")
    static let iosPurple: Color = Color(hex: "BF5AF2")
    static let iosIndigo: Color = Color(hex: "5E5CE6")
    static let iosGreen: Color = Color(hex: "30D158")
    static let iosRed: Color = Color(hex: "FF453A")
    static let iosOrange: Color = Color(hex: "FF9F0A")
    static let iosYellow: Color = Color(hex: "FFD60A")
    static let iosPink: Color = Color(hex: "FF375F")
    static let iosTeal: Color = Color(hex: "64D2FF")

    // MARK: - Semantic Colors

    /// Primary text — white for strong contrast on purple
    static let textPrimary: Color = .white

    /// Muted text, placeholders, descriptions
    static let textSecondary: Color = Color.textMuted

    /// Positive / winners / "they owe you" / success
    static let positiveColor: Color = Color.accentGreen

    /// Negative / "you owe" / destructive / logout
    static let destructiveColor: Color = Color.accentRed

    /// Tertiary text (60% opacity)
    static let textTertiary: Color = Color.white.opacity(0.6)

    /// Quaternary text (30% opacity)
    static let textQuaternary: Color = Color.white.opacity(0.3)
}

// MARK: - Theme Colors (Figma design-tokens.json)

private extension Color {
    // Primary accent — iOS purple (vibrant)
    static let neonPurple = Color(hex: "BF5AF2")         // Figma: color.ios.system.purple.dark
    
    // Semantic colors
    static let accentGreen = Color(hex: "30D158")        // Figma: color.semantic.success.dark
    static let accentRed = Color(hex: "FF453A")          // Figma: color.semantic.error.dark
    
    // Text colors
    static let textMuted = Color(hex: "EBEBF5")          // Figma: color.text.secondary.dark
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        case 8:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - AppTypography

/// iOS typography scale — SF Pro Rounded
struct AppTypography {
    static func largeTitle() -> Font { .system(size: 34, weight: .bold, design: .rounded) }
    static func title1() -> Font { .system(size: 28, weight: .bold, design: .rounded) }
    static func title2() -> Font { .system(size: 22, weight: .semibold, design: .rounded) }
    static func title3() -> Font { .system(size: 20, weight: .semibold, design: .rounded) }
    static func headline() -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    static func body() -> Font { .system(size: 17, weight: .regular, design: .rounded) }
    static func callout() -> Font { .system(size: 16, weight: .regular, design: .rounded) }
    static func subheadline() -> Font { .system(size: 15, weight: .regular, design: .rounded) }
    static func footnote() -> Font { .system(size: 13, weight: .regular, design: .rounded) }
    static func caption1() -> Font { .system(size: 12, weight: .regular, design: .rounded) }
    static func caption2() -> Font { .system(size: 11, weight: .regular, design: .rounded) }
}

// MARK: - AppSpacing (8pt grid)

struct AppSpacing {
    static let _0: CGFloat = 0
    static let _1: CGFloat = 4
    static let _2: CGFloat = 8
    static let _3: CGFloat = 12
    static let _4: CGFloat = 16
    static let _5: CGFloat = 20
    static let _6: CGFloat = 24
    static let _8: CGFloat = 32
    static let _10: CGFloat = 40
    static let _12: CGFloat = 48
    static let _16: CGFloat = 64
    static let _20: CGFloat = 80
    static let _24: CGFloat = 96

    static let tight: CGFloat = _2
    static let small: CGFloat = _3
    static let medium: CGFloat = _4
    static let large: CGFloat = _6
    static let xLarge: CGFloat = _8
}

// MARK: - AppRadius

struct AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 9999

    static let iosDefault: CGFloat = 10
    static let iosLarge: CGFloat = 14
    static let iosCard: CGFloat = 16
}

// MARK: - AppAnimation

struct AppAnimation {
    /// Bouncy — tab switches, modals (stiffness 400, damping 25)
    static var springBouncy: Animation { .spring(response: 0.35, dampingFraction: 0.65) }

    /// Smooth — general interactions (stiffness 300, damping 30)
    static var springSmooth: Animation { .spring(response: 0.4, dampingFraction: 0.75) }

    /// Snappy — quick feedback (stiffness 500, damping 30)
    static var springSnappy: Animation { .spring(response: 0.28, dampingFraction: 0.7) }

    static let durationFast: Double = 0.15
    static let durationNormal: Double = 0.3
    static let durationSlow: Double = 0.5
}

// MARK: - AppComponent (Component tokens)

struct AppComponent {
    struct Button {
        static let heightSm: CGFloat = 32
        static let heightMd: CGFloat = 44
        static let heightLg: CGFloat = 50
        static let paddingX: CGFloat = 16
        static let paddingY: CGFloat = 12
    }
    struct Input {
        static let height: CGFloat = 44
        static let paddingX: CGFloat = 16
        static let paddingY: CGFloat = 12
    }
    struct Card {
        static let padding: CGFloat = 16
        static let gap: CGFloat = 12
    }
    struct Avatar {
        static let sizeSm: CGFloat = 32
        static let sizeMd: CGFloat = 40
        static let sizeLg: CGFloat = 56
        static let sizeXl: CGFloat = 80
    }
    struct Layout {
        static let statusBarHeight: CGFloat = 44
        static let tabBarHeight: CGFloat = 80
        static let navBarHeight: CGFloat = 44
        static let maxContentWidth: CGFloat = 896
    }
}
