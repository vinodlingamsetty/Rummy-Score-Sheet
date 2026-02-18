//
//  SettlementLogicTests.swift
//  Rummy ScorekeeperTests
//
//  Unit tests for Settlement and Balance logic
//

import XCTest
@testable import Rummy_Score_Sheet

final class SettlementLogicTests: XCTestCase {
    
    var service: MockFriendService!
    
    override func setUp() {
        super.setUp()
        service = MockFriendService()
    }
    
    func testPartialSettlementReducesPositiveBalance() async throws {
        // Find a friend with positive balance or create a scenario
        // MockFriendService initializes with mock data.
        // Let's rely on finding one or just trusting the logic updates the array.
        
        let friends = try await service.fetchFriends()
        guard let targetFriend = friends.first(where: { $0.balance > 0 }) else {
            XCTFail("Setup failed: No friend with positive balance found in mock data")
            return
        }
        
        let initialBalance = targetFriend.balance
        let payment = 10.0
        
        // Act
        try await service.recordSettlement(id: targetFriend.id, amount: payment, note: "Test Payment")
        
        // Assert
        let updatedFriends = try await service.fetchFriends()
        let updatedFriend = updatedFriends.first(where: { $0.id == targetFriend.id })!
        
        XCTAssertEqual(updatedFriend.balance, initialBalance - payment, accuracy: 0.01)
    }
    
    func testFullSettlementClearsBalance() async throws {
        let friends = try await service.fetchFriends()
        guard let targetFriend = friends.first(where: { $0.balance != 0 }) else {
            XCTFail("Setup failed: No friend with balance found")
            return
        }
        
        // Act
        try await service.settleFriend(id: targetFriend.id)
        
        // Assert
        let updatedFriends = try await service.fetchFriends()
        let updatedFriend = updatedFriends.first(where: { $0.id == targetFriend.id })!
        
        XCTAssertEqual(updatedFriend.balance, 0.0, accuracy: 0.01)
    }
    
    func testOverpaymentHandling() async throws {
        // MockService logic: friends[index].balance = max(0, currentBalance - amount)
        // It clamps to 0.
        
        let friends = try await service.fetchFriends()
        guard let targetFriend = friends.first(where: { $0.balance > 0 }) else { return }
        
        let payment = targetFriend.balance + 50.0 // Overpay
        
        // Act
        try await service.recordSettlement(id: targetFriend.id, amount: payment, note: "Overpayment")
        
        // Assert
        let updatedFriends = try await service.fetchFriends()
        let updatedFriend = updatedFriends.first(where: { $0.id == targetFriend.id })!
        
        XCTAssertEqual(updatedFriend.balance, 0.0, accuracy: 0.01, "Balance should not go negative on overpayment in this simple model")
    }
}
