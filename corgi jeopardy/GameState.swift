import Foundation
import SpriteKit

/// Global game state container for Corgi Jeopardy.
/// Stores player order, scores, and data needed for wager-based specials.
final class GameState {
    enum RoundType {
        case jeopardy
        case doubleJeopardy
        case finalJeopardy
    }

    enum WagerType {
        case dailyDouble
        case dailyDooDoo
    }

    struct Player: Equatable {
        let id: String
        var displayName: String { id }
    }

    struct WagerContext {
        let wageringPlayer: Player
        let type: WagerType
        let amount: Int
        let opponent: Player?
    }

    static let shared = GameState()

    private(set) var players: [Player]
    private(set) var playerScores: [String: Int]
    private(set) var currentTurnIndex: Int
    private(set) var currentRound: RoundType
    private var activeWager: WagerContext?

    private init() {
        let defaultPlayers = [Player(id: "Player1"), Player(id: "AI1")]
        self.players = defaultPlayers
        self.playerScores = Dictionary(uniqueKeysWithValues: defaultPlayers.map { ($0.id, 0) })
        self.currentTurnIndex = 0
        self.currentRound = .jeopardy
    }

    var currentPlayer: Player { players[currentTurnIndex] }

    func score(for player: Player) -> Int {
        playerScores[player.id, default: 0]
    }

    func updateScore(for player: Player, by delta: Int) {
        let updated = score(for: player) + delta
        playerScores[player.id] = updated
    }

    func setScore(_ value: Int, for player: Player) {
        playerScores[player.id] = value
    }

    func setActiveWager(amount: Int, type: WagerType, opponent: Player? = nil) {
        activeWager = WagerContext(wageringPlayer: currentPlayer, type: type, amount: amount, opponent: opponent)
    }

    func clearActiveWager() {
        activeWager = nil
    }

    /// Applies the stored wager after the clue is answered.
    /// - Parameter isCorrect: Outcome of the player's answer.
    /// - Returns: Tuple describing the affected player and score change for UI updates.
    @discardableResult
    func resolveActiveWager(isCorrect: Bool) -> (affectedPlayer: Player, delta: Int, type: WagerType)? {
        guard let context = activeWager else { return nil }
        defer { activeWager = nil }

        switch context.type {
        case .dailyDouble:
            let delta = isCorrect ? context.amount : -context.amount
            updateScore(for: context.wageringPlayer, by: delta)
            return (context.wageringPlayer, delta, context.type)
        case .dailyDooDoo:
            guard let opponent = context.opponent ?? defaultDailyDooDooOpponent(excluding: context.wageringPlayer) else {
                return nil
            }
            let delta = isCorrect ? -context.amount : context.amount
            updateScore(for: opponent, by: delta)
            return (opponent, delta, context.type)
        }
    }

    /// Selects a default opponent for Daily Doo-Doo if none was supplied.
    /// Strategy: choose the opponent with the highest score (best potential loss), breaking ties alphabetically.
    func defaultDailyDooDooOpponent(excluding wageringPlayer: Player) -> Player? {
        let candidates = players.filter { $0 != wageringPlayer }
        guard !candidates.isEmpty else { return nil }
        return candidates.max { lhs, rhs in
            let lhsScore = score(for: lhs)
            let rhsScore = score(for: rhs)
            if lhsScore == rhsScore {
                return lhs.id < rhs.id
            }
            return lhsScore < rhsScore
        }
    }

    /// Maximum wager allowed for Daily Doo-Doo based on opponent score.
    func maxDailyDooDooWager(against opponent: Player?) -> Int {
        let target = opponent ?? defaultDailyDooDooOpponent(excluding: currentPlayer)
        guard let opponentPlayer = target else { return 0 }
        return max(score(for: opponentPlayer), 0)
    }
}
