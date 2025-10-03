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
    }
}
