//
//  FriendsView.swift
//  Rummy Scorekeeper
//
//  Friends list with settlements and balances
//

import SwiftUI

struct FriendsView: View {
    @State private var viewModel = FriendsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                contentView
            }
            .navigationTitle("Friends")
            .searchable(
                text: $viewModel.searchQuery,
                prompt: "Search friends"
            )
            .refreshable {
                await viewModel.loadFriends()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.filteredFriends.isEmpty {
            emptyStateView
        } else {
            friendsListView
        }
    }
    
    // MARK: - Friends List
    
    private var friendsListView: some View {
        ScrollView {
            VStack(spacing: AppSpacing._6) {
                // To Collect Section
                if !viewModel.friendsToCollect.isEmpty {
                    friendsSection(
                        title: "TO COLLECT",
                        friends: viewModel.friendsToCollect,
                        accentColor: AppTheme.positiveColor
                    )
                }
                
                // To Settle Section
                if !viewModel.friendsToSettle.isEmpty {
                    friendsSection(
                        title: "TO SETTLE",
                        friends: viewModel.friendsToSettle,
                        accentColor: Color.orange
                    )
                }
                
                // Settled (Zero Balance) Section
                if !viewModel.settledFriends.isEmpty {
                    friendsSection(
                        title: "SETTLED",
                        friends: viewModel.settledFriends,
                        accentColor: .secondary
                    )
                }
            }
            .padding(.horizontal, AppSpacing._4)
            .padding(.top, AppSpacing._4)
            .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._6)
        }
    }
    
    private func friendsSection(title: String, friends: [Friend], accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing._3) {
            // Section Header
            Text(title)
                .font(AppTypography.caption1())
                .foregroundStyle(accentColor)
                .padding(.horizontal, AppSpacing._3)
            
            // Friend Cards
            VStack(spacing: AppSpacing._3) {
                ForEach(friends) { friend in
                    NavigationLink {
                        FriendDetailView(friend: friend)
                    } label: {
                        FriendCard(
                            friend: friend,
                            accentColor: accentColor,
                            onSettle: {
                                Task {
                                    await viewModel.settleFriend(friend)
                                }
                            },
                            onNudge: {
                                Task {
                                    await viewModel.nudgeFriend(friend)
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
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
            
            Text("Loading friends...")
                .font(AppTypography.body())
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing._4) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.primaryColor.opacity(0.5))
            
            Text("No Friends Yet")
                .font(AppTypography.title2())
                .foregroundStyle(.primary)
            
            Text(viewModel.searchQuery.isEmpty
                 ? "Play games to add friends automatically"
                 : "No friends match '\(viewModel.searchQuery)'"
            )
            .font(AppTypography.body())
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppSpacing._8)
        }
        .padding(.top, AppSpacing._8)
    }
}

// MARK: - Friend Card

private struct FriendCard: View {
    let friend: Friend
    let accentColor: Color
    let onSettle: () -> Void
    let onNudge: () -> Void
    
    var body: some View {
        HStack(spacing: AppSpacing._4) {
            // Avatar
            Circle()
                .fill(accentColor.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(friend.initial)
                        .font(AppTypography.title3())
                        .foregroundStyle(accentColor)
                )
            
            // Friend Info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(AppTypography.headline())
                    .foregroundStyle(.primary)
                
                Text("\(friend.gamesPlayedTogether) \(friend.gamesPlayedTogether == 1 ? "game" : "games") together")
                    .font(AppTypography.caption1())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Balance
            Text(friend.balanceFormatted)
                .font(AppTypography.title3())
                .fontWeight(.semibold)
                .foregroundStyle(accentColor)
        }
        .padding(AppSpacing._4)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(accentColor.opacity(0.3), lineWidth: 1)
        )
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if !friend.isSettled {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onSettle()
                } label: {
                    Label("Settle", systemImage: "checkmark.circle.fill")
                }
                .tint(AppTheme.positiveColor)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onNudge()
            } label: {
                Label("Nudge", systemImage: "bell.fill")
            }
            .tint(Color.orange)
        }
        .contextMenu {
            Button {
                onNudge()
            } label: {
                Label("Send Reminder", systemImage: "bell.fill")
            }
            
            if !friend.isSettled {
                Button {
                    onSettle()
                } label: {
                    Label("Mark as Settled", systemImage: "checkmark.circle.fill")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FriendsView()
        .preferredColorScheme(.dark)
}
