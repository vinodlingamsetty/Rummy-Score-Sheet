//
//  ProfileView.swift
//  Rummy Scorekeeper
//
//  Profile screen with user info, statistics, and settings
//

import SwiftUI
import UIKit

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else if let profile = viewModel.userProfile {
                    profileContentView(profile: profile)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Profile")
            .task {
                await viewModel.loadUserProfile()
            }
            .sheet(isPresented: $viewModel.isEditingProfile) {
                editProfileSheet
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
    }
    
    // MARK: - Profile Content
    
    private func profileContentView(profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing._6) {
                // User Info Card
                userInfoCard(profile: profile)
                
                // Statistics Card
                statisticsCard(profile: profile)
                
                // Settings Section
                settingsSection
                
                // Legal Section
                legalSection
                
                // Account Actions
                accountActionsSection
            }
            .padding(.horizontal, AppSpacing._4)
            .padding(.top, AppSpacing._4)
            .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._6)
        }
    }
    
    // MARK: - User Info Card
    
    private func userInfoCard(profile: UserProfile) -> some View {
        VStack(spacing: AppSpacing._4) {
            // Avatar
            Circle()
                .fill(AppTheme.primaryColor.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(profile.initial)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(AppTheme.primaryColor)
                )
            
            // Name
            Text(profile.displayName)
                .font(AppTypography.title1())
                .foregroundStyle(.primary)
            
            // Email/Phone
            if let email = profile.email {
                Text(email)
                    .font(AppTypography.body())
                    .foregroundStyle(.secondary)
            } else if let phone = profile.phoneNumber {
                Text(phone)
                    .font(AppTypography.body())
                    .foregroundStyle(.secondary)
            }
            
            // Edit Button
            Button {
                viewModel.triggerHaptic()
                viewModel.editedDisplayName = profile.displayName
                viewModel.isEditingProfile = true
            } label: {
                Text("Edit Profile")
                    .font(AppTypography.headline())
                    .foregroundStyle(AppTheme.primaryColor)
                    .padding(.vertical, AppSpacing._2)
                    .padding(.horizontal, AppSpacing._4)
                    .background(AppTheme.primaryColor.opacity(0.2), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._5)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
    }
    
    // MARK: - Statistics Card
    
    private func statisticsCard(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing._4) {
            Text("GAME STATISTICS")
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpacing._3)
            
            VStack(spacing: AppSpacing._3) {
                HStack {
                    statItem(
                        icon: "gamecontroller.fill",
                        label: "Games Played",
                        value: "\(profile.totalGamesPlayed)"
                    )
                    
                    Spacer()
                    
                    statItem(
                        icon: "trophy.fill",
                        label: "Games Won",
                        value: "\(profile.totalGamesWon)"
                    )
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack {
                    statItem(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "Win Rate",
                        value: profile.winRateFormatted,
                        color: AppTheme.positiveColor
                    )
                    
                    Spacer()
                    
                    statItem(
                        icon: "dollarsign.circle.fill",
                        label: "Net Balance",
                        value: profile.netBalanceFormatted,
                        color: profile.netBalance >= 0 ? AppTheme.positiveColor : AppTheme.destructiveColor
                    )
                }
            }
            .padding(AppSpacing._4)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        }
    }
    
    private func statItem(icon: String, label: String, value: String, color: Color = .primary) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing._2) {
            HStack(spacing: AppSpacing._2) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(AppTheme.primaryColor)
                Text(value)
                    .font(AppTypography.title3())
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            
            Text(label)
                .font(AppTypography.caption2())
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._4) {
            Text("APP SETTINGS")
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpacing._3)
            
            VStack(spacing: 0) {
                settingRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Get notified about game updates",
                    isOn: $viewModel.notificationsEnabled
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                settingRow(
                    icon: "hand.tap.fill",
                    title: "Haptic Feedback",
                    subtitle: "Vibration on interactions",
                    isOn: $viewModel.hapticsEnabled
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                settingRow(
                    icon: "eye.fill",
                    title: "High Contrast",
                    subtitle: "Improve accessibility",
                    isOn: $viewModel.highContrastMode
                )
            }
            .padding(AppSpacing._4)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        }
    }
    
    private func settingRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: AppSpacing._3) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.primaryColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.headline())
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(AppTypography.caption1())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.primaryColor)
                .onChange(of: isOn.wrappedValue) { _, newValue in
                    if newValue {
                        viewModel.triggerHaptic()
                    }
                }
        }
    }
    
    // MARK: - Legal Section
    
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._4) {
            Text("LEGAL")
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpacing._3)
            
            Button {
                viewModel.triggerHaptic()
                if let url = URL(string: AppConstants.URLs.privacyPolicy) {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: AppSpacing._3) {
                    Image(systemName: "hand.raised.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.primaryColor)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy Policy")
                            .font(AppTypography.headline())
                            .foregroundStyle(.primary)
                        Text("View how we handle your data")
                            .font(AppTypography.caption1())
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(AppSpacing._4)
            }
            .buttonStyle(.plain)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        }
    }
    
    // MARK: - Account Actions
    
    private var accountActionsSection: some View {
        VStack(spacing: AppSpacing._3) {
            Button {
                viewModel.triggerHaptic(style: .medium)
                Task {
                    await viewModel.logout()
                }
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                        .font(AppTypography.headline())
                }
                .foregroundStyle(AppTheme.destructiveColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing._3)
                .background(AppTheme.destructiveColor.opacity(0.1), in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Edit Profile Sheet
    
    private var editProfileSheet: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppSpacing._5) {
                    // Display Name Field
                    VStack(alignment: .leading, spacing: AppSpacing._2) {
                        Text("Display Name")
                            .font(AppTypography.headline())
                            .foregroundStyle(.secondary)
                        
                        TextField("Enter your name", text: $viewModel.editedDisplayName)
                            .font(AppTypography.body())
                            .foregroundStyle(.primary)
                            .padding(AppSpacing._3)
                            .background(AppTheme.controlMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
                    }
                    
                    Spacer()
                }
                .padding(AppSpacing._4)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.isEditingProfile = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.updateDisplayName()
                        }
                    }
                    .disabled(viewModel.editedDisplayName.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing._4) {
            ProgressView()
                .tint(AppTheme.primaryColor)
                .scaleEffect(1.2)
            
            Text("Loading profile...")
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing._4) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.primaryColor.opacity(0.5))
            
            Text("No Profile Found")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
            
            Text("Please sign in to view your profile")
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
