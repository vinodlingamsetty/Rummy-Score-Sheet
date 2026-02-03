//
//  GameRoom.swift
//  Rummy Scorekeeper
//
//  Room and Player data models for game sessions
//

import Foundation

struct GameRoom: Identifiable {
    let id: String           // 6-char room code (e.g., "A1B2C3")
    let pointLimit: Int
    let pointValue: Int
    var players: [Player]
    var currentRound: Int
    var isStarted: Bool
}

struct Player: Identifiable {
    let id: UUID
    let name: String
    var isReady: Bool
    var isModerator: Bool
    var scores: [Int]        // Score per round
    
    var totalScore: Int {
        scores.reduce(0, +)
    }
}

enum PlayerReadyState {
    case waiting
    case ready
}
