//
//  GameHistoryService.swift
//  Rummy Scorekeeper
//
//  Service for fetching and managing game history
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class GameHistoryService: @unchecked Sendable {
    private let db = Firestore.firestore()
    private let collectionName = "gameRooms"
    
    // MARK: - Fetch Game History
    
    /// Fetch completed games where the current user participated
    /// - Parameters:
    ///   - limit: Maximum number of games to fetch (default: 10)
    /// - Returns: Array of completed GameRooms, sorted by most recent first
    func fetchUserGameHistory(limit: Int = 10) async throws -> [GameRoom] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "GameHistoryService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        
        do {
            // Query completed games where current user is explicitly marked as a participant
            // Ordered by endedAt (requires composite index: participantIds array-contains, endedAt desc)
            var allGames: [GameRoom] = []
            do {
                let snapshot = try await db.collection(collectionName)
                    .whereField("isCompleted", isEqualTo: true)
                    .whereField("participantIds", arrayContains: userId)
                    .order(by: "endedAt", descending: true)
                    .limit(to: limit)
                    .getDocuments()
                allGames = try snapshot.documents.compactMap { doc -> GameRoom? in
                    try doc.data(as: GameRoom.self)
                }
            } catch let indexError {
                // Fallback: index may not be deployed; fetch without order and sort in memory
                print("⚠️ Indexed query failed, using fallback: \(indexError.localizedDescription)")
                let snapshot = try await db.collection(collectionName)
                    .whereField("isCompleted", isEqualTo: true)
                    .whereField("participantIds", arrayContains: userId)
                    .limit(to: limit * 2)
                    .getDocuments()
                allGames = try snapshot.documents.compactMap { doc -> GameRoom? in
                    try doc.data(as: GameRoom.self)
                }
                allGames.sort { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
                allGames = Array(allGames.prefix(limit))
            }
            
            print("✅ Fetched \(allGames.count) completed games for user \(userId)")
            return allGames
            
        } catch {
            print("❌ Failed to fetch game history: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Fetch a single game by room code
    func fetchGame(code: String) async throws -> GameRoom? {
        let normalizedCode = code.uppercased().trimmingCharacters(in: .whitespaces)
        
        do {
            let document = try await db.collection(collectionName)
                .document(normalizedCode)
                .getDocument()
            
            guard document.exists else { return nil }
            
            return try document.data(as: GameRoom.self)
        } catch {
            print("❌ Failed to fetch game \(normalizedCode): \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Search & Filter
    
    /// Search games by player name
    func searchGames(playerName: String, limit: Int = 20) async throws -> [GameRoom] {
        let allGames = try await fetchUserGameHistory(limit: limit)
        
        let searchTerm = playerName.lowercased()
        return allGames.filter { room in
            room.players.contains { player in
                player.name.lowercased().contains(searchTerm)
            }
        }
    }
    
    /// Filter games by date range
    func filterGames(from startDate: Date, to endDate: Date) async throws -> [GameRoom] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "GameHistoryService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        
        do {
            let snapshot = try await db.collection(collectionName)
                .whereField("isCompleted", isEqualTo: true)
                .whereField("endedAt", isGreaterThanOrEqualTo: startDate)
                .whereField("endedAt", isLessThanOrEqualTo: endDate)
                .order(by: "endedAt", descending: true)
                .getDocuments()
            
            let games = try snapshot.documents.compactMap { doc -> GameRoom? in
                try doc.data(as: GameRoom.self)
            }
            
            return games
        } catch {
            print("❌ Failed to filter games: \(error.localizedDescription)")
            throw error
        }
    }
}
