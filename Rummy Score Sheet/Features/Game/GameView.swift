//
//  GameView.swift
//  Rummy Scorekeeper
//
//  Active game screen — rounds, player scores, live leaderboard
//

import SwiftUI

struct GameView: View {
    @Bindable var viewModel: GameViewModel
    let onLeaveGame: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Round Selector (Horizontal)
                roundSelectorBar
                    .padding(.horizontal, AppSpacing._4)
                    .padding(.top, AppSpacing._4)
                    .padding(.bottom, AppSpacing._3)
                    .background(AppTheme.background)
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: AppSpacing._4) {
                        // Round info
                        roundInfoCard
                        
                        // Player Cards
                        playersList
                        
                        // Action Buttons
                        actionButtons
                    }
                    .padding(.horizontal, AppSpacing._4)
                    .padding(.top, AppSpacing._2)
                    .padding(.bottom, AppComponent.Layout.tabBarHeight + AppSpacing._6)
                }
            }
        }
        .sheet(isPresented: $viewModel.isScoreInputPresented) {
            if let player = viewModel.selectedPlayerForScore {
                ScoreInputView(
                    player: player,
                    currentRound: viewModel.room.currentRound,
                    onSubmit: { score in
                        viewModel.submitScore(for: player.id, score: score)
                    },
                    onCancel: {
                        viewModel.isScoreInputPresented = false
                    }
                )
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("You've Been Eliminated", isPresented: $viewModel.showEliminationAlert) {
            Button("OK") {
                viewModel.showEliminationAlert = false
            }
        } message: {
            Text("You've reached the point limit. You're out of this game, but you can still watch the rest.")
        }
        .alert("End Game?", isPresented: $viewModel.showEndGameConfirmation) {
            Button("Declare Winner") {
                Task {
                    await viewModel.endGame(isVoid: false)
                }
            }
            Button("End & Void Game", role: .destructive) {
                Task {
                    await viewModel.endGame(isVoid: true)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("How would you like to end the game? You can either declare a winner based on current scores or void the game entirely (no money will be exchanged).")
        }
    }
    
    // MARK: - Round Selector Bar
    
    private var roundSelectorBar: some View {
        RoundSelectorBar(
            roundCount: viewModel.roundCount,
            selectedRound: viewModel.selectedRound,
            showTotalsView: viewModel.showTotalsView,
            onSelectRound: { round in
                viewModel.selectRound(round)
            },
            onToggleTotals: {
                viewModel.showTotalsView.toggle()
            }
        )
    }
    
    // MARK: - Round Info
    
    private var roundInfoCard: some View {
        HStack(spacing: AppSpacing._4) {
            VStack(alignment: .leading, spacing: AppSpacing._1) {
                Text("Room \(viewModel.room.id)")
                    .font(AppTypography.headline())
                    .foregroundStyle(.primary)
                Text("Point Limit: \(viewModel.room.pointLimit)")
                    .font(AppTypography.footnote())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: AppSpacing._1) {
                Text("\(viewModel.activePlayers.count) Active")
                    .font(AppTypography.headline())
                    .foregroundStyle(AppTheme.positiveColor)
                Text("\(viewModel.room.players.count - viewModel.activePlayers.count) Eliminated")
                    .font(AppTypography.footnote())
                    .foregroundStyle(AppTheme.destructiveColor)
            }
        }
        .padding(AppSpacing._4)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
    }
    
    // MARK: - Players List
    
        private var playersList: some View {
        VStack(spacing: AppSpacing._3) {
            ForEach(viewModel.sortedPlayers) { player in
                let isMe = player.id == viewModel.currentUserId
                let canTap = viewModel.isCurrentUserModerator || (!isMe && !viewModel.isEliminated(player)) || (isMe && !viewModel.isEliminated(player))
                
                PlayerScoreCard(
                    player: player,
                    scoreDisplay: viewModel.showTotalsView ? "\(player.totalScore)" : (viewModel.score(for: player.id, round: viewModel.selectedRound - 1).map { "\($0)" } ?? "-"),
                    isEliminated: viewModel.isEliminated(player),
                    isLeader: viewModel.isLeader(player),
                    isModerator: player.isModerator,
                    isTotal: viewModel.showTotalsView,
                    hasScore: viewModel.showTotalsView || viewModel.hasScore(for: player.id, round: viewModel.selectedRound - 1),
                    pointLimit: viewModel.room.pointLimit,
                    onTapScore: {
                        if !viewModel.showTotalsView {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            viewModel.presentScoreInput(for: player)
                        }
                    }
                )
                .disabled(!canTap || viewModel.showTotalsView)
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: AppSpacing._3) {
            HStack(spacing: AppSpacing._3) {
                // End Game Button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.showEndGameConfirmation = true
                } label: {
                    HStack(spacing: AppSpacing._2) {
                        Image(systemName: "flag.checkered")
                        Text("End Game")
                            .font(AppTypography.subheadline())
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing._3)
                    .background(AppTheme.controlMaterial, in: Capsule())
                    .glassEffect(in: .capsule)
                }
                .buttonStyle(.plain)
                
                // Leave Game Button
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onLeaveGame()
                } label: {
                    HStack(spacing: AppSpacing._2) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Leave")
                            .font(AppTypography.subheadline())
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing._3)
                    .background(AppTheme.controlMaterial, in: Capsule())
                    .glassEffect(in: .capsule)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let mockService = MockRoomService()
    let mockRoom = GameRoom(
        id: "ABC123",
        pointLimit: 201,
        pointValue: 10,
        players: [
            Player(id: UUID(), name: "Alice", isReady: true, isModerator: true, scores: [15, 20]),
            Player(id: UUID(), name: "Bob", isReady: true, isModerator: false, scores: [25, 30]),
            Player(id: UUID(), name: "Charlie", isReady: true, isModerator: false, scores: [210, 15])
        ],
        currentRound: 2,
        isStarted: true
    )
    
    let viewModel = GameViewModel(
        room: mockRoom,
        currentUserId: UUID(),
        roomService: mockService,
        onRoomUpdate: { _ in }
    )
    
    GameView(
        viewModel: viewModel,
        onLeaveGame: {}
    )
}
