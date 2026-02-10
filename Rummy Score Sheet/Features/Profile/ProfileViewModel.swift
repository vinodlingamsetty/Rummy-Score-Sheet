//
//  ProfileViewModel.swift
//  Rummy Scorekeeper
//
//  ViewModel for Profile screen
//

import SwiftUI
import FirebaseAuth

@Observable
class ProfileViewModel {
    
    // MARK: - State
    
    var userProfile: UserProfile?
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Settings (persisted via UserDefaults)
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: AppConstants.UserDefaultsKeys.notificationsEnabled)
        }
    }
    
    var hapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticsEnabled, forKey: AppConstants.UserDefaultsKeys.hapticsEnabled)
        }
    }
    
    var highContrastMode: Bool {
        didSet {
            UserDefaults.standard.set(highContrastMode, forKey: AppConstants.UserDefaultsKeys.highContrastMode)
        }
    }
    
    // Edit state
    var isEditingProfile: Bool = false
    var editedDisplayName: String = ""
    
    /// True when user is signed in anonymously (Guest)
    var isAnonymous: Bool {
        Auth.auth().currentUser?.isAnonymous ?? true
    }
    
    // MARK: - Initialization
    
    init() {
        // Load settings from UserDefaults (false if never set)
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.notificationsEnabled)
        self.hapticsEnabled = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.hapticsEnabled)
        self.highContrastMode = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.highContrastMode)
    }
    
    // MARK: - User Profile
    
    @MainActor
    func loadUserProfile() async {
        isLoading = true
        errorMessage = nil
        
        // Get current Firebase user
        guard let currentUser = Auth.auth().currentUser else {
            // Use mock data for development
            userProfile = UserProfile.mock
            isLoading = false
            return
        }
        
        // Create profile from Firebase Auth
        let displayName = await FirebaseConfig.getUserDisplayName()
        
        userProfile = UserProfile(
            userId: currentUser.uid,
            displayName: displayName,
            email: currentUser.email,
            phoneNumber: currentUser.phoneNumber
        )
        
        // TODO: Load game statistics from Firestore
        // For now, use default values (0)
        
        isLoading = false
    }
    
    @MainActor
    func updateDisplayName() async {
        // Validate: trim whitespace and enforce length limits
        let trimmed = editedDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= AppConstants.Profile.displayNameMinLength else {
            errorMessage = "Display name cannot be empty"
            return
        }
        let validated = String(trimmed.prefix(AppConstants.Profile.displayNameMaxLength))
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Update Firebase Auth display name (validated length/trim applied)
            try await FirebaseConfig.updateDisplayName(validated)
            
            // Update local profile
            userProfile?.displayName = validated
            
            // Close edit mode
            isEditingProfile = false
            
            // Haptic feedback
            if hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } catch {
            errorMessage = "Failed to update name: \(error.localizedDescription)"
            if hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
        
        isLoading = false
    }
    
    /// Completes Sign in with Apple using credential from SignInWithAppleButton's onCompletion.
    @MainActor
    func completeSignInWithApple(credential: AppleAuthCredential) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await FirebaseConfig.signInWithApple(credential: credential)
            await loadUserProfile()
            if hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } catch let error as NSError {
            if error.domain == AuthErrorDomain, error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                errorMessage = "This Apple ID is already used with another account"
            } else {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
            if hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            if hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func logout() async {
        isLoading = true
        
        do {
            try Auth.auth().signOut()
            
            // Haptic feedback
            if hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
            // Clear user profile
            userProfile = nil
        } catch {
            errorMessage = "Failed to logout: \(error.localizedDescription)"
            if hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Haptic Helpers
    
    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
