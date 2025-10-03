import Foundation

/// Represents a single trivia clue on the board.
struct Clue {
    let value: Int
    let question: String
    let answer: String
    let isDailyDouble: Bool
}
