import Foundation

/// A simple global game state model used to coordinate scores and wagers across scenes.
final class GameState {
    static let shared = GameState()

    /// Mapping of player identifiers to their scores.
    var playerScores: [String: Int]

    /// Identifier for the player whose turn it currently is.
    var currentTurn: String

    /// Stores the most recent wager placed for Daily Double style clues.
    var currentWager: Int

    private init() {
        // Provide a minimal default configuration so the app can run
        // even before real player data has been configured.
        self.playerScores = ["Player1": 0]
        self.currentTurn = "Player1"
        self.currentWager = 0
    }

    /// Convenience accessor for the active player's score.
    var currentPlayerScore: Int {
        return playerScores[currentTurn] ?? 0
    }

    /// Updates the score for a particular player by the provided amount.
    func updateScore(for player: String, by delta: Int) {
        let current = playerScores[player] ?? 0
        playerScores[player] = current + delta
    }

    /// Updates the score for the active player.
    func updateCurrentPlayerScore(by delta: Int) {
        updateScore(for: currentTurn, by: delta)
    }
}
