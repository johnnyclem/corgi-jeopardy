import Foundation

struct Clue {
    let id: UUID
    let category: String
    let value: Int
    let question: String
    let answer: String
    var isRevealed: Bool

    init(id: UUID = UUID(), category: String, value: Int, question: String, answer: String, isRevealed: Bool = false) {
        self.id = id
        self.category = category
        self.value = value
        self.question = question
        self.answer = answer
        self.isRevealed = isRevealed
    }
}

final class GameState {
    static let shared = GameState()

    enum Difficulty: String, CaseIterable {
import SpriteKit

struct Clue: Identifiable {
    enum Difficulty {
        case easy
        case medium
        case hard

        var buzzDelay: TimeInterval {
            switch self {
            case .easy:
                return 3.0
            case .medium:
                return 2.0
            case .hard:
                return 1.0
            }
        }

        var correctProbability: Double {
            switch self {
            case .easy:
                return 0.5
            case .medium:
                return 0.75
            case .hard:
                return 0.9
            }
        }
    }

    struct Player: Identifiable, Equatable {
        let id: String
        var name: String
        var isHuman: Bool
        var difficulty: Difficulty

        init(id: String, name: String, isHuman: Bool, difficulty: Difficulty) {
            self.id = id
            self.name = name
            self.isHuman = isHuman
            self.difficulty = difficulty
        }
    }

    private(set) var players: [Player]
    private(set) var playerScores: [String: Int]
    private(set) var currentTurnIndex: Int

    var currentTurn: Player {
        players[currentTurnIndex]
    }

    private init() {
        let human = Player(id: "human", name: "You", isHuman: true, difficulty: .medium)
        let aiOne = Player(id: "ai_easy", name: "Sir Barksalot", isHuman: false, difficulty: .easy)
        let aiTwo = Player(id: "ai_hard", name: "Professor Wiggles", isHuman: false, difficulty: .hard)

        players = [human, aiOne, aiTwo]
        playerScores = Dictionary(uniqueKeysWithValues: players.map { ($0.id, 0) })
        currentTurnIndex = 0
    }

    func player(withId id: String) -> Player? {
        players.first { $0.id == id }
    }

    func score(for player: Player) -> Int {
        playerScores[player.id] ?? 0
    }

    func updateScore(for player: Player, delta: Int) {
        playerScores[player.id, default: 0] += delta
    }

    func setPlayers(_ players: [Player]) {
        let existingScores = playerScores
        self.players = players
        playerScores = Dictionary(uniqueKeysWithValues: players.map { ($0.id, existingScores[$0.id] ?? 0) })
        currentTurnIndex = min(currentTurnIndex, max(players.count - 1, 0))
    }

    func setScore(_ score: Int, for player: Player) {
        playerScores[player.id] = score
    }

    func advanceTurn() {
        guard !players.isEmpty else { return }
        currentTurnIndex = (currentTurnIndex + 1) % players.count
    }

