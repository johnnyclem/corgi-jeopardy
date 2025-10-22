import XCTest
@testable import corgi_jeopardy

final class GameStateTests: XCTestCase {

    func testUpdateScoreHandlesWagers() {
        let gameState = GameState()

        gameState.updateScore(for: 200, isCorrect: true)
        XCTAssertEqual(gameState.score, 200)

        gameState.updateScore(for: 400, isCorrect: false)
        XCTAssertEqual(gameState.score, -200)

        // Add winnings so the player has a positive balance to wager.
        gameState.updateScore(for: 1200, isCorrect: true)
        XCTAssertEqual(gameState.score, 1000)

        gameState.updateScore(for: 2000, isCorrect: true, isWager: true)
        XCTAssertEqual(gameState.score, 2000, "Wagers should be clamped to the player's available score when correct.")

        gameState.updateScore(for: 2000, isCorrect: false, isWager: true)
        XCTAssertEqual(gameState.score, 0, "Incorrect wagers should subtract, but remain clamped to the available score.")

        gameState.updateScore(for: -500, isCorrect: true, isWager: true)
        XCTAssertEqual(gameState.score, 0, "Negative wagers should be treated as zero.")
    }

    func testGenerateBoardIncludesDogCategories() {
        var generator = PredictableRandomNumberGenerator(seed: 1234)
        let gameState = GameState()
        gameState.generateBoard(categoryCount: 6, using: &generator)

        XCTAssertEqual(gameState.board.count, 6)

        let dogCategories = gameState.board.filter { $0.isDogCategory }
        XCTAssertGreaterThanOrEqual(dogCategories.count, 1)
        XCTAssertLessThanOrEqual(dogCategories.count, 3)

        let uniqueTitles = Set(gameState.board.map { $0.title })
        XCTAssertEqual(uniqueTitles.count, gameState.board.count)
    }

    func testValidateAnswer() {
        let gameState = GameState()
        XCTAssertTrue(gameState.validateAnswer("What is Corgi?", correctAnswer: "corgi"))
        XCTAssertTrue(gameState.validateAnswer("WHO ARE THE CORGIS", correctAnswer: "Corgis"))
        XCTAssertTrue(gameState.validateAnswer("Corgi lore!", correctAnswer: "corgi lore"))
        XCTAssertFalse(gameState.validateAnswer("", correctAnswer: "corgi"))
        XCTAssertFalse(gameState.validateAnswer("Cat", correctAnswer: "corgi"))
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
