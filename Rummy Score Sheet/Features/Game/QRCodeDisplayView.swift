//
//  QRCodeDisplayView.swift
//  Rummy Scorekeeper
//
//  Popup displaying the room's QR code for players to scan
//

import SwiftUI

struct QRCodeDisplayView: View {
    @Environment(\.dismiss) private var dismiss
    let roomCode: String

    private let qrSize: CGFloat = 220

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing._6) {
                HStack {
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)
                    }
                }

                Text("Scan to Join")
                    .font(AppTypography.title2())
                    .foregroundStyle(.primary)

                if let qrImage = QRCodeGenerator.generate(from: roomCode, size: qrSize) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: qrSize, height: qrSize)
                        .padding(AppSpacing._4)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: AppRadius.lg))
                }

                Text(roomCode)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(AppTheme.primaryColor)
                    .tracking(4)

                Spacer()
            }
            .padding(.top, AppSpacing._4)
            .padding(.horizontal, AppSpacing._6)
        }
    }
}

#Preview {
    QRCodeDisplayView(roomCode: "A1B2C3")
}