    func setCurrentTurn(to player: Player) {
        if let index = players.firstIndex(of: player) {
            currentTurnIndex = index
        }
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
//
//  GameState.swift
//  corgi jeopardy
//
//  Created as part of Ticket 2.2 to back the game board scene.
//

import Foundation

struct Clue: Identifiable {
    let id = UUID()
    let value: Int
    let question: String
    let answer: String
import Foundation

/// Centralized state management for the game. Stores player information, scoring,
/// round progression, and lightweight board data. The model is intentionally
/// simple for now but can be expanded as future tickets introduce additional
/// gameplay systems.
final class GameState {
    /// Represents the possible rounds in the game.
    enum RoundType: CaseIterable {
        case jeopardy
        case doubleJeopardy
        case finalJeopardy

        /// Provides the next round in the cycle or returns `nil` when the game is over.
        func next() -> RoundType? {
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

    /// Lightweight data representation for a clue on the board.
    struct Clue {
        let value: Int
        let question: String
        let answer: String
        var isRevealed: Bool
        var isDailyDouble: Bool
        var isDailyDooDoo: Bool
    }

    static let shared = GameState()

    /// Ordered list of players – index 0 is reserved for the human player.
    let playerOrder: [String]
    /// Convenience accessor for the primary human player identifier.
    let humanPlayerId: String
    /// The identifiers that represent AI opponents.
    let aiPlayerIds: [String]
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
    var difficulty: Difficulty
}

enum RoundType: Int, Codable {
    case jeopardy
    case doubleJeopardy
    case finalJeopardy
}

struct Category {
    let title: String
    var clues: [Clue]
}

final class GameState {
    static let shared = GameState()

    private let highScoresKey = "corgiJeopardy.highScores"
    enum RoundType {
        case jeopardy
        case doubleJeopardy
        case finalJeopardy
    }

    private(set) var playerScores: [String: Int] = [:]
    private(set) var currentRound: RoundType = .jeopardy
    private(set) var currentTurn: String = "Player1"
    private(set) var board: [Category] = []

    private init() {
        resetBoard()
    }

    func resetBoard() {
        board = GameState.generateDefaultBoard(for: currentRound)
    }

    func clue(atColumn column: Int, row: Int) -> Clue? {
        guard board.indices.contains(column), board[column].clues.indices.contains(row) else {
            return nil
        }
        return board[column].clues[row]
    }

    func markClueRevealed(atColumn column: Int, row: Int) {
        guard board.indices.contains(column), board[column].clues.indices.contains(row) else { return }
        board[column].clues[row].isRevealed = true
    }

    private static func generateDefaultBoard(for round: RoundType) -> [Category] {
        let baseValues = [200, 400, 600, 800, 1000]
        let categories = [
            "Corgi Breeds",
            "Dog Tricks",
            "Famous Pups",
            "Paw-some Places",
            "Treats & Eats",
            "Tail Tales"
        ]

        return categories.map { title in
            let clues = baseValues.enumerated().map { rowIndex, value -> Clue in
                let multiplier = (round == .doubleJeopardy) ? 2 : 1
                let adjustedValue = value * multiplier
                return Clue(
                    value: adjustedValue,
                    question: "Placeholder question #\(rowIndex + 1) for \(title).",
                    answer: "Placeholder answer",
                    isRevealed: false,
                    isDailyDouble: false,
                    isDailyDooDoo: false
                )
            }
            return Category(title: title, clues: clues)
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

    /// Mapping of player identifier to avatar image name.
    var playerAvatars: [String: String]

    private(set) var highScores: [Int]

    /// All available avatar texture names in the project.
    let availableAvatarNames: [String] = [
        "corgi1.png",
        "corgi2.png",
        "corgi3.png",
        "corgi4.png",
        "corgi5.png"
    ]

    private let highScoresKey = "HighScores"

    private init() {
        // Default players – can be customized in future tickets.
        let defaultPlayers = ["Player1", "AI1", "AI2"]
        playerOrder = defaultPlayers
        humanPlayerId = defaultPlayers.first ?? "Player1"
        aiPlayerIds = Array(defaultPlayers.dropFirst())

        playerScores = Dictionary(uniqueKeysWithValues: defaultPlayers.map { ($0, 0) })
        currentRound = .jeopardy
        currentTurn = humanPlayerId
        board = []
        playerAvatars = [:]

        highScores = UserDefaults.standard.array(forKey: highScoresKey) as? [Int] ?? []

        assignDefaultAvatars()
    }

    /// Resets the entire game state back to its initial configuration.
    func reset() {
        for playerId in playerOrder {
            playerScores[playerId] = 0
        }
        currentRound = .jeopardy
        currentTurn = humanPlayerId
        board.removeAll()
        assignDefaultAvatars()
    }

    /// Updates the score for a specific player by the provided delta.
    func updateScore(player: String, amount: Int) {
        let existing = playerScores[player] ?? 0
        playerScores[player] = existing + amount
    }

    /// Progresses the game to the next round, if available.
    func nextRound() {
        if let next = currentRound.next() {
            currentRound = next
        }
    }

    /// Records a new high score entry.
    func recordHighScore(_ score: Int) {
        highScores.append(score)
        highScores.sort(by: >)
        highScores = Array(highScores.prefix(10))
        UserDefaults.standard.set(highScores, forKey: highScoresKey)
    }

    /// Ensures AI opponents have avatar assignments, generating random ones if necessary.
    func ensureAIAvatarsAssigned() {
        let humanAvatar = playerAvatars[humanPlayerId]
        let excluded = humanAvatar.map { [$0] } ?? []
        let requiresAssignment = aiPlayerIds.contains { playerAvatars[$0] == nil }
        if requiresAssignment {
            assignRandomAvatarsToAI(excluding: excluded)
        }
    }

    /// Updates the stored avatar for a specific player.
    func setAvatar(_ imageName: String, for player: String) {
        playerAvatars[player] = imageName
    }

    /// Returns the avatar name for a player, falling back to a default if needed.
    func avatarName(for player: String) -> String {
        if let stored = playerAvatars[player] {
            return stored
        }
        // Provide a deterministic fallback to keep UI stable.
        if player == humanPlayerId {
            return availableAvatarNames.first ?? "corgi1.png"
        }
        // Assign random avatar on the fly for AI opponents if missing.
        assignRandomAvatarsToAI(excluding: Array(Set(playerAvatars.values)))
        return playerAvatars[player] ?? availableAvatarNames.first ?? "corgi1.png"
    }

    /// Assigns random avatars to AI opponents, optionally avoiding a collection of names.
    func assignRandomAvatarsToAI(excluding excludedNames: [String]) {
        var pool = availableAvatarNames.filter { !excludedNames.contains($0) }
        if pool.isEmpty {
            pool = availableAvatarNames
        }

        for aiId in aiPlayerIds {
            if pool.isEmpty {
                pool = availableAvatarNames
            }
            let avatar = pool.randomElement() ?? availableAvatarNames.first ?? "corgi1.png"
            playerAvatars[aiId] = avatar
            if let index = pool.firstIndex(of: avatar) {
                pool.remove(at: index)
            }
        }
    }

    /// Assigns a default avatar to the human player and random avatars to AI opponents.
    private func assignDefaultAvatars() {
        let defaultAvatar = availableAvatarNames.first ?? "corgi1.png"
        playerAvatars[humanPlayerId] = defaultAvatar
        assignRandomAvatarsToAI(excluding: [defaultAvatar])
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
