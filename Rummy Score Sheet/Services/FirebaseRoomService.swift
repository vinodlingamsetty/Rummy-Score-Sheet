//
//  FirebaseRoomService.swift
//  Rummy Scorekeeper
//
//  Firebase Firestore implementation of RoomService with real-time sync.
//  Note: Moderator-only actions (startGame, endGame, etc.) are not enforced here;
//  Firestore security rules must enforce authorization server-side.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseRoomService: RoomService, @unchecked Sendable {
    
    private let db = Firestore.firestore()
    private let collectionName = "gameRooms"
    
    // MARK: - RoomService Implementation
    
    func createRoom(pointLimit: Int, pointValue: Int) async throws -> RoomServiceResult {
        // Ensure auth is complete
        await FirebaseConfig.ensureAuthenticated()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RoomServiceError.networkError(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
        }
        
        let code = generateRoomCode()
        let moderatorId = UUID()
        let moderator = Player(
            id: moderatorId,
            name: FirebaseConfig.getUserDisplayName(),
            isReady: true,
            isModerator: true,
            scores: [],
            userId: userId,
            email: Auth.auth().currentUser?.email
        )
        
        let room = GameRoom(
            id: code,
            pointLimit: pointLimit,
            pointValue: pointValue,
            players: [moderator],
            currentRound: 1,
            isStarted: false,
            createdAt: Date(),
            createdBy: userId,
            participantIds: [userId]
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
        await FirebaseConfig.ensureAuthenticated()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RoomServiceError.networkError(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
        }
        
        let normalizedCode = code.uppercased()
        let docRef = db.collection(collectionName).document(normalizedCode)
        let playerId = UUID()
        
        return try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                document = try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard document.exists else {
                let error = RoomServiceError.roomNotFound as NSError
                errorPointer?.pointee = error
                return nil
            }
            
            var room: GameRoom
            do {
                room = try document.data(as: GameRoom.self)
            } catch let decodeError as NSError {
                errorPointer?.pointee = decodeError
                return nil
            }
            
            if room.players.count >= 10 {
                let error = RoomServiceError.roomFull as NSError
                errorPointer?.pointee = error
                return nil
            }
            
            let player = Player(
                id: playerId,
                name: playerName,
                isReady: false,
                isModerator: false,
                scores: [], 
                userId: userId,
                email: Auth.auth().currentUser?.email
            )
            
            room.players.append(player)
            
            if var currentIds = room.participantIds {
                if !currentIds.contains(userId) {
                    currentIds.append(userId)
                    room.participantIds = currentIds
                }
            } else {
                room.participantIds = room.players.compactMap { $0.userId }
            }
            
            do {
                try transaction.setData(from: room, forDocument: docRef)
            } catch let writeError as NSError {
                errorPointer?.pointee = writeError
                return nil
            }
            
            return RoomServiceResult(room: room, currentUserId: playerId)
        } as! RoomServiceResult
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
                copy.scores = [] // Start with empty scores - user must enter explicitly
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
    
    func updatePlayerScore(roomCode: String, playerId: UUID, score: Int, round: Int) async throws -> GameRoom {
        await FirebaseConfig.ensureAuthenticated()
        let normalizedCode = roomCode.uppercased().trimmingCharacters(in: .whitespaces)
        let docRef = db.collection(collectionName).document(normalizedCode)
        
        return try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                document = try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard document.exists else {
                let error = RoomServiceError.roomNotFound as NSError
                errorPointer?.pointee = error
                return nil
            }
            
            var room: GameRoom
            do {
                room = try document.data(as: GameRoom.self)
            } catch let decodeError as NSError {
                errorPointer?.pointee = decodeError
                return nil
            }
            
            guard let playerIndex = room.players.firstIndex(where: { $0.id == playerId }) else {
                let error = RoomServiceError.playerNotFound as NSError
                errorPointer?.pointee = error
                return nil
            }
            
            let roundIndex = round - 1
            if room.players[playerIndex].scores.count <= roundIndex {
                room.players[playerIndex].scores.append(contentsOf: [Int](repeating: 0, count: roundIndex - room.players[playerIndex].scores.count + 1))
            }
            room.players[playerIndex].scores[roundIndex] = score
            
            do {
                try transaction.setData(from: room, forDocument: docRef)
            } catch let writeError as NSError {
                errorPointer?.pointee = writeError
                return nil
            }
            
            return room
        } as! GameRoom
    }
    
    func nextRound(roomCode: String) async throws -> GameRoom {
        await FirebaseConfig.ensureAuthenticated()
        let normalizedCode = roomCode.uppercased().trimmingCharacters(in: .whitespaces)
        let docRef = db.collection(collectionName).document(normalizedCode)
        
        return try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                document = try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var room: GameRoom
            do {
                room = try document.data(as: GameRoom.self)
            } catch let decodeError as NSError {
                errorPointer?.pointee = decodeError
                return nil
            }
            
            room.currentRound += 1
            
            do {
                try transaction.setData(from: room, forDocument: docRef)
            } catch let writeError as NSError {
                errorPointer?.pointee = writeError
                return nil
            }
            
            return room
        } as! GameRoom
    }
    
    func endGame(roomCode: String, winnerId: UUID?) async throws -> GameRoom {
        await FirebaseConfig.ensureAuthenticated()
        let normalizedCode = roomCode.uppercased().trimmingCharacters(in: .whitespaces)
        let docRef = db.collection(collectionName).document(normalizedCode)
        
        return try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                document = try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var room: GameRoom
            do {
                room = try document.data(as: GameRoom.self)
            } catch let decodeError as NSError {
                errorPointer?.pointee = decodeError
                return nil
            }
            
            room.isCompleted = true
            room.endedAt = Date()
            room.winnerId = winnerId?.uuidString
            
            // If voiding (no winner), zero out all scores
            if winnerId == nil {
                room.players = room.players.map { player in
                    var copy = player
                    copy.scores = []
                    return copy
                }
            }
            
            // Final safety update of participant IDs
            room.participantIds = Array(Set((room.participantIds ?? []) + room.players.compactMap { $0.userId }))
            
            do {
                try transaction.setData(from: room, forDocument: docRef)
            } catch let writeError as NSError {
                errorPointer?.pointee = writeError
                return nil
            }
            
            return room
        } as! GameRoom
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
    
    /// Generates a 6-character room code. Excludes ambiguous chars (0,O,1,I).
    private func generateRoomCode() -> String {
        let chars = AppConstants.RoomCode.characters
        return String((0..<AppConstants.RoomCode.length).compactMap { _ in chars.randomElement() })
    }
}
