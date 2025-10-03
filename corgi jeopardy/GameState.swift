import Foundation

struct GameState {
    struct Category: Equatable {
        let name: String
        let clues: [Clue]
        let isDogCategory: Bool
    }

    struct Clue: Equatable {
        let prompt: String
        let response: String
        let value: Int
    }

    private(set) var score: Int
    private(set) var board: [Category]

    private static let dogCategoryPool: [Category] = [
        Category(name: "Corgi Lore", clues: GameState.makeDefaultClues(prefix: "Corgi"), isDogCategory: true),
        Category(name: "Working Dogs", clues: GameState.makeDefaultClues(prefix: "Working"), isDogCategory: true),
        Category(name: "Famous Dogs", clues: GameState.makeDefaultClues(prefix: "Famous"), isDogCategory: true),
        Category(name: "Dog Training", clues: GameState.makeDefaultClues(prefix: "Training"), isDogCategory: true)
    ]

    private static let generalCategoryPool: [Category] = [
        Category(name: "Dog Adjacent Trivia", clues: GameState.makeDefaultClues(prefix: "Adjacent"), isDogCategory: false),
        Category(name: "Pet Care", clues: GameState.makeDefaultClues(prefix: "Care"), isDogCategory: false),
        Category(name: "Corgi History", clues: GameState.makeDefaultClues(prefix: "History"), isDogCategory: false),
        Category(name: "Agility", clues: GameState.makeDefaultClues(prefix: "Agility"), isDogCategory: false),
        Category(name: "Parks", clues: GameState.makeDefaultClues(prefix: "Parks"), isDogCategory: false),
        Category(name: "Treats", clues: GameState.makeDefaultClues(prefix: "Treats"), isDogCategory: false)
    ]

    init(score: Int = 0, board: [Category] = []) {
        self.score = score
        self.board = board
    }

    mutating func updateScore(for value: Int, isCorrect: Bool, isWager: Bool = false) {
        let sanitizedValue = max(0, value)
        if isWager {
            let allowedWager = max(0, min(sanitizedValue, max(score, 0)))
            score += isCorrect ? allowedWager : -allowedWager
        } else {
            score += isCorrect ? sanitizedValue : -sanitizedValue
        }
    }

    mutating func generateBoard(categoryCount: Int = 6, using generator: inout some RandomNumberGenerator) {
        let dogCategoryLimit = min(3, GameState.dogCategoryPool.count)
        let dogCountUpperBound = max(1, min(categoryCount, dogCategoryLimit))
        let dogCount = Int.random(in: 1...dogCountUpperBound, using: &generator)
        let generalCount = max(0, categoryCount - dogCount)

        let dogCategories = Array(GameState.dogCategoryPool.shuffled(using: &generator).prefix(dogCount))
        let generalCategories = Array(GameState.generalCategoryPool.shuffled(using: &generator).prefix(generalCount))

        board = dogCategories + generalCategories
    }

    mutating func generateBoard(categoryCount: Int = 6) {
        var generator = SystemRandomNumberGenerator()
        generateBoard(categoryCount: categoryCount, using: &generator)
    }

    func validateAnswer(_ userAnswer: String, correctAnswer: String) -> Bool {
        let normalizedUser = GameState.normalized(answer: userAnswer)
        let normalizedCorrect = GameState.normalized(answer: correctAnswer)
        guard !normalizedUser.isEmpty, !normalizedCorrect.isEmpty else { return false }
        return normalizedUser == normalizedCorrect
    }

    private static func normalized(answer: String) -> String {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return "" }

        let response = trimmed
            .replacingOccurrences(of: "what is", with: "", options: [.anchored, .caseInsensitive])
            .replacingOccurrences(of: "who is", with: "", options: [.anchored, .caseInsensitive])
            .replacingOccurrences(of: "where is", with: "", options: [.anchored, .caseInsensitive])
            .replacingOccurrences(of: "what are", with: "", options: [.anchored, .caseInsensitive])
            .replacingOccurrences(of: "who are", with: "", options: [.anchored, .caseInsensitive])
            .replacingOccurrences(of: "where are", with: "", options: [.anchored, .caseInsensitive])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let allowedCharacters = CharacterSet.alphanumerics
        let normalized = response.unicodeScalars.filter { allowedCharacters.contains($0) }.map { Character($0) }
        return String(normalized)
    }

    private static func makeDefaultClues(prefix: String) -> [Clue] {
        return stride(from: 200, through: 1000, by: 200).map { value in
            Clue(prompt: "\(prefix) clue for \(value)", response: "\(prefix) answer \(value)", value: value)
        }
    }
}
