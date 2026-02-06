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
    
    // Settings
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    var hapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled")
        }
    }
    
    var highContrastMode: Bool {
        didSet {
            UserDefaults.standard.set(highContrastMode, forKey: "highContrastMode")
        }
    }
    
    // Edit state
    var isEditingProfile: Bool = false
    var editedDisplayName: String = ""
    
    // MARK: - Initialization
    
    init() {
        // Load settings from UserDefaults
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.hapticsEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
        self.highContrastMode = UserDefaults.standard.bool(forKey: "highContrastMode")
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
        guard !editedDisplayName.isEmpty else {
            errorMessage = "Display name cannot be empty"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Update Firebase Auth display name
            try await FirebaseConfig.updateDisplayName(editedDisplayName)
            
            // Update local profile
            userProfile?.displayName = editedDisplayName
            
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
