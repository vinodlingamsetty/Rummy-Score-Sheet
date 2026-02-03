//
//  GameViewModel.swift
//  Rummy Scorekeeper
//
//  Manages active game state, rounds, and scores
//

import Foundation

@Observable
final class GameViewModel {
    var room: GameRoom
    var currentUserId: UUID?

    var currentRoundScore: Int {
        room.currentRound - 1
    }

    var roundCount: Int {
        6
    }

    var sortedPlayers: [Player] {
        room.players.sorted { ($0.totalScore, $0.name) > ($1.totalScore, $1.name) }
    }

    init(room: GameRoom, currentUserId: UUID? = nil) {
        self.room = room
        self.currentUserId = currentUserId
    }

    func score(for playerId: UUID, round: Int) -> Int {
        guard let player = room.players.first(where: { $0.id == playerId }),
              round >= 0, round < player.scores.count else { return 0 }
        return player.scores[round]
    }

    func selectRound(_ round: Int) {
        room.currentRound = min(max(1, round), roundCount)
    }

    func addScores(_ scores: [UUID: Int]) {
        for (playerId, score) in scores {
            guard let index = room.players.firstIndex(where: { $0.id == playerId }) else { continue }
            let roundIndex = room.currentRound - 1
            if room.players[index].scores.count <= roundIndex {
                room.players[index].scores.append(contentsOf: [Int](repeating: 0, count: roundIndex - room.players[index].scores.count + 1))
            }
            if roundIndex < room.players[index].scores.count {
                room.players[index].scores[roundIndex] = score
            }
        }
    }
}
