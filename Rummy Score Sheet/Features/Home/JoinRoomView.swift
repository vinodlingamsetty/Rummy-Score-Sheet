//
//  JoinRoomView.swift
//  Rummy Scorekeeper
//
//  Join room popup — 6-digit code input or scan QR code
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var gameState: AppGameState
    @State private var roomCode: String = ""
    @State private var isQRScannerPresented = false

    private let maxCodeLength = 6
    private var canJoin: Bool {
        roomCode.count == maxCodeLength
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing._6) {
                header
                roomCodeSection
                joinRoomButton
                Spacer(minLength: 0)
                scanQRCodeButton
            }
            .padding(.top, AppSpacing._6)
            .padding(.horizontal, AppSpacing._6)
            .padding(.bottom, AppSpacing._6)
        }
        .sheet(isPresented: $isQRScannerPresented) {
            QRScannerView(onCodeScanned: { code in
                roomCode = code
                isQRScannerPresented = false
                joinRoom(with: code)
            })
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            Text("Join Room")
                .font(AppTypography.title2())
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private var roomCodeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Room Code")
                .font(AppTypography.headline())
                .foregroundStyle(AppTheme.textSecondary)

            TextField("A 1 B 2 C 3", text: $roomCode)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .onChange(of: roomCode) { _, newValue in
                    let filtered = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
                    roomCode = String(filtered.prefix(maxCodeLength))
                }
                .padding(AppSpacing._5)
                .background(AppTheme.glassBackground, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.iosCard)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }

    private var joinRoomButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            joinRoom(with: roomCode)
        } label: {
            Text("Join Room")
                .font(AppTypography.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppComponent.Button.heightLg)
                .background(canJoin ? AnyShapeStyle(AppTheme.gradientPrimary) : AnyShapeStyle(AppTheme.glassBackground), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!canJoin)
    }

    private var scanQRCodeButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            isQRScannerPresented = true
        } label: {
            HStack(spacing: AppSpacing._2) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 20, weight: .medium))
                Text("Scan QR Code")
                    .font(AppTypography.headline())
            }
            .foregroundStyle(AppTheme.primaryColor)
        }
        .buttonStyle(.plain)
    }

    private func joinRoom(with code: String) {
        gameState.joinRoom(code: code)
        dismiss()
    }
}

#Preview {
    JoinRoomView(gameState: AppGameState(roomService: MockRoomService()))
}
