//
//  FriendDetailView.swift
//  Rummy Scorekeeper
//
//  Detail view for individual friend showing game history together
//

import SwiftUI

struct FriendDetailView: View {
    let friend: Friend
    @Environment(FriendsViewModel.self) private var viewModel
    @State private var isShowingSettlementSheet = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppSpacing._6) {
                    // Friend Header
                    friendHeaderCard
                    
                    // Balance Summary
                    balanceSummaryCard
                    
                    // Actions
                    if !friend.isSettled {
                        settlementActions
                    }
                    
                    // Game History Section
                    gameHistorySection
                }
                .padding(.horizontal, AppSpacing._4)
                .padding(.top, AppSpacing._4)
                .padding(.bottom, AppSpacing._8)
            }
        }
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingSettlementSheet) {
            SettlementSheet(friend: friend) { amount, note in
                Task {
                    await viewModel.recordSettlement(friend: friend, amount: amount, note: note)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private var settlementActions: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            isShowingSettlementSheet = true
        } label: {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                Text("Record Settlement")
                    .font(AppTypography.headline())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing._4)
            .background(AppTheme.gradientPrimary, in: Capsule())
            .glassEffect(in: .capsule)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Friend Header Card
    
    private var friendHeaderCard: some View {
        VStack(spacing: AppSpacing._4) {
            // Avatar
            Circle()
                .fill(AppTheme.primaryColor.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(friend.initial)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(AppTheme.primaryColor)
                )
            
            // Name
            Text(friend.name)
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
            
            // Email
            if let email = friend.email {
                Text(email)
                    .font(AppTypography.body())
                    .foregroundStyle(.secondary)
            }
            
            // Stats
            HStack(spacing: AppSpacing._6) {
                statItem(
                    value: "\(friend.gamesPlayedTogether)",
                    label: "Games",
                    icon: "gamecontroller.fill"
                )
                
                if let lastPlayed = friend.lastPlayedDate {
                    statItem(
                        value: lastPlayed.timeAgoDisplay,
                        label: "Last Played",
                        icon: "clock.fill"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._5)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
    }
    
    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: AppSpacing._2) {
            HStack(spacing: AppSpacing._2) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(AppTypography.headline())
            }
            .foregroundStyle(AppTheme.primaryColor)
            
            Text(label)
                .font(AppTypography.caption2())
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Balance Summary Card
    
    private var balanceSummaryCard: some View {
        VStack(spacing: AppSpacing._4) {
            Text("Current Balance")
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
            
            Text(friend.balanceFormatted)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(balanceColor)
            
            Text(balanceDescription)
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._5)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(balanceColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var balanceColor: Color {
        if friend.isToCollect {
            return AppTheme.positiveColor
        } else if friend.isToSettle {
            return Color.orange
        } else {
            return .secondary
        }
    }
    
    private var balanceDescription: String {
        if friend.isToCollect {
            return "\(friend.name) owes you"
        } else if friend.isToSettle {
            return "You owe \(friend.name)"
        } else {
            return "All settled up!"
        }
    }
    
    // MARK: - Game History Section
    
    private var gameHistorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("GAME HISTORY")
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpacing._3)
            
            VStack(spacing: AppSpacing._3) {
                // Placeholder for future game history
                emptyGameHistoryCard
            }
        }
    }
    
    private var emptyGameHistoryCard: some View {
        VStack(spacing: AppSpacing._3) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            
            Text("Game history coming soon")
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
            
            Text("You'll be able to see all games played with \(friend.name) here")
                .font(AppTypography.caption1())
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing._6)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
    }
}

// MARK: - Settlement Sheet

private struct SettlementSheet: View {
    let friend: Friend
    let onConfirm: (Double, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var note: String = ""
    
    init(friend: Friend, onConfirm: @escaping (Double, String) -> Void) {
        self.friend = friend
        self.onConfirm = onConfirm
        // Set default amount to absolute balance
        _amount = State(initialValue: String(format: "%.2f", abs(friend.balance)))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing._6) {
                        headerSection
                        
                        VStack(alignment: .leading, spacing: AppSpacing._2) {
                            Text("Amount")
                                .font(AppTypography.headline())
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(AppTheme.primaryColor)
                                
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 44, weight: .bold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .background(AppTheme.controlMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                            .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
                        }
                        
                        VStack(alignment: .leading, spacing: AppSpacing._2) {
                            Text("Note (Optional)")
                                .font(AppTypography.headline())
                                .foregroundStyle(.secondary)
                            
                            TextField("e.g. Cash, Venmo", text: $note)
                                .padding()
                                .background(AppTheme.controlMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                                .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
                        }
                        
                        Spacer()
                        
                        confirmButton
                    }
                    .padding(AppSpacing._4)
                }
            }
            .navigationTitle("Record Settlement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppSpacing._2) {
            Text(friend.isToCollect ? "Collect from \(friend.name)" : "Pay to \(friend.name)")
                .font(AppTypography.title3())
                .foregroundStyle(.secondary)
            
            Text("Balance: \(friend.balanceFormatted)")
                .font(AppTypography.body())
                .foregroundStyle(friend.isToCollect ? AppTheme.positiveColor : .orange)
        }
        .padding(.vertical, AppSpacing._4)
    }
    
    private var confirmButton: some View {
        Button {
            if let value = Double(amount) {
                onConfirm(value, note)
                dismiss()
            }
        } label: {
            Text("Confirm Settlement")
                .font(AppTypography.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing._4)
                .background(AppTheme.gradientPrimary, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(Double(amount) == nil || Double(amount)! <= 0)
    }
}

// MARK: - Date Extension

extension Date {
    var timeAgoDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FriendDetailView(friend: Friend.mockFriends[0])
    }
    .preferredColorScheme(.dark)
}
