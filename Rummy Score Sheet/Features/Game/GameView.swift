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
    }
    
    // MARK: - Round Selector Bar
    
    private var roundSelectorBar: some View {
        HStack(spacing: AppSpacing._3) {
            // Horizontal scroll for rounds
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing._2) {
                    ForEach(1...viewModel.roundCount, id: \.self) { round in
                        RoundButton(
                            round: round,
                            isSelected: viewModel.selectedRound == round,
                            action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                viewModel.selectRound(round)
                            }
                        )
                    }
                }
            }
            
            // Totals button
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                viewModel.showTotalsView.toggle()
            } label: {
                Text("T")
                    .font(AppTypography.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(viewModel.showTotalsView ? AnyShapeStyle(AppTheme.primaryColor) : AnyShapeStyle(AppTheme.controlMaterial))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing._4)
        .padding(.vertical, AppSpacing._2)
        .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: AppRadius.lg))
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.lg))
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
                    Task {
                        await viewModel.endGame()
                        // No onEndGame() call here; the room update listener will 
                        // trigger the transition to WinnerDeclarationView for everyone.
                    }
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

// MARK: - Round Button

private struct RoundButton: View {
    let round: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("R\(round)")
                .font(AppTypography.subheadline())
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(minWidth: 44)
                .padding(.horizontal, AppSpacing._2)
                .padding(.vertical, AppSpacing._2)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(AppTheme.primaryColor) : AnyShapeStyle(AppTheme.controlMaterial))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Player Score Card

private struct PlayerScoreCard: View {
    let player: Player
    let scoreDisplay: String
    let isEliminated: Bool
    let isLeader: Bool
    let isModerator: Bool
    let isTotal: Bool
    let hasScore: Bool
    let pointLimit: Int
    let onTapScore: () -> Void
    
    private var remainingPoints: Int {
        max(0, pointLimit - player.totalScore)
    }
    
    // Computed colors to avoid complex ternary expressions
    private var scoreColor: Color {
        if isEliminated { return .secondary }
        if isTotal { return AppTheme.positiveColor }
        if hasScore { return .primary }
        return .secondary.opacity(0.5)
    }
    
    private var scoreBorderColor: Color {
        if isTotal { return AppTheme.positiveColor.opacity(0.5) }
        if hasScore { return Color.white.opacity(0.2) }
        return Color.white.opacity(0.1)
    }
    
    var body: some View {
        HStack(spacing: AppSpacing._4) {
            // Avatar
            Circle()
                .fill(isEliminated ? AppTheme.destructiveColor.opacity(0.3) : AppTheme.primaryColor.opacity(0.3))
                .frame(width: AppComponent.Avatar.sizeLg, height: AppComponent.Avatar.sizeLg)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(AppTypography.title3())
                        .foregroundStyle(isEliminated ? AppTheme.destructiveColor : AppTheme.primaryColor)
                )
            
            // Player Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing._2) {
                    Text(player.name)
                        .font(AppTypography.headline())
                        .foregroundStyle(isEliminated ? .secondary : .primary)
                    
                    if isLeader {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.yellow)
                    }
                    if isModerator {
                        Image(systemName: "person.badge.key.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.primaryColor)
                    }
                    
                    if isEliminated {
                        Text("ELIMINATED")
                            .font(AppTypography.caption2())
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing._2)
                            .padding(.vertical, 2)
                            .background(AppTheme.destructiveColor, in: Capsule())
                    }
                }
                
                Text(isTotal ? "Running Total" : "Total: \(player.totalScore)")
                    .font(AppTypography.footnote())
                    .foregroundStyle(.secondary)
                
                if !isEliminated {
                    Text("Remaining: \(remainingPoints)")
                        .font(AppTypography.caption2())
                        .foregroundStyle(.secondary.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Score Display (Tappable if not total mode)
            Button(action: onTapScore) {
                Text(scoreDisplay)
                    .font(AppTypography.title2())
                    .foregroundStyle(scoreColor)
                    .frame(minWidth: 60)
                    .padding(.vertical, AppSpacing._2)
                    .padding(.horizontal, AppSpacing._3)
                    .background(
                        hasScore ? AnyShapeStyle(AppTheme.controlMaterial) : AnyShapeStyle(AppTheme.controlMaterial.opacity(0.5)),
                        in: RoundedRectangle(cornerRadius: AppRadius.md)
                    )
                    .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(scoreBorderColor, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(isEliminated || isTotal)
        }
        .padding(AppComponent.Card.padding)
        .background(
            isEliminated ? AnyShapeStyle(AppTheme.destructiveColor.opacity(0.1)) : AnyShapeStyle(AppTheme.cardMaterial),
            in: RoundedRectangle(cornerRadius: AppRadius.iosCard)
        )
        .glassEffect(in: RoundedRectangle(cornerRadius: AppRadius.iosCard))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.iosCard)
                .stroke(isEliminated ? AppTheme.destructiveColor.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
        )
        .opacity(isEliminated ? 0.6 : 1)
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
