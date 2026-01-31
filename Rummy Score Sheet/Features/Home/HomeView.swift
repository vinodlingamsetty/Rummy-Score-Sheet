//
//  HomeView.swift
//  Rummy Scorekeeper
//
//  Home tab — Host / Join / Recent History
//

import SwiftUI

struct HomeView: View {
    @State private var isGameSetupPresented = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    actionCards
                    recentHistorySection
                }
                .padding(.top, 48)
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $isGameSetupPresented) {
            GameSetupView()
        }
    }

    private var actionCards: some View {
        VStack(spacing: 20) {
            ActionCard(
                title: "Host Game",
                icon: "antenna.radiowaves.left.and.right",
                action: { isGameSetupPresented = true }
            )
            ActionCard(
                title: "Join Game",
                icon: "qrcode.viewfinder",
                action: {}
            )
        }
        .padding(.horizontal, 24)
    }

    private var recentHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent History")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 24)

            Text("No recent games")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
        }
        .padding(.top, 16)
    }
}

private struct ActionCard: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(AppTheme.primaryColor)
                    .frame(width: 56, height: 56)

                Text(title)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(24)
            .background(AppTheme.glassMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}
