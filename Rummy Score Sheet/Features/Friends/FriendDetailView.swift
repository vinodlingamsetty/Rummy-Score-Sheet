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
    
    /// Always use the latest data from the viewModel if available
    private var currentFriend: Friend {
        viewModel.friends.first(where: { $0.id == friend.id }) ?? friend
    }
    
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
                    if !currentFriend.isSettled {
                        settlementActions
                    }
                    
                    // Settlement History
                    settlementHistorySection
                    
                    // Game History Section
                    gameHistorySection
                }
                .padding(.horizontal, AppSpacing._4)
                .padding(.top, AppSpacing._4)
                .padding(.bottom, AppSpacing._8)
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationTitle(currentFriend.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSettlements(for: currentFriend)
            await viewModel.loadSharedGames(friendUserId: currentFriend.userId)
        }
        .sheet(isPresented: $isShowingSettlementSheet) {
            SettlementSheet(friend: currentFriend) { amount, note in
                Task {
                    await viewModel.recordSettlement(friend: currentFriend, amount: amount, note: note)
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: AppSpacing._3) {
                ProgressView()
                    .tint(.white)
                Text("Recording...")
                    .font(AppTypography.caption1())
                    .foregroundStyle(.white)
            }
            .padding(AppSpacing._6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
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
                    Text(currentFriend.initial)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(AppTheme.primaryColor)
                )
            
            // Name
            Text(currentFriend.name)
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
            
            // Email
            if let email = currentFriend.email {
                Text(email)
                    .font(AppTypography.body())
                    .foregroundStyle(.secondary)
            }
            
            // Stats
            HStack(spacing: AppSpacing._6) {
                statItem(
                    value: "\(currentFriend.gamesPlayedTogether)",
                    label: "Games",
                    icon: "gamecontroller.fill"
                )
                
                if let lastPlayed = currentFriend.lastPlayedDate {
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
            
            Text(currentFriend.balanceFormatted)
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
        if currentFriend.isToCollect {
            return AppTheme.positiveColor
        } else if currentFriend.isToSettle {
            return Color.orange
        } else {
            return .secondary
        }
    }
    
    private var balanceDescription: String {
        if currentFriend.isToCollect {
            return "\(currentFriend.name) owes you"
        } else if currentFriend.isToSettle {
            return "You owe \(currentFriend.name)"
        } else {
            return "All settled up!"
        }
    }
    
    // MARK: - Settlement History
    
    private var settlementHistorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("SETTLEMENT HISTORY")
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpacing._3)
            
            if viewModel.isSettlementsLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.settlements.isEmpty {
                Text("No settlement records yet.")
                    .font(AppTypography.body())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
                    .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
            } else {
                VStack(spacing: AppSpacing._2) {
                    ForEach(viewModel.settlements) { settlement in
                        SettlementRow(settlement: settlement, friend: currentFriend)
                    }
                }
            }
        }
    }
    
    // MARK: - Game History Section
    
    private var gameHistorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            Text("GAME HISTORY")
                .font(AppTypography.caption1())
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpacing._3)
            
            if viewModel.isSharedGamesLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.sharedGames.isEmpty {
                emptyGameHistoryCard
            } else {
                VStack(spacing: AppSpacing._3) {
                    ForEach(viewModel.sharedGames) { game in
                        NavigationLink {
                            GameDetailView(game: game)
                        } label: {
                            GameHistoryCard(game: game)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private var emptyGameHistoryCard: some View {
        VStack(spacing: AppSpacing._3) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            
            Text("No shared games yet")
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
            
            Text("Complete a game with \(currentFriend.name) to see history here")
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

// MARK: - Settlement Row

private struct SettlementRow: View {
    let settlement: Settlement
    let friend: Friend
    
    private var isMe: Bool {
        settlement.settledBy == FirebaseConfig.getCurrentUserId()
    }
    
    var body: some View {
        HStack(spacing: AppSpacing._3) {
            Circle()
                .fill(isMe ? AppTheme.primaryColor.opacity(0.2) : AppTheme.positiveColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isMe ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundStyle(isMe ? AppTheme.primaryColor : AppTheme.positiveColor)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isMe ? "You paid \(friend.name)" : "\(friend.name) paid you")
                    .font(AppTypography.headline())
                    .foregroundStyle(.primary)
                
                Text(settlement.settledAt, format: .dateTime.month().day().year().hour().minute())
                    .font(AppTypography.caption2())
                    .foregroundStyle(.secondary)
                
                if let note = settlement.note, !note.isEmpty {
                    Text(note)
                        .font(AppTypography.caption1())
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(settlement.amountFormatted)
                .font(AppTypography.title3())
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .padding(AppSpacing._3)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
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
            .environment(FriendsViewModel(friendService: MockFriendService()))
    }
    .preferredColorScheme(.dark)
}
