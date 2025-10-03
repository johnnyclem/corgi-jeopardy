import Foundation

enum RoundType: Int, Codable {
    case jeopardy
    case doubleJeopardy
    case finalJeopardy

    var next: RoundType? {
        switch self {
        case .jeopardy:
            return .doubleJeopardy
        case .doubleJeopardy:
            return .finalJeopardy
        case .finalJeopardy:
            return nil
        }
    }
}

struct Clue: Codable, Identifiable {
    let id = UUID()
    var value: Int
    var question: String
    var answer: String
    var isRevealed: Bool
    var isDailyDouble: Bool
    var isDailyDooDoo: Bool
}

final class GameState {
    private enum Constants {
        static let highScoresKey = "GameState.HighScores"
        static let maxHighScoresStored = 10
    }

    private let players: [String]
    private(set) var highScores: [Int]

    var playerScores: [String: Int]
    var currentRound: RoundType
    var currentTurn: String
    var board: [[Clue]]

    convenience init(aiPlayerCount: Int) {
        let clampedCount = max(1, min(aiPlayerCount, 2))
        var players = ["Player1"]
        for index in 1...clampedCount {
            players.append("AI\(index)")
        }
        self.init(withPlayers: players)
    }

    init(withPlayers players: [String]) {
        precondition(!players.isEmpty, "GameState requires at least one player")
        self.players = players
        self.playerScores = Dictionary(uniqueKeysWithValues: players.map { ($0, 0) })
        self.currentRound = .jeopardy
        self.currentTurn = players[0]
        self.board = GameState.generateBoard(for: .jeopardy)
        self.highScores = GameState.loadHighScores()
    }

    func reset() {
        for player in players {
            playerScores[player] = 0
        }
        currentRound = .jeopardy
        currentTurn = players[0]
        board = GameState.generateBoard(for: .jeopardy)
    }

    func updateScore(player: String, amount: Int) {
        guard playerScores[player] != nil else { return }
        playerScores[player, default: 0] += amount
        updateHighScoresIfNeeded(for: player)
    }

    func nextRound() {
        guard let nextRound = currentRound.next else { return }
        currentRound = nextRound
        board = GameState.generateBoard(for: nextRound)
    }

    func advanceTurn() {
        guard let currentIndex = players.firstIndex(of: currentTurn) else { return }
        let nextIndex = (currentIndex + 1) % players.count
        currentTurn = players[nextIndex]
    }

    func recordHighScore(for player: String) {
        let score = playerScores[player] ?? 0
        highScores.append(score)
        highScores.sort(by: >)
        if highScores.count > Constants.maxHighScoresStored {
            highScores = Array(highScores.prefix(Constants.maxHighScoresStored))
        }
        GameState.save(highScores: highScores)
    }

    private func updateHighScoresIfNeeded(for player: String) {
        let score = playerScores[player] ?? 0
        guard let bestScore = highScores.first else {
            highScores = [score]
            GameState.save(highScores: highScores)
            return
        }

        if score > bestScore {
            highScores.append(score)
            highScores.sort(by: >)
            if highScores.count > Constants.maxHighScoresStored {
                highScores = Array(highScores.prefix(Constants.maxHighScoresStored))
            }
            GameState.save(highScores: highScores)
        }
    }

    private static func generateBoard(for round: RoundType) -> [[Clue]] {
        if round == .finalJeopardy {
            let finalClue = Clue(
                value: 0,
                question: "Final Jeopardy Question",
                answer: "Final Answer",
                isRevealed: false,
                isDailyDouble: false,
                isDailyDooDoo: false
            )
            return [[finalClue]]
        }

        let rows = 5
        let columns = 6
        var clues: [[Clue]] = []

        let dailyDoublePosition = (Int.random(in: 0..<rows), Int.random(in: 0..<columns))
        var dailyDooDooPosition: (row: Int, column: Int)
        repeat {
            dailyDooDooPosition = (Int.random(in: 0..<rows), Int.random(in: 0..<columns))
        } while dailyDooDooPosition == dailyDoublePosition

        for row in 0..<rows {
            var rowClues: [Clue] = []
            for column in 0..<columns {
                let valueMultiplier = round == .doubleJeopardy ? 2 : 1
                let baseValue = 200 * (row + 1)
                let value = baseValue * valueMultiplier
                let isDailyDouble = dailyDoublePosition.row == row && dailyDoublePosition.column == column
                let isDailyDooDoo = dailyDooDooPosition.row == row && dailyDooDooPosition.column == column

                let clue = Clue(
                    value: value,
                    question: "Category \(column + 1) Question \(row + 1)",
                    answer: "Answer \(row + 1)",
                    isRevealed: false,
                    isDailyDouble: isDailyDouble,
                    isDailyDooDoo: isDailyDooDoo
                )
                rowClues.append(clue)
            }
            clues.append(rowClues)
        }

        return clues
    }

    private static func loadHighScores() -> [Int] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: Constants.highScoresKey) as? [Int] ?? []
    }

    private static func save(highScores: [Int]) {
        let defaults = UserDefaults.standard
        defaults.set(highScores, forKey: Constants.highScoresKey)
    }
}
