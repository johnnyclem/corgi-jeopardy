import SpriteKit
import UIKit

final class ClueScene: SKScene {
    private let clue: Clue
    private let gameState = GameState.shared

    private var hasBuzzed = false
    private var aiTimers: [Timer] = []
    private var noBuzzTimer: Timer?

    private let questionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let aiAnswerLabel = SKLabelNode(fontNamed: "AvenirNext-Italic")
    private let buzzButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    init(size: CGSize, clue: Clue) {
        self.clue = clue
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        backgroundColor = SKColor(red: 6.0 / 255.0, green: 12.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)

        configureQuestionLabel()
        configureStatusLabel()
        configureBuzzButton()
        configureAIAnswerLabel()

        scheduleAITimers()
        startNoBuzzTimer()
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        invalidateTimers()
    }

    deinit {
        invalidateTimers()
    }

    private func configureQuestionLabel() {
        questionLabel.text = clue.question
        questionLabel.fontSize = 32
        questionLabel.numberOfLines = 0
        questionLabel.preferredMaxLayoutWidth = size.width * 0.8
        questionLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        questionLabel.horizontalAlignmentMode = .center
        questionLabel.verticalAlignmentMode = .center
        addChild(questionLabel)
    }

    private func configureStatusLabel() {
        statusLabel.text = "Tap to buzz in!"
        statusLabel.fontSize = 24
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        statusLabel.horizontalAlignmentMode = .center
        addChild(statusLabel)
    }

    private func configureAIAnswerLabel() {
        aiAnswerLabel.text = ""
        aiAnswerLabel.fontSize = 26
        aiAnswerLabel.alpha = 0
        aiAnswerLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        aiAnswerLabel.horizontalAlignmentMode = .center
        aiAnswerLabel.verticalAlignmentMode = .center
        addChild(aiAnswerLabel)
    }

    private func configureBuzzButton() {
        buzzButtonLabel.text = "BUZZ!"
        buzzButtonLabel.fontSize = 44
        buzzButtonLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        buzzButtonLabel.horizontalAlignmentMode = .center
        addChild(buzzButtonLabel)
    }

    private func scheduleAITimers() {
        let aiPlayers = gameState.players.filter { !$0.isHuman }
        for player in aiPlayers {
            let delay = player.difficulty.buzzDelay
            let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                self?.handleAIBuzz(for: player)
            }
            aiTimers.append(timer)
        }
    }

    private func startNoBuzzTimer() {
        noBuzzTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { [weak self] _ in
            self?.handleNoBuzz()
        }
    }

    private func invalidateTimers() {
        aiTimers.forEach { $0.invalidate() }
        aiTimers.removeAll()
        noBuzzTimer?.invalidate()
        noBuzzTimer = nil
    }

    private func handleAIBuzz(for player: GameState.Player) {
        guard !hasBuzzed else { return }
        hasBuzzed = true
        invalidateTimers()

        let isCorrect = Double.random(in: 0...1) <= player.difficulty.correctProbability
        let response = isCorrect ? clue.answer : randomWrongAnswer()
        let formattedAnswer = "What is \(response)?"

        aiAnswerLabel.text = "\(player.name): \(formattedAnswer)"
        aiAnswerLabel.removeAllActions()
        aiAnswerLabel.alpha = 0
        aiAnswerLabel.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.wait(forDuration: 1.2)
        ]))

        if isCorrect {
            statusLabel.text = "\(player.name) is correct!"
            gameState.updateScore(for: player, delta: clue.value)
        } else {
            statusLabel.text = "\(player.name) guessed wrong!"
            gameState.updateScore(for: player, delta: -clue.value)
        }

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { [weak self] in self?.finishClue() }
        ]))
    }

    private func handleNoBuzz() {
        guard !hasBuzzed else { return }
        hasBuzzed = true
        invalidateTimers()
        gameState.advanceTurn()
        let nextPlayerName = gameState.currentTurn.name
        statusLabel.text = "No buzzes! Next up: \(nextPlayerName)"

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in self?.finishClue() }
        ]))
    }

    private func randomWrongAnswer() -> String {
        let wrongAnswers = [
            "sniffing butts",
            "the squeaky toy",
            "mail carriers",
            "belly rubs",
            "taking a nap"
        ]
        return wrongAnswers.randomElement() ?? "dog treats"
    }

    private func finishClue() {
        // Placeholder transition logic; in a full game this would return to the board scene.
        let fade = SKTransition.crossFade(withDuration: 0.5)
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: fade)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !hasBuzzed else { return }
        guard let human = gameState.players.first(where: { $0.isHuman }) else { return }

        hasBuzzed = true
        invalidateTimers()

        statusLabel.text = "You buzzed in first!"
        aiAnswerLabel.removeAllActions()
        aiAnswerLabel.alpha = 0

        promptForHumanAnswer(for: human)
    }

    private func promptForHumanAnswer(for player: GameState.Player) {
        guard let view = view else { return }
        let alert = UIAlertController(title: "Your Answer", message: "Respond in the form of a question.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "What is..."
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            let answerText = alert.textFields?.first?.text ?? ""
            self?.evaluateHumanAnswer(answerText, for: player)
        }))
        alert.addAction(UIAlertAction(title: "Pass", style: .cancel, handler: { [weak self] _ in
            self?.handleHumanPass(for: player)
        }))
        view.window?.rootViewController?.present(alert, animated: true)
    }

    private func evaluateHumanAnswer(_ answer: String, for player: GameState.Player) {
        let normalizedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let requiredPrefixMatches = ["what is", "who is", "where is", "what are", "who are", "where are"]
        let hasCorrectPrefix = requiredPrefixMatches.contains(where: { normalizedAnswer.hasPrefix($0) })
        let containsCorrectResponse = normalizedAnswer.contains(clue.answer.lowercased())

        let isCorrect = hasCorrectPrefix && containsCorrectResponse

        if isCorrect {
            statusLabel.text = "Correct!"
            gameState.updateScore(for: player, delta: clue.value)
        } else {
            statusLabel.text = "Sorry, that's not right."
            gameState.updateScore(for: player, delta: -clue.value)
        }

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in self?.finishClue() }
        ]))
    }

    private func handleHumanPass(for player: GameState.Player) {
        statusLabel.text = "You passed. Other players may buzz."
        hasBuzzed = false

        scheduleAITimers()
        startNoBuzzTimer()
    }
}
