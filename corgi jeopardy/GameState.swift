import Foundation

/// Centralized model responsible for tracking players, scores, round
/// progression, and the Jeopardy-style board for the game.  The state object is
/// intentionally feature rich so that SpriteKit scenes can focus on
/// presentation logic while tests can validate the core rules independently of
/// rendering.
final class GameState {
    // MARK: - Nested Types

    enum Round: Int, CaseIterable {
        case jeopardy
        case doubleJeopardy
        case finalJeopardy

        var displayName: String {
            switch self {
            case .jeopardy:
                return "Jeopardy!"
            case .doubleJeopardy:
                return "Double Jeopardy!"
            case .finalJeopardy:
                return "Final Jeopardy!"
            }
        }

        /// Returns the round that follows the current one, if any.
        var next: Round? {
            switch self {
            case .jeopardy:
                return .doubleJeopardy
            case .doubleJeopardy:
                return .finalJeopardy
            case .finalJeopardy:
                return nil
            }
        }

        /// Multiplier applied to the standard clue values.
        var valueMultiplier: Int {
            switch self {
            case .jeopardy:
                return 1
            case .doubleJeopardy:
                return 2
            case .finalJeopardy:
                return 0
            }
        }
    }

    enum AIDifficulty: CaseIterable {
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
                return 0.8...1.4
            }
        }

        var correctnessProbability: Double {
            switch self {
            case .easy:
                return 0.45
            case .medium:
                return 0.7
            case .hard:
                return 0.9
            }
        }
    }

    struct Player: Identifiable, Equatable {
        let id: String
        var displayName: String
        var isHuman: Bool
        var difficulty: AIDifficulty?

        init(id: String, displayName: String, isHuman: Bool, difficulty: AIDifficulty?) {
            self.id = id
            self.displayName = displayName
            self.isHuman = isHuman
            self.difficulty = difficulty
        }
    }

    struct Category {
        let title: String
        let isDogCategory: Bool
        var clues: [Clue]
    }

    struct Clue: Identifiable {
        let id: UUID
        let category: String
        var value: Int
        var question: String
        var answer: String
        var isRevealed: Bool
        var isDailyDouble: Bool
        var isDailyDooDoo: Bool

        init(id: UUID = UUID(), category: String, value: Int, question: String, answer: String, isRevealed: Bool = false, isDailyDouble: Bool = false, isDailyDooDoo: Bool = false) {
            self.id = id
            self.category = category
            self.value = value
            self.question = question
            self.answer = answer
            self.isRevealed = isRevealed
            self.isDailyDouble = isDailyDouble
            self.isDailyDooDoo = isDailyDooDoo
        }
    }

    struct WagerContext {
        enum Kind {
            case dailyDouble(max: Int)
            case dailyDooDoo(opponent: Player, max: Int)
        }

        let clue: Clue
        let kind: Kind
    }

    struct WagerResolution {
        enum Kind {
            case dailyDouble
            case dailyDooDoo
        }

        let kind: Kind
        let affectedPlayer: Player
        let delta: Int
    }

    private enum Constants {
        static let highScoresKey = "corgiJeopardy.highScores"
        static let maxStoredHighScores = 10
        static let defaultAvatars = ["corgi1", "corgi2", "corgi3", "corgi4", "corgi5"]
    }

    private enum WagerKind {
        case dailyDouble(playerId: String)
        case dailyDooDoo(opponentId: String)
    }

    // MARK: - Singleton

    static let shared = GameState()

    // MARK: - Stored Properties

    private(set) var players: [Player]
    private(set) var scores: [String: Int]
    private(set) var currentPlayerIndex: Int
    private(set) var currentRound: Round
    private(set) var board: [Category]
    private(set) var highScores: [Int]

    var playerAvatars: [String: String]
    var lastSelectedClue: Clue?

    private var rng = SystemRandomNumberGenerator()
    private var activeWager: (clueId: UUID, kind: WagerKind, amount: Int)?

    // MARK: - Initialisation

    init(players: [Player]? = nil) {
        let defaultPlayers = players ?? GameState.makeDefaultPlayers()
        self.players = defaultPlayers
        self.scores = Dictionary(uniqueKeysWithValues: defaultPlayers.map { ($0.id, 0) })
        self.currentPlayerIndex = 0
        self.currentRound = .jeopardy
        self.board = []
        self.playerAvatars = [:]
        self.lastSelectedClue = nil

        if let storedScores = UserDefaults.standard.array(forKey: Constants.highScoresKey) as? [Int] {
            self.highScores = storedScores
        } else {
            self.highScores = []
        }

        regenerateBoard()
    }

    // MARK: - Player Convenience

    private static func makeDefaultPlayers() -> [Player] {
        [
            Player(id: "human", displayName: "You", isHuman: true, difficulty: nil),
            Player(id: "ai_easy", displayName: "Sir Barksalot", isHuman: false, difficulty: .easy),
            Player(id: "ai_hard", displayName: "Professor Wiggles", isHuman: false, difficulty: .hard)
        ]
    }

    var playerOrder: [String] {
        players.map { $0.id }
    }

    var humanPlayerId: String {
        players.first(where: { $0.isHuman })?.id ?? players[0].id
    }

    var aiPlayerIds: [String] {
        players.filter { !$0.isHuman }.map { $0.id }
    }

    var playerScores: [String: Int] {
        scores
    }

    var currentPlayer: Player {
        players[currentPlayerIndex]
    }

    var currentPlayerScore: Int {
        scores[currentPlayer.id, default: 0]
    }

    var score: Int {
        scores[humanPlayerId, default: 0]
    }

    var availableAvatarNames: [String] {
        Constants.defaultAvatars
    }

    func avatarName(for playerId: String) -> String {
        playerAvatars[playerId] ?? availableAvatarNames.first ?? "corgi"
    }

    func setAvatar(_ name: String, for playerId: String) {
        playerAvatars[playerId] = name
    }

    func assignRandomAvatarsToAI(excluding excludedNames: [String] = []) {
        let pool = availableAvatarNames.filter { !excludedNames.contains($0) }
        var iterator = pool.makeIterator()
        for player in players where !player.isHuman {
            if let avatar = iterator.next() {
                playerAvatars[player.id] = avatar
            }
        }
    }

    func ensureAIAvatarsAssigned() {
        var unused = availableAvatarNames.filter { name in
            !playerAvatars.values.contains(name)
        }
        for player in players where !player.isHuman {
            if playerAvatars[player.id] == nil {
                if unused.isEmpty {
                    unused = availableAvatarNames
                }
                playerAvatars[player.id] = unused.removeFirst()
            }
        }
    }

    // MARK: - Board Management

    func regenerateBoard() {
        board = BoardGenerator.generateBoard(for: currentRound, using: &rng)
    }

    func clue(atColumn column: Int, row: Int) -> Clue? {
        guard board.indices.contains(column) else { return nil }
        guard board[column].clues.indices.contains(row) else { return nil }
        return board[column].clues[row]
    }

    func markClueRevealed(atColumn column: Int, row: Int) {
        guard board.indices.contains(column), board[column].clues.indices.contains(row) else { return }
        board[column].clues[row].isRevealed = true
    }

    var allCluesRevealed: Bool {
        board.flatMap { $0.clues }.allSatisfy { $0.isRevealed }
    }

    // MARK: - Round Progression

    @discardableResult
    func advanceToNextRound() -> Round {
        if let next = currentRound.next() {
            currentRound = next
            if next != .finalJeopardy {
                regenerateBoard()
            } else {
                board = []
            }
        }
        return currentRound
    }

    func resetForNewGame() {
        scores = Dictionary(uniqueKeysWithValues: players.map { ($0.id, 0) })
        currentPlayerIndex = 0
        currentRound = .jeopardy
        activeWager = nil
        lastSelectedClue = nil
        regenerateBoard()
    }

    func advanceTurn() {
        guard !players.isEmpty else { return }
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }

    // MARK: - Scoring

    func updateScore(playerId: String, delta: Int) {
        scores[playerId, default: 0] += delta
    }

    func updateScore(for player: Player, delta: Int) {
        updateScore(playerId: player.id, delta: delta)
    }

    func updateCurrentPlayerScore(by delta: Int) {
        updateScore(playerId: currentPlayer.id, delta: delta)
    }

    func score(for player: Player) -> Int {
        scores[player.id, default: 0]
    }

    var orderedPlayersByScore: [Player] {
        players.sorted { score(for: $0) > score(for: $1) }
    }

    var winningPlayer: Player? {
        orderedPlayersByScore.first
    }

    func updateHighScoreIfNeededForHumanWin() -> Bool {
        guard let winner = winningPlayer, winner.id == humanPlayerId else {
            return false
        }
        let humanScore = score(for: winner)
        var updated = highScores
        updated.append(humanScore)
        updated.sort(by: >)
        if updated.count > Constants.maxStoredHighScores {
            updated = Array(updated.prefix(Constants.maxStoredHighScores))
        }
        let changed = updated != highScores
        if changed {
            highScores = updated
            UserDefaults.standard.set(updated, forKey: Constants.highScoresKey)
        }
        return changed
    }

    // MARK: - Trivia Helpers

    func validateAnswer(_ answer: String, correctAnswer: String) -> Bool {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return false }

        let validPrefixes = [
            "what is", "who is", "where is",
            "what are", "who are", "where are"
        ]
        guard validPrefixes.contains(where: { trimmed.hasPrefix($0) }) else {
            return false
        }

        let sanitizedAnswer = correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.contains(sanitizedAnswer)
    }

    func updateScore(for clueValue: Int, isCorrect: Bool, isWager: Bool = false) {
        let positiveValue = max(0, clueValue)
        if isWager {
            let maxWager = max(score, 0)
            let applied = min(positiveValue, maxWager)
            let delta = isCorrect ? applied : -applied
            updateScore(playerId: humanPlayerId, delta: delta)
        } else {
            let delta = isCorrect ? positiveValue : -positiveValue
            updateScore(playerId: humanPlayerId, delta: delta)
        }
    }

    func generateBoard(categoryCount: Int, using generator: inout RandomNumberGenerator) {
        board = BoardGenerator.generateBoard(for: currentRound, categoryCount: categoryCount, using: &generator)
    }

    // MARK: - Wager Logic

    func wagerContext(for clue: Clue) -> WagerContext? {
        if clue.isDailyDouble {
            return WagerContext(clue: clue, kind: .dailyDouble(max: max(currentPlayerScore, 0)))
        }

        if clue.isDailyDooDoo, let opponent = selectDailyDooDooOpponent() {
            let opponentScore = max(score(for: opponent), 0)
            return WagerContext(clue: clue, kind: .dailyDooDoo(opponent: opponent, max: opponentScore))
        }

        return nil
    }

    func setActiveWager(amount: Int, for context: WagerContext) {
        let sanitizedAmount: Int
        switch context.kind {
        case let .dailyDouble(maxAmount):
            sanitizedAmount = min(max(amount, 0), maxAmount)
            activeWager = (context.clue.id, .dailyDouble(playerId: currentPlayer.id), sanitizedAmount)
        case let .dailyDooDoo(opponent, maxAmount):
            sanitizedAmount = min(max(amount, 0), maxAmount)
            activeWager = (context.clue.id, .dailyDooDoo(opponentId: opponent.id), sanitizedAmount)
        }
    }

    var wager: Int? {
        activeWager?.amount
    }

    func resolveActiveWager(isCorrect: Bool) -> WagerResolution? {
        guard let activeWager else { return nil }
        let resolution: WagerResolution
        switch activeWager.kind {
        case let .dailyDouble(playerId):
            let delta = isCorrect ? activeWager.amount : -activeWager.amount
            updateScore(playerId: playerId, delta: delta)
            let player = player(withId: playerId) ?? currentPlayer
            resolution = WagerResolution(kind: .dailyDouble, affectedPlayer: player, delta: delta)
        case let .dailyDooDoo(opponentId):
            let delta = isCorrect ? -activeWager.amount : activeWager.amount
            updateScore(playerId: opponentId, delta: delta)
            let player = player(withId: opponentId) ?? players.first { !$0.isHuman } ?? currentPlayer
            resolution = WagerResolution(kind: .dailyDooDoo, affectedPlayer: player, delta: delta)
        }
        self.activeWager = nil
        return resolution
    }

    func clearWager() {
        activeWager = nil
    }

    // MARK: - Private Helpers

    private func selectDailyDooDooOpponent() -> Player? {
        players.filter { !$0.isHuman }.sorted { score(for: $0) > score(for: $1) }.first
    }

    func player(for id: String) -> Player? {
        players.first { $0.id == id }
    }

    private func player(withId id: String) -> Player? {
        player(for: id)
    }
}
