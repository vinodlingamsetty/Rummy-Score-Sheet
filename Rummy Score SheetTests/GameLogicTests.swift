//
//  GameLogicTests.swift
//  Rummy ScorekeeperTests
//
//  Unit tests for GameViewModel scoring and logic
//

import XCTest
@testable import Rummy_Score_Sheet

final class GameLogicTests: XCTestCase {
    
    var mockRoomService: MockRoomService!
    var viewModel: GameViewModel!
    var room: GameRoom!
    let userId1 = UUID()
    let userId2 = UUID()
    
    override func setUp() {
        super.setUp()
        mockRoomService = MockRoomService()
        
        // Setup a standard room with 2 players
        room = GameRoom(
            id: "TEST01",
            pointLimit: 100,
            pointValue: 10,
            players: [
                Player(id: userId1, name: "Alice", isReady: true, isModerator: true, scores: []),
                Player(id: userId2, name: "Bob", isReady: true, isModerator: false, scores: [])
            ],
            currentRound: 1,
            isStarted: true,
            createdAt: Date(),
            createdBy: "user1",
            participantIds: ["user1", "user2"]
        )
        
        viewModel = GameViewModel(
            room: room,
            currentUserId: userId1,
            roomService: mockRoomService,
            onRoomUpdate: { _ in }
        )
    }
    
    // MARK: - Scoring Tests
    
    func testTotalScoreCalculation() {
        // Given
        var p1 = room.players[0]
        p1.scores = [10, 20, 5] // Total: 35
        room.players[0] = p1
        viewModel.room = room
        
        // Then
        XCTAssertEqual(viewModel.room.players[0].totalScore, 35)
    }
    
    func testEliminationLogic() {
        // Given point limit is 100
        var p1 = room.players[0]
        p1.scores = [50, 49] // Total: 99 (Safe)
        room.players[0] = p1
        viewModel.room = room
        
        XCTAssertFalse(viewModel.isEliminated(p1), "Player with 99 points should not be eliminated")
        
        // Update to exceed limit
        p1.scores.append(1) // Total: 100 (Eliminated)
        room.players[0] = p1
        viewModel.room = room
        
        XCTAssertTrue(viewModel.isEliminated(p1), "Player with 100 points should be eliminated")
    }
    
    func testLeaderIdentification() {
        // Given
        var p1 = room.players[0] // Alice
        var p2 = room.players[1] // Bob
        
        p1.scores = [10]
        p2.scores = [20]
        
        room.players = [p1, p2]
        viewModel.room = room
        
        // Then Alice (10) should be leader over Bob (20)
        XCTAssertTrue(viewModel.isLeader(p1))
        XCTAssertFalse(viewModel.isLeader(p2))
    }
    
    // MARK: - Game Flow Tests
    
    func testCanAdvanceRound() {
        // Round 1
        XCTAssertFalse(viewModel.canAdvanceRound, "Should not advance when scores are missing")
        
        // Add scores for both players
        var p1 = room.players[0]
        var p2 = room.players[1]
        p1.scores = [10]
        p2.scores = [20]
        room.players = [p1, p2]
        viewModel.room = room
        
        XCTAssertTrue(viewModel.canAdvanceRound, "Should advance when all active players have scores")
    }
    
    func testWinnerDetection() async {
        // Setup: Bob gets eliminated
        var p2 = room.players[1]
        p2.scores = [101] // Over limit
        room.players[1] = p2
        viewModel.room = room
        
        // Check winner computed property
        XCTAssertNotNil(viewModel.winner)
        XCTAssertEqual(viewModel.winner?.name, "Alice")
    }
}
