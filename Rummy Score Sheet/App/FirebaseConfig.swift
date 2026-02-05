//
//  FirebaseConfig.swift
//  Rummy Scorekeeper
//
//  Firebase initialization and configuration
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
    
    /// Ensure user is authenticated (await this before any operations)
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
    
    /// Log analytics event
    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
