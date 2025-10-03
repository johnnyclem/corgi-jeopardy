import Foundation

enum RoundType: Int, CaseIterable {
    case jeopardy
    case doubleJeopardy
    case finalJeopardy

    var baseClueValue: Int {
        switch self {
        case .jeopardy:
            return 200
        case .doubleJeopardy:
            return 400
        case .finalJeopardy:
            return 0
        }
    }

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
}

struct Clue {
    let category: String
    let prompt: String
    let response: String
    var value: Int
    var isRevealed: Bool
    var isDailyDouble: Bool
    var isDailyDooDoo: Bool
}

struct CategoryBoard {
    let title: String
    var clues: [Clue]
}

final class GameState {
    static let shared = GameState()

    private(set) var playerScores: [String: Int] = ["Player1": 0, "AI1": 0]
    private(set) var currentRound: RoundType = .jeopardy
    private(set) var board: [CategoryBoard] = []

    private let generalCategories: [String: [String]] = [
        "History": [
            "This ancient civilization built the pyramids.",
            "He crossed the Delaware on Christmas night in 1776.",
            "The war that ended with the Treaty of Versailles.",
            "He wrote the 95 Theses in 1517.",
            "This wall fell in 1989, reuniting a European city."
        ],
        "Science": [
            "The powerhouse of the cell.",
            "This planet is known as the Red Planet.",
            "He developed the theory of relativity.",
            "The chemical symbol for gold.",
            "Number of bones in the adult human body (approximate)."
        ],
        "Literature": [
            "He wrote 'Romeo and Juliet'.",
            "This novel features the character Atticus Finch.",
            "Author of '1984'.",
            "The poet who wrote 'The Raven'.",
            "Greek author of 'The Odyssey'."
        ],
        "Geography": [
            "The longest river in the world.",
            "This country is both an island and a continent.",
            "The mountain range containing Mount Everest.",
            "Capital city of Canada.",
            "This desert covers much of northern Africa."
        ]
    ]

    private let dogCategories: [String: [String]] = [
        "Corgi Facts": [
            "This is the country where corgis originated.",
            "Corgis famously worked as this type of dog on farms.",
            "The Queen of England favored this breed.",
            "This corgi feature makes them look like loaves of bread.",
            "Corgi tails are often described as this baked good." 
        ],
        "Paw-some Puns": [
            "A corgi's favorite sci-fi series might be called this.",
            "When a corgi relaxes on the beach, it's soaking up this.",
            "A corgi detective solves cases using this sense.",
            "Corgi math class is all about learning this kind of angle.",
            "The corgi musician plays this instrument with a wag."
        ],
        "Doggy Delights": [
            "A corgi's favorite frozen treat on a hot day.",
            "This chew toy makes every corgi go wild.",
            "The holiday where corgis wear costumes.",
            "A corgi birthday cake is topped with this candle substitute.",
            "This is the best topping for a corgi pizza night."
        ]
    ]

    private init() {
        generateBoard(for: currentRound)
    }

    func reset(players: [String] = ["Player1", "AI1"]) {
        playerScores = players.reduce(into: [:]) { result, player in
            result[player] = 0
        }
        currentRound = .jeopardy
        generateBoard(for: currentRound)
    }

    func updateScore(player: String, delta: Int) {
        guard playerScores[player] != nil else { return }
        playerScores[player]! += delta
    }

    func markClueRevealed(categoryIndex: Int, clueIndex: Int) {
        guard board.indices.contains(categoryIndex) else { return }
        guard board[categoryIndex].clues.indices.contains(clueIndex) else { return }
        board[categoryIndex].clues[clueIndex].isRevealed = true
    }

    var allCluesRevealed: Bool {
        return board.flatMap { $0.clues }.allSatisfy { $0.isRevealed }
    }

    @discardableResult
    func nextRound() -> RoundType {
        switch currentRound {
        case .jeopardy:
            currentRound = .doubleJeopardy
            generateBoard(for: currentRound)
        case .doubleJeopardy:
            currentRound = .finalJeopardy
            board = []
        case .finalJeopardy:
            break
        }
        return currentRound
    }

    func generateBoard(for round: RoundType) {
        guard round != .finalJeopardy else {
            board = []
            return
        }

        var availableGeneral = Array(generalCategories.keys)
        var availableDog = Array(dogCategories.keys)

        let dogCategoryCount = Int.random(in: 1...3)
        let generalCategoryCount = 6 - dogCategoryCount

        var selectedCategories: [CategoryBoard] = []

        for _ in 0..<dogCategoryCount {
            guard let key = availableDog.randomElement(), let prompts = dogCategories[key] else { continue }
            availableDog.removeAll(where: { $0 == key })
            let clues = createClues(for: key, prompts: prompts, round: round)
            selectedCategories.append(CategoryBoard(title: key, clues: clues))
        }

        for _ in 0..<generalCategoryCount {
            guard let key = availableGeneral.randomElement(), let prompts = generalCategories[key] else { continue }
            availableGeneral.removeAll(where: { $0 == key })
            let clues = createClues(for: key, prompts: prompts, round: round)
            selectedCategories.append(CategoryBoard(title: key, clues: clues))
        }

        selectedCategories.shuffle()
        assignSpecialClues(in: &selectedCategories, for: round)
        board = selectedCategories
    }

    private func createClues(for category: String, prompts: [String], round: RoundType) -> [Clue] {
        let baseValue = round.baseClueValue
        return prompts.enumerated().map { index, prompt in
            let value = baseValue * (index + 1)
            return Clue(
                category: category,
                prompt: prompt,
                response: "What is ...?",
                value: value,
                isRevealed: false,
                isDailyDouble: false,
                isDailyDooDoo: false
            )
        }
    }

    private func assignSpecialClues(in board: inout [CategoryBoard], for round: RoundType) {
        guard !board.isEmpty else { return }

        var allIndices: [(Int, Int)] = []
        for (categoryIndex, category) in board.enumerated() {
            for clueIndex in category.clues.indices {
                allIndices.append((categoryIndex, clueIndex))
            }
        }

        guard !allIndices.isEmpty else { return }

        allIndices.shuffle()

        let dailyDoubleCount = round == .doubleJeopardy ? 2 : 1
        for i in 0..<min(dailyDoubleCount, allIndices.count) {
            let (catIdx, clueIdx) = allIndices[i]
            board[catIdx].clues[clueIdx].isDailyDouble = true
        }

        if let dooDooIndex = allIndices.dropFirst(dailyDoubleCount).first {
            board[dooDooIndex.0].clues[dooDooIndex.1].isDailyDooDoo = true
        }
    }
}
