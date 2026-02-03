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
                VStack(spacing: AppSpacing._8) {
                    actionCards
                    recentHistorySection
                }
                .padding(.top, AppSpacing._12)
                .padding(.bottom, AppSpacing._16 + 56)
            }
        }
        .sheet(isPresented: $isGameSetupPresented) {
            GameSetupView()
        }
    }

    private var actionCards: some View {
        VStack(spacing: AppSpacing._5) {
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
        .padding(.horizontal, AppSpacing._6)
    }

    private var recentHistorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("Recent History")
                .font(AppTypography.title2())
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, AppSpacing._6)

            Text("No recent games")
                .font(AppTypography.subheadline())
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing._6)
        }
        .padding(.top, AppSpacing._4)
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
            HStack(spacing: AppSpacing._5) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(AppTheme.primaryColor)
                    .frame(width: AppComponent.Avatar.sizeLg, height: AppComponent.Avatar.sizeLg)

                Text(title)
                    .font(AppTypography.title2())
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(AppTypography.headline())
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(AppSpacing._6)
            .background(AppTheme.glassMaterial, in: RoundedRectangle(cornerRadius: AppRadius.xl))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}
