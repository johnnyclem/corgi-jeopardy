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
    var isRevealed: Bool
    var isDailyDouble: Bool
    var isDailyDooDoo: Bool
}

struct Category {
    let title: String
    var clues: [Clue]
}

final class GameState {
    static let shared = GameState()

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
    }
}
