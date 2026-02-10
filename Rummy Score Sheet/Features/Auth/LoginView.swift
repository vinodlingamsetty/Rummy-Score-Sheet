//
//  LoginView.swift
//  Rummy Scorekeeper
//
//  Login screen with Sign in with Apple, Google, and Anonymous options.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import FirebaseAnalytics
import FirebaseCrashlytics

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var appleSignInNonce: String?
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppSpacing._8) {
                    Spacer(minLength: AppSpacing._12)
                    
                    // Logo / Title
                    VStack(spacing: AppSpacing._3) {
                        Image(systemName: "playingcards.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(AppTheme.primaryColor)
                        
                        Text("Rummy Scorekeeper")
                            .font(AppTypography.largeTitle())
                            .foregroundStyle(.primary)
                        
                        Text("Sign in to track scores and settlements")
                            .font(AppTypography.body())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, AppSpacing._8)
                    
                    // Sign in buttons
                    VStack(spacing: AppSpacing._4) {
                        // Sign in with Apple
                        SignInWithAppleButton(.signIn) { request in
                            let nonce = AppleAuthService.randomNonceString()
                            appleSignInNonce = nonce
                            request.nonce = AppleAuthService.sha256(nonce)
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleSignInWithAppleCompletion(result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(AppRadius.md)
                        
                        // Sign in with Google (placeholder)
                        Button {
                            viewModel.showGoogleComingSoon = true
                        } label: {
                            HStack(spacing: AppSpacing._2) {
                                Image(systemName: "globe")
                                Text("Sign in with Google")
                                    .font(AppTypography.headline())
                            }
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                        }
                        .buttonStyle(.plain)
                        
                        #if DEBUG
                        // Sign in anonymously (dev only)
                        Button {
                            Task {
                                await viewModel.signInAnonymously()
                            }
                        } label: {
                            HStack(spacing: AppSpacing._2) {
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                Text("Sign in anonymously")
                                    .font(AppTypography.headline())
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppTheme.controlMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoading)
                        #endif
                    }
                    .padding(.horizontal, AppSpacing._6)
                    
                    Spacer(minLength: AppSpacing._12)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Coming Soon", isPresented: $viewModel.showGoogleComingSoon) {
            Button("OK", role: .cancel) {
                viewModel.showGoogleComingSoon = false
            }
        } message: {
            Text("Sign in with Google will be available soon.")
        }
    }
    
    private func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: identityToken, encoding: .utf8),
                  let nonce = appleSignInNonce else {
                viewModel.errorMessage = "Invalid credential from Apple"
                return
            }
            let credential = AppleAuthCredential(
                idToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            Task {
                await viewModel.signInWithApple(credential: credential)
            }
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code == .canceled {
                return
            }
            viewModel.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - ViewModel

@Observable
final class LoginViewModel {
    var isLoading = false
    var errorMessage: String?
    var showGoogleComingSoon = false
    
    @MainActor
    func signInWithApple(credential: AppleAuthCredential) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await FirebaseConfig.signInWithApple(credential: credential)
        } catch let error as NSError {
            if error.domain == AuthErrorDomain, error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                errorMessage = "This Apple ID is already used with another account"
            } else {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signInAnonymously()
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                AnalyticsParameterMethod: "anonymous"
            ])
            Crashlytics.crashlytics().setUserID(result.user.uid)
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}
