//
//  FCMService.swift
//  Rummy Scorekeeper
//
//  Handles FCM token registration, permission requests, and persisting tokens to Firestore.
//

import Foundation
import FirebaseMessaging
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

@MainActor
final class FCMDelegate: NSObject, MessagingDelegate {
    
    static let shared = FCMDelegate()
    
    private let usersCollection = AppConstants.Firestore.users
    private let db = Firestore.firestore()
    
    private override init() {
        super.init()
    }
    
    // MARK: - MessagingDelegate
    
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task { @MainActor in
            await saveTokenToFirestore(fcmToken)
        }
    }
    
    // MARK: - Token Persistence
    
    func saveTokenToFirestore(_ fcmToken: String?) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let notificationsEnabled = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.notificationsEnabled)
        
        var data: [String: Any] = [
            "notificationsEnabled": notificationsEnabled,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let token = fcmToken, !token.isEmpty, notificationsEnabled {
            data["fcmToken"] = token
        } else {
            data["fcmToken"] = FieldValue.delete()
        }
        
        do {
            try await db.collection(usersCollection).document(userId).setData(data, merge: true)
        } catch {
            #if DEBUG
            print("❌ Failed to save FCM token to Firestore: \(error.localizedDescription)")
            #endif
        }
    }
    
    // MARK: - Permission & Registration
    
    /// Request notification permission and register for remote notifications.
    /// Call when user enables Notifications in Profile.
    static func requestPermissionAndRegister() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                await shared.saveTokenToFirestore(Messaging.messaging().fcmToken)
                return true
            }
            return false
        } catch {
            #if DEBUG
            print("❌ Notification permission error: \(error.localizedDescription)")
            #endif
            return false
        }
    }
    
    /// Update Firestore with current notifications preference. Call when user toggles the setting.
    /// When disabled, clears fcmToken so nudges are not sent.
    static func updateNotificationsPreference() async {
        await shared.saveTokenToFirestore(Messaging.messaging().fcmToken)
    }
}
