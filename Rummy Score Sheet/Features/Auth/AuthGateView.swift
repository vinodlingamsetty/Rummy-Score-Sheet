//
//  AuthGateView.swift
//  Rummy Scorekeeper
//
//  Root view that gates content behind authentication.
//  Shows LoginView when signed out, MainTabView when signed in.
//

import SwiftUI
import FirebaseAuth

@Observable
final class AuthStateObserver {
    var isSignedIn: Bool = false
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isSignedIn = user != nil
        }
    }
    
    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

struct AuthGateView: View {
    @State private var authState = AuthStateObserver()
    let gameState: AppGameState
    let friendService: FriendService
    
    var body: some View {
        Group {
            if authState.isSignedIn {
                MainTabView(gameState: gameState, friendService: friendService)
            } else {
                LoginView()
            }
        }
    }
}
