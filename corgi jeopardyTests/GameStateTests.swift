import XCTest
@testable import corgi_jeopardy

final class GameStateTests: XCTestCase {

    func testUpdateScore() {
        var gameState = GameState()
        gameState.updateScore(for: 200, isCorrect: true)
        XCTAssertEqual(gameState.score, 200, "Correct answers should add the clue value to the score.")

        gameState.updateScore(for: 400, isCorrect: false)
        XCTAssertEqual(gameState.score, -200, "Incorrect answers should subtract the clue value, allowing negative scores.")

        gameState = GameState(score: 1000)
        gameState.updateScore(for: 2000, isCorrect: true, isWager: true)
        XCTAssertEqual(gameState.score, 2000, "Wagers should be clamped to the available score when answering correctly.")

        gameState.updateScore(for: 2000, isCorrect: false, isWager: true)
        XCTAssertEqual(gameState.score, 1000, "Wagers larger than the score should be clamped when answered incorrectly as well.")

        gameState.updateScore(for: -500, isCorrect: true, isWager: true)
        XCTAssertEqual(gameState.score, 1000, "Negative wagers should be treated as zero to avoid inflating the score.")
    }

    func testGenerateBoardEnsuresDogCategories() {
        var generator = PredictableRandomNumberGenerator(seed: 42)
        var gameState = GameState()
        gameState.generateBoard(categoryCount: 6, using: &generator)

        XCTAssertEqual(gameState.board.count, 6, "A standard Jeopardy round should contain six categories.")

        let dogCategories = gameState.board.filter { $0.isDogCategory }
        XCTAssertGreaterThanOrEqual(dogCategories.count, 1, "The generated board should always include at least one dog-themed category.")
        XCTAssertLessThanOrEqual(dogCategories.count, 3, "The generated board should include no more than three dog-themed categories to preserve variety.")

        let uniqueCategoryNames = Set(gameState.board.map { $0.name })
        XCTAssertEqual(uniqueCategoryNames.count, gameState.board.count, "Board generation should not duplicate category names in a single round.")
    }

    func testAnswerValidation() {
        let gameState = GameState()

        XCTAssertTrue(gameState.validateAnswer("What is Corgi?", correctAnswer: "corgi"))
        XCTAssertTrue(gameState.validateAnswer("WHO ARE THE CORGIS", correctAnswer: "Corgis"))
        XCTAssertTrue(gameState.validateAnswer("Corgi lore!", correctAnswer: "corgi lore"))

        XCTAssertFalse(gameState.validateAnswer("", correctAnswer: "corgi"), "Empty answers should be treated as invalid.")
        XCTAssertFalse(gameState.validateAnswer("Cat", correctAnswer: "corgi"), "Mismatched answers should return false.")
    }
}

private struct PredictableRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
