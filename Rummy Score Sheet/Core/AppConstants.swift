//
//  AppConstants.swift
//  Rummy Scorekeeper
//
//  Central constants to avoid magic numbers and string literals.
//  Improves maintainability and reduces risk of typos.
//

import Foundation

enum AppConstants {

    // MARK: - URLs
    enum URLs {
        /// Privacy Policy (GitHub Pages)
        static let privacyPolicy = "https://vinodlingamsetty.github.io/Rummy-Score-Sheet/PRIVACY_POLICY"
    }

    // MARK: - UserDefaults Keys
    // Use these instead of raw strings for settings persistence
    enum UserDefaultsKeys {
        static let notificationsEnabled = "notificationsEnabled"
        static let hapticsEnabled = "hapticsEnabled"
        static let highContrastMode = "highContrastMode"
    }

    // MARK: - Game Setup Bounds
    enum GameSetup {
        static let pointLimitMin = 100
        static let pointLimitMax = 350
        static let pointLimitDefault = 201
        static let pointValueDefault = 10
        static let pointValueMin = 0
        static let pointValueMax = 1000
        static let playerCountMin = 2
        static let playerCountMax = 10
        static let playerCountDefault = 4
    }

    // MARK: - Room Code
    enum RoomCode {
        static let length = 6
        static let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    }

    // MARK: - Score Input
    enum ScoreInput {
        /// Max digits allowed for a single round score (e.g., 999 points)
        static let maxDigits = 3
    }

    // MARK: - Profile
    enum Profile {
        static let displayNameMinLength = 1
        static let displayNameMaxLength = 50
    }

    // MARK: - Timing
    enum Timing {
        /// Delay before auto-advancing to next round after all scores entered (nanoseconds)
        static let autoAdvanceRoundDelay: UInt64 = 500_000_000
    }
}
