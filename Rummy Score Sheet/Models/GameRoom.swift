//
//  GameRoom.swift
//  Rummy Scorekeeper
//
//  Room and Player data models for game sessions
//

import Foundation

struct GameRoom: Identifiable, Codable {
    let id: String           // 6-char room code (e.g., "A1B2C3")
    let pointLimit: Int
    let pointValue: Int
    var players: [Player]
    var currentRound: Int
    var isStarted: Bool
    var createdAt: Date?     // Firebase timestamp
    var createdBy: String?   // Firebase user ID
    
    // Game completion tracking
    var isCompleted: Bool = false
    var endedAt: Date?       // When the game ended
    var winnerId: String?    // Winner's player ID (UUID as String)
    var participantIds: [String]? // Firebase Auth UIDs of all participants
    
    // Computed properties
    var winner: Player? {
        guard let winnerId = winnerId else { return nil }
        return players.first { $0.id.uuidString == winnerId }
    }
}

struct Player: Identifiable, Codable {
    let id: UUID
    let name: String
    var isReady: Bool
    var isModerator: Bool
    var scores: [Int]        // Score per round
    var userId: String?      // Firebase Auth UID; used for Friends (nil for legacy players)
    var email: String?       // Player's email address
    
    var totalScore: Int {
        scores.reduce(0, +)
    }
    
    // Custom coding keys for Firestore (UUID as String)
    enum CodingKeys: String, CodingKey {
        case id, name, isReady, isModerator, scores, userId, email
    }
    
    init(id: UUID, name: String, isReady: Bool, isModerator: Bool, scores: [Int], userId: String? = nil, email: String? = nil) {
        self.id = id
        self.name = name
        self.isReady = isReady
        self.isModerator = isModerator
        self.scores = scores
        self.userId = userId
        self.email = email
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.isReady = try container.decode(Bool.self, forKey: .isReady)
        self.isModerator = try container.decode(Bool.self, forKey: .isModerator)
        self.scores = try container.decode([Int].self, forKey: .scores)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isReady, forKey: .isReady)
        try container.encode(isModerator, forKey: .isModerator)
        try container.encode(scores, forKey: .scores)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(email, forKey: .email)
    }
}

enum PlayerReadyState {
    case waiting
    case ready
}
