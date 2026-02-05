//
//  FirebaseRoomService.swift
//  Rummy Scorekeeper
//
//  Firebase Firestore implementation of RoomService with real-time sync
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseRoomService: RoomService, @unchecked Sendable {
    
    private let db = Firestore.firestore()
    private let collectionName = "gameRooms"
    
    // MARK: - RoomService Implementation
    
    func createRoom(pointLimit: Int, pointValue: Int, playerCount: Int) async throws -> RoomServiceResult {
        // Ensure auth is complete
        await FirebaseConfig.ensureAuthenticated()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RoomServiceError.networkError(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
        }
        
        let code = generateRoomCode()
        let moderatorId = UUID()
        let moderator = Player(
            id: moderatorId,
            name: "You",
            isReady: true,
            isModerator: true,
            scores: []
        )
        
        let room = GameRoom(
            id: code,
            pointLimit: pointLimit,
            pointValue: pointValue,
            players: [moderator],
            currentRound: 1,
            isStarted: false,
            createdAt: Date(),
            createdBy: userId
        )
        
        do {
            try db.collection(collectionName).document(code).setData(from: room)
            
            // Log analytics
            FirebaseConfig.logEvent("room_created", parameters: [
                "room_code": code,
                "point_limit": pointLimit
            ])
            
            return RoomServiceResult(room: room, currentUserId: moderatorId)
        } catch {
            throw RoomServiceError.networkError(error)
        }
    }
    
    func joinRoom(code: String, playerName: String) async throws -> RoomServiceResult {
        // Ensure auth is complete
        await FirebaseConfig.ensureAuthenticated()
        
        guard Auth.auth().currentUser != nil else {
            throw RoomServiceError.networkError(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
        }
        
        let normalizedCode = code.uppercased()
        let docRef = db.collection(collectionName).document(normalizedCode)
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists else {
                throw RoomServiceError.roomNotFound
            }
            
            var room = try document.data(as: GameRoom.self)
            
            // Check if room is full
            if room.players.count >= 10 {
                throw RoomServiceError.roomFull
            }
            
            let playerId = UUID()
            let player = Player(
                id: playerId,
                name: playerName,
                isReady: false,
                isModerator: false,
                scores: room.isStarted ? [Int](repeating: 0, count: 6) : []
            )
            
            room.players.append(player)
            
            try docRef.setData(from: room)
            
            // Log analytics
            FirebaseConfig.logEvent("room_joined", parameters: [
                "room_code": normalizedCode
            ])
            
            return RoomServiceResult(room: room, currentUserId: playerId)
        } catch let error as RoomServiceError {
            throw error
        } catch {
            throw RoomServiceError.networkError(error)
        }
    }
    
    func leaveRoom(roomCode: String, playerId: UUID) async throws {
        let docRef = db.collection(collectionName).document(roomCode)
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists else {
                throw RoomServiceError.roomNotFound
            }
            
            var room = try document.data(as: GameRoom.self)
            
            room.players.removeAll { $0.id == playerId }
            
            if room.players.isEmpty {
                // Delete room if no players remain
                try await docRef.delete()
            } else {
                // If moderator left, assign new moderator
                if !room.players.contains(where: { $0.isModerator }) {
                    room.players[0].isModerator = true
                }
                try docRef.setData(from: room)
            }
        } catch let error as RoomServiceError {
            throw error
        } catch {
            throw RoomServiceError.networkError(error)
        }
    }
    
    func setReady(roomCode: String, playerId: UUID, ready: Bool) async throws -> GameRoom {
        let docRef = db.collection(collectionName).document(roomCode)
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists else {
                throw RoomServiceError.roomNotFound
            }
            
            var room = try document.data(as: GameRoom.self)
            
            guard let index = room.players.firstIndex(where: { $0.id == playerId }) else {
                throw RoomServiceError.playerNotFound
            }
            
            room.players[index].isReady = ready
            
            try docRef.setData(from: room)
            
            return room
        } catch let error as RoomServiceError {
            throw error
        } catch {
            throw RoomServiceError.networkError(error)
        }
    }
    
    func startGame(roomCode: String) async throws -> GameRoom {
        let docRef = db.collection(collectionName).document(roomCode)
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists else {
                throw RoomServiceError.roomNotFound
            }
            
            var room = try document.data(as: GameRoom.self)
            
            // Validate: at least 2 players and all ready
            guard room.players.count >= 2 else {
                throw RoomServiceError.networkError(NSError(domain: "Game", code: -1, userInfo: [NSLocalizedDescriptionKey: "Need at least 2 players"]))
            }
            
            guard room.players.allSatisfy({ $0.isReady }) else {
                throw RoomServiceError.networkError(NSError(domain: "Game", code: -1, userInfo: [NSLocalizedDescriptionKey: "All players must be ready"]))
            }
            
            room.isStarted = true
            room.players = room.players.map { player in
                var copy = player
                copy.scores = [Int](repeating: 0, count: 6)
                return copy
            }
            
            try docRef.setData(from: room)
            
            // Log analytics
            FirebaseConfig.logEvent("game_started", parameters: [
                "room_code": roomCode,
                "player_count": room.players.count
            ])
            
            return room
        } catch let error as RoomServiceError {
            throw error
        } catch {
            throw RoomServiceError.networkError(error)
        }
    }
    
    func observeRoom(code: String) -> AsyncStream<GameRoom?> {
        AsyncStream { continuation in
            let docRef = db.collection(collectionName).document(code)
            
            let listener = docRef.addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("❌ Firestore listener error: \(error.localizedDescription)")
                    continuation.yield(nil)
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    continuation.yield(nil)
                    return
                }
                
                do {
                    let room = try document.data(as: GameRoom.self)
                    continuation.yield(room)
                } catch {
                    print("❌ Failed to decode GameRoom: \(error.localizedDescription)")
                    continuation.yield(nil)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func generateRoomCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
