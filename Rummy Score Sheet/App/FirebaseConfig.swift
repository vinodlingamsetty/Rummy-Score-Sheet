//
//  FirebaseConfig.swift
//  Rummy Scorekeeper
//
//  Firebase initialization and configuration.
//  Auth is gated by LoginView; no auto sign-in on launch.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseMessaging
import GoogleSignIn

struct FirebaseConfig {
    
    /// Configure Firebase on app launch
    static func configure() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Set FCM delegate (must be set before Messaging receives token)
        Messaging.messaging().delegate = FCMDelegate.shared
        
        // Configure Crashlytics
        configureCrashlytics()
        
        print("✅ Firebase initialized successfully")
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
    
    // MARK: - Sign in with Apple
    
    /// Signs in or links with Apple credential. If user is anonymous, links to preserve data.
    static func signInWithApple(credential: AppleAuthCredential) async throws {
        let oauthCredential = OAuthProvider.appleCredential(
            withIDToken: credential.idToken,
            rawNonce: credential.rawNonce,
            fullName: credential.fullName
        )
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            try await linkWithApple(oauthCredential: oauthCredential, fullName: credential.fullName)
        } else {
            _ = try await Auth.auth().signIn(with: oauthCredential)
            if let fullName = credential.fullName {
                try? await saveAppleDisplayName(fullName)
            }
            Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: "apple"])
            Crashlytics.crashlytics().setUserID(Auth.auth().currentUser?.uid)
        }
    }
    
    /// Links anonymous user to Apple credential (preserves Firestore data).
    private static func linkWithApple(oauthCredential: AuthCredential, fullName: PersonNameComponents?) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseConfig", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        let result = try await user.link(with: oauthCredential)
        if let fullName = fullName {
            try? await saveAppleDisplayName(fullName)
        }
        Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: "apple"])
        Crashlytics.crashlytics().setUserID(result.user.uid)
    }
    
    /// Saves Apple-provided full name to Firebase profile (Apple only sends name on first sign-in).
    private static func saveAppleDisplayName(_ fullName: PersonNameComponents) async throws {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        let name = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
    }
    
    // MARK: - Sign in with Google
    
    /// Signs in or links with Google credential. If user is anonymous, links to preserve data.
    static func signInWithGoogle(idToken: String, accessToken: String, displayName: String?) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            try await linkWithGoogle(credential: credential, displayName: displayName)
        } else {
            _ = try await Auth.auth().signIn(with: credential)
            if let displayName = displayName, !displayName.isEmpty,
               Auth.auth().currentUser?.displayName?.isEmpty ?? true {
                try? await saveGoogleDisplayName(displayName)
            }
            Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: "google"])
            Crashlytics.crashlytics().setUserID(Auth.auth().currentUser?.uid)
        }
    }
    
    /// Links anonymous user to Google credential (preserves Firestore data).
    private static func linkWithGoogle(credential: AuthCredential, displayName: String?) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseConfig", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        let result = try await user.link(with: credential)
        if let displayName = displayName, !displayName.isEmpty,
           result.user.displayName?.isEmpty ?? true {
            try? await saveGoogleDisplayName(displayName)
        }
        Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: "google"])
        Crashlytics.crashlytics().setUserID(result.user.uid)
    }
    
    /// Saves Google-provided display name to Firebase profile (on first sign-in).
    private static func saveGoogleDisplayName(_ name: String) async throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = trimmed
        try await changeRequest.commitChanges()
    }
}
