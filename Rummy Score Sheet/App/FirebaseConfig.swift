//
//  FirebaseConfig.swift
//  Rummy Scorekeeper
//
//  Firebase initialization and configuration.
//  Uses Anonymous Auth for quick start; no user credentials stored locally.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import FirebaseCrashlytics

struct FirebaseConfig {
    
    /// Configure Firebase on app launch
    static func configure() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Setup Anonymous Authentication
        setupAnonymousAuth()
        
        // Configure Crashlytics
        configureCrashlytics()
        
        print("✅ Firebase initialized successfully")
    }
    
    // MARK: - Anonymous Authentication
    
    private static func setupAnonymousAuth() {
        Task {
            await ensureAuthenticated()
        }
    }
    
    /// Ensures user is authenticated. Call before Firestore/Auth operations.
    /// Signs in anonymously if not already authenticated.
    static func ensureAuthenticated() async {
        if Auth.auth().currentUser == nil {
            do {
                let result = try await Auth.auth().signInAnonymously()
                print("✅ Anonymous auth successful: \(result.user.uid)")
                Analytics.logEvent(AnalyticsEventLogin, parameters: [
                    AnalyticsParameterMethod: "anonymous"
                ])
                Crashlytics.crashlytics().setUserID(result.user.uid)
            } catch {
                print("❌ Anonymous auth failed: \(error.localizedDescription)")
                Crashlytics.crashlytics().record(error: error)
            }
        } else {
            print("✅ User already authenticated: \(Auth.auth().currentUser?.uid ?? "unknown")")
        }
    }
    
    // MARK: - Crashlytics
    
    private static func configureCrashlytics() {
        // Set user identifier for crash reports
        if let userId = Auth.auth().currentUser?.uid {
            Crashlytics.crashlytics().setUserID(userId)
        }
        
        #if DEBUG
        // Disable Crashlytics in debug mode (optional)
        // Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #endif
    }
    
    // MARK: - Helpers
    
    /// Get current authenticated user ID
    static func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// Get current user's display name (or generate guest name)
    static func getUserDisplayName() -> String {
        if let user = Auth.auth().currentUser {
            // Check if user has a display name set
            if let displayName = user.displayName, !displayName.isEmpty {
                return displayName
            }
            
            // For anonymous users, generate a guest name
            let suffix = String(user.uid.suffix(4)).uppercased()
            return "Guest \(suffix)"
        }
        
        return "Guest"
    }
    
    /// Updates the current user's display name in Firebase Auth.
    /// Caller must validate/sanitize name (length, trim) before calling.
    static func updateDisplayName(_ name: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseConfig", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "No authenticated user"
            ])
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        
        print("✅ Display name updated to: \(name)")
        Analytics.logEvent("profile_updated", parameters: ["field": "display_name"])
    }
    
    /// Log analytics event
    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
