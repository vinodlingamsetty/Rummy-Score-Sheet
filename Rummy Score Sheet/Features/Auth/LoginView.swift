//
//  LoginView.swift
//  Rummy Scorekeeper
//
//  Login screen with Sign in with Apple, Google, and Anonymous options.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import FirebaseFunctions
import FirebaseAnalytics
import FirebaseCrashlytics
import GoogleSignIn

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var appleSignInNonce: String?
    
    @State private var email: String = ""
    @State private var otpCode: String = ""
    @State private var isOtpSent: Bool = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
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
                        
                        Text(isOtpSent ? "Enter the code sent to \(email)" : "Sign in to track scores and settlements")
                            .font(AppTypography.body())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing._6)
                    }
                    .padding(.bottom, AppSpacing._4)
                    
                    if !isOtpSent {
                        emailEntrySection
                    } else {
                        otpEntrySection
                    }
                    
                    if !isOtpSent {
                        divider
                        socialSignInSection
                    }
                    
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
    }
    
    private var emailEntrySection: some View {
        VStack(spacing: AppSpacing._4) {
            TextField("Email Address", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(AppTypography.headline())
                .padding()
                .background(AppTheme.controlMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(Color.white.opacity(0.1), lineWidth: 1))
            
            Button {
                Task {
                    if await viewModel.requestOTP(email: email) {
                        withAnimation { isOtpSent = true }
                    }
                }
            } label: {
                Text("Continue with Email")
                    .font(AppTypography.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.gradientPrimary, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
            .buttonStyle(.plain)
            .disabled(email.isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal, AppSpacing._6)
    }
    
    private var otpEntrySection: some View {
        VStack(spacing: AppSpacing._4) {
            TextField("6-Digit Code", text: $otpCode)
                .keyboardType(.numberPad)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()
                .background(AppTheme.controlMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(Color.white.opacity(0.1), lineWidth: 1))
                .onChange(of: otpCode) { _, newValue in
                    if newValue.count > 6 {
                        otpCode = String(newValue.prefix(6))
                    }
                }
            
            Button {
                Task {
                    await viewModel.verifyOTP(email: email, code: otpCode)
                }
            } label: {
                Text("Verify & Login")
                    .font(AppTypography.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.gradientPrimary, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
            .buttonStyle(.plain)
            .disabled(otpCode.count < 6 || viewModel.isLoading)
            
            Button {
                withAnimation {
                    isOtpSent = false
                    otpCode = ""
                }
            } label: {
                Text("Use a different email")
                    .font(AppTypography.footnote())
                    .foregroundStyle(AppTheme.primaryColor)
            }
            .padding(.top, AppSpacing._2)
        }
        .padding(.horizontal, AppSpacing._6)
    }
    
    private var divider: some View {
        HStack {
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
            Text("OR").font(AppTypography.caption2()).foregroundStyle(.secondary)
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
        }
        .padding(.horizontal, AppSpacing._8)
        .padding(.vertical, AppSpacing._4)
    }
    
    private var socialSignInSection: some View {
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
            
            // Sign in with Google
            Button {
                Task {
                    await viewModel.signInWithGoogle()
                }
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
                .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
            
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
    
    private let functions = Functions.functions()
    
    @MainActor
    func requestOTP(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await functions.httpsCallable("sendEmailOTP").call(["email": email])
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    @MainActor
    func verifyOTP(email: String, code: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await functions.httpsCallable("verifyEmailOTP").call(["email": email, "code": code])
            
            guard let data = result.data as? [String: Any],
                  let token = data["token"] as? String else {
                errorMessage = "Invalid response from server"
                isLoading = false
                return
            }
            
            try await Auth.auth().signIn(withCustomToken: token)
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                AnalyticsParameterMethod: "email_otp"
            ])
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing Firebase client ID"
            isLoading = false
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Cannot present sign-in"
            isLoading = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = result.user
            guard let idToken = user.idToken?.tokenString else {
                errorMessage = "Missing ID token from Google"
                isLoading = false
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let displayName = user.profile?.name
            
            try await FirebaseConfig.signInWithGoogle(
                idToken: idToken,
                accessToken: accessToken,
                displayName: displayName
            )
        } catch let error as NSError {
            if error.domain == "GIDSignInErrorDomain", error.code == -5 {
                // User cancelled - ignore
                return
            }
            if error.domain == AuthErrorDomain, error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                errorMessage = "This Google account is already used with another account"
            } else {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
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
