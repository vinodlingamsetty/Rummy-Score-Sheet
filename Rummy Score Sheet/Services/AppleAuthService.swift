//
//  AppleAuthService.swift
//  Rummy Scorekeeper
//
//  Sign in with Apple integration. Handles Apple auth flow and Firebase credential exchange.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

/// Result of Sign in with Apple flow
struct AppleAuthCredential {
    let idToken: String
    let rawNonce: String
    let fullName: PersonNameComponents?
}

@MainActor
final class AppleAuthService: NSObject {
    
    private var continuation: CheckedContinuation<AppleAuthCredential, Error>?
    private var currentNonce: String?
    
    /// Triggers Sign in with Apple flow. Returns credential for Firebase, or throws on cancel/error.
    func signInWithApple() async throws -> AppleAuthCredential {
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
        return try await withCheckedThrowingContinuation { cont in
            continuation = cont
        }
    }
    
    // MARK: - Helpers (static for use with SignInWithAppleButton)
    
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { byte in charset[Int(byte) % charset.count] })
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthService: ASAuthorizationControllerDelegate {
    
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: identityToken, encoding: .utf8),
                  let nonce = currentNonce else {
                continuation?.resume(throwing: AppleAuthError.invalidCredential)
                continuation = nil
                return
            }
            
            let credential = AppleAuthCredential(
                idToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            continuation?.resume(returning: credential)
            continuation = nil
            currentNonce = nil
        }
    }
    
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            let authError = error as? ASAuthorizationError
            if authError?.code == .canceled {
                continuation?.resume(throwing: AppleAuthError.userCanceled)
            } else {
                continuation?.resume(throwing: error)
            }
            continuation = nil
            currentNonce = nil
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return ASPresentationAnchor()
        }
        return window
    }
}

// MARK: - Errors

enum AppleAuthError: LocalizedError {
    case invalidCredential
    case userCanceled
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid credential from Apple"
        case .userCanceled:
            return "Sign in was canceled"
        }
    }
}
