import Foundation

/// A lightweight model that keeps track of scores and player metadata for the Jeopardy flow.
final class GameState {
    static let shared = GameState()

    enum RoundType: Int {
        case jeopardy
        case doubleJeopardy
        case finalJeopardy
    }

    struct Player: Hashable {
        let id: String
        let displayName: String
        let isHuman: Bool
    }

    private(set) var players: [Player]
    private(set) var playerScores: [String: Int]
    var currentRound: RoundType

    private let highScoreKey = "HighScore"

    private init() {
        players = [
            Player(id: "human", displayName: "You", isHuman: true),
            Player(id: "ai_corgi", displayName: "AI Corgi", isHuman: false)
        ]
        playerScores = [:]
        currentRound = .jeopardy
        resetScores()
    }

    func resetForNewGame() {
        currentRound = .jeopardy
        resetScores()
    }

    func resetScores() {
        for player in players {
            playerScores[player.id] = 0
        }
    }

    func score(for player: Player) -> Int {
        playerScores[player.id] ?? 0
    }

    func setScore(_ score: Int, for player: Player) {
        playerScores[player.id] = score
    }

    func updateScore(for playerID: String, delta: Int) {
        playerScores[playerID, default: 0] += delta
    }

    var humanPlayer: Player? {
        players.first { $0.isHuman }
    }

    var orderedPlayersByScore: [Player] {
        players.sorted { score(for: $0) > score(for: $1) }
    }

    var winningPlayer: Player? {
        orderedPlayersByScore.first
    }

    var savedHighScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }

    /// Returns `true` if the stored high score was updated.
    @discardableResult
    func updateHighScoreIfNeededForHumanWin() -> Bool {
        guard let winner = winningPlayer, let human = humanPlayer, winner.id == human.id else {
            return false
        }

        let humanScore = score(for: human)
        if humanScore > savedHighScore {
            savedHighScore = humanScore
            return true
        }
        return false
    }
}
