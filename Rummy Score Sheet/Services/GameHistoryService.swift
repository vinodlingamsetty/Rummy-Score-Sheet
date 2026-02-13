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
    private let collectionName = AppConstants.Firestore.gameRooms
    
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
                #if DEBUG
                print("⚠️ Indexed query failed, using fallback: \(indexError.localizedDescription)")
                #endif
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
            
            #if DEBUG
            print("✅ Fetched \(allGames.count) completed games for user \(userId)")
            #endif
            return allGames
            
        } catch {
            #if DEBUG
            print("❌ Failed to fetch game history: \(error.localizedDescription)")
            #endif
            throw error
        }
    }
    
    /// Fetch completed games played between the current user and a specific friend
    func fetchGamesWithFriend(friendUserId: String, limit: Int = 20) async throws -> [GameRoom] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "GameHistoryService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        
        do {
            // Strategy: Fetch the current user's games and filter for the friend.
            // This is more reliable than searching the friend's history.
            let snapshot = try await db.collection(collectionName)
                .whereField("isCompleted", isEqualTo: true)
                .whereField("participantIds", arrayContains: userId)
                .order(by: "endedAt", descending: true)
                .limit(to: 50) // Scan more of OUR history to find all shared matches
                .getDocuments()
            
            let myGames = try snapshot.documents.compactMap { doc -> GameRoom? in
                try doc.data(as: GameRoom.self)
            }
            
            // Filter for games where the friend was ALSO a participant
            let sharedGames = myGames.filter { game in
                game.participantIds?.contains(friendUserId) == true
            }
            
            #if DEBUG
            print("✅ Found \(sharedGames.count) shared games with friend \(friendUserId)")
            #endif
            return Array(sharedGames.prefix(limit))
        } catch {
            #if DEBUG
            print("❌ Failed to fetch shared games: \(error.localizedDescription)")
            #endif
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
            #if DEBUG
            print("❌ Failed to fetch game \(normalizedCode): \(error.localizedDescription)")
            #endif
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
            #if DEBUG
            print("❌ Failed to filter games: \(error.localizedDescription)")
            #endif
            throw error
        }
    }
}
