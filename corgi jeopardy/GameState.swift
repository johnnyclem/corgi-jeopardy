import Foundation
import SpriteKit

struct Clue: Identifiable {
    enum Difficulty {
        case easy
        case medium
        case hard

        var buzzDelayRange: ClosedRange<TimeInterval> {
            switch self {
            case .easy:
                return 2.5...3.5
            case .medium:
                return 1.5...2.5
            case .hard:
                return 0.8...1.5
            }
        }

        var correctnessProbability: Double {
            switch self {
            case .easy:
                return 0.45
            case .medium:
                return 0.65
            case .hard:
                return 0.85
            }
        }
    }

    let id = UUID()
    var category: String
    var value: Int
    var question: String
    var answer: String
    var isRevealed: Bool
    var isDailyDouble: Bool
    var isDailyDooDoo: Bool
    var difficulty: Difficulty
}

enum RoundType: Int, Codable {
    case jeopardy
    case doubleJeopardy
    case finalJeopardy
}

final class GameState {
    static let shared = GameState()

    private let highScoresKey = "corgiJeopardy.highScores"

    var playerScores: [String: Int]
    var currentRound: RoundType
    var currentTurn: String
    var board: [[Clue]]
    var playerOrder: [String]
    var aiPlayers: [String]
    var playerAvatars: [String: String]
    var difficulty: Clue.Difficulty
    var lastSelectedClue: Clue?
    var wager: Int?

    private init() {
        self.playerOrder = ["Player1", "AI1"]
        self.aiPlayers = ["AI1"]
        self.playerScores = ["Player1": 0, "AI1": 0]
        self.currentRound = .jeopardy
        self.currentTurn = "Player1"
        self.board = []
        self.playerAvatars = [:]
        self.difficulty = .medium
    }

    func reset(withPlayers players: [String] = ["Player1", "AI1"]) {
        playerOrder = players
        aiPlayers = players.filter { $0.hasPrefix("AI") }
        playerScores = Dictionary(uniqueKeysWithValues: players.map { ($0, 0) })
        currentRound = .jeopardy
        currentTurn = players.first ?? "Player1"
        board = []
        wager = nil
    }

    func updateScore(player: String, amount: Int) {
        let current = playerScores[player, default: 0]
        playerScores[player] = current + amount
    }

    func rotateTurn() {
        guard let currentIndex = playerOrder.firstIndex(of: currentTurn) else { return }
        let nextIndex = playerOrder.index(after: currentIndex)
        currentTurn = playerOrder[nextIndex % playerOrder.count]
    }

    func recordHighScoreIfNeeded() {
        guard let humanScore = playerScores[playerOrder.first ?? "Player1"] else { return }
        var scores = UserDefaults.standard.array(forKey: highScoresKey) as? [Int] ?? []
        scores.append(humanScore)
        scores.sort(by: >)
        scores = Array(scores.prefix(10))
        UserDefaults.standard.set(scores, forKey: highScoresKey)
    }

    func avatarName(for player: String) -> String? {
        return playerAvatars[player]
    }
}
