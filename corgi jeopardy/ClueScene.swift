import SpriteKit
import UIKit

final class ClueScene: SKScene, UITextFieldDelegate {
    private let clue: GameState.Clue
    private let gameState = GameState.shared

    private var questionLabel: SKLabelNode!
    private var statusLabel: SKLabelNode!
    private var promptLabel: SKLabelNode!
    private var aiAnswerLabel: SKLabelNode!

    private var answerField: UITextField?
    private var hasBuzzed = false
    private var currentResponder: GameState.Player?
    private var aiTimers: [String: Timer] = [:]
    private var noBuzzTimer: Timer?

    init(size: CGSize, clue: GameState.Clue) {
        self.clue = clue
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        guard let storedClue = GameState.shared.lastSelectedClue else { return nil }
        self.clue = storedClue
        super.init(coder: aDecoder)
    }

    deinit {
        invalidateTimers()
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = SKColor(red: 6/255, green: 12/255, blue: 64/255, alpha: 1)
        setupLabels()
        scheduleAITimers()
        startNoBuzzTimer()
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        invalidateTimers()
        answerField?.removeFromSuperview()
        answerField = nil
    }

    private func setupLabels() {
        questionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        questionLabel.text = clue.question
        questionLabel.fontSize = min(34, size.width * 0.06)
        questionLabel.numberOfLines = 0
        questionLabel.preferredMaxLayoutWidth = size.width * 0.8
        questionLabel.position = CGPoint(x: 0, y: size.height * 0.25)
        questionLabel.horizontalAlignmentMode = .center
        addChild(questionLabel)

        promptLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        promptLabel.text = "Tap anywhere to buzz in!"
        promptLabel.fontSize = 24
        promptLabel.position = CGPoint(x: 0, y: -size.height * 0.05)
        addChild(promptLabel)

        statusLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        statusLabel.fontSize = 24
        statusLabel.fontColor = .white
        statusLabel.position = CGPoint(x: 0, y: -size.height * 0.2)
        addChild(statusLabel)

        aiAnswerLabel = SKLabelNode(fontNamed: "AvenirNext-Italic")
        aiAnswerLabel.fontSize = 26
        aiAnswerLabel.alpha = 0
        aiAnswerLabel.position = CGPoint(x: 0, y: size.height * 0.05)
        addChild(aiAnswerLabel)
    }

    private func scheduleAITimers() {
        for playerId in gameState.aiPlayerIds {
            guard let player = gameState.player(for: playerId), let difficulty = player.difficulty else { continue }
            let delay = Double.random(in: difficulty.buzzDelayRange)
            let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                self?.handleAIBuzz(player: player)
            }
            aiTimers[playerId] = timer
        }
    }

    private func startNoBuzzTimer() {
        noBuzzTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            self?.handleNoBuzz()
        }
    }

    private func invalidateTimers() {
        aiTimers.values.forEach { $0.invalidate() }
        aiTimers.removeAll()
        noBuzzTimer?.invalidate()
        noBuzzTimer = nil
    }

    // MARK: - Buzz Logic

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !hasBuzzed else { return }
        guard let human = gameState.player(for: gameState.humanPlayerId) else { return }
        hasBuzzed = true
        currentResponder = human
        invalidateTimers()
        promptHumanAnswer()
    }

    private func handleAIBuzz(player: GameState.Player) {
        guard !hasBuzzed else { return }
        hasBuzzed = true
        currentResponder = player
        invalidateTimers()
        presentAIAnswer(for: player)
    }

    private func handleNoBuzz() {
        guard !hasBuzzed else { return }
        hasBuzzed = true
        statusLabel.text = "No one buzzed in."
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { [weak self] in self?.finishClue() }
        ]))
    }

    // MARK: - Human Answering

    private func promptHumanAnswer() {
        guard let view = view else { return }
        statusLabel.text = "You buzzed in first!"
        promptLabel.text = "Answer in the form of a question."

        let field = UITextField(frame: CGRect(x: view.bounds.midX - 160, y: view.bounds.midY, width: 320, height: 44))
        field.placeholder = "What is..."
        field.borderStyle = .roundedRect
        field.returnKeyType = .done
        field.delegate = self
        view.addSubview(field)
        field.becomeFirstResponder()
        answerField = field
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        evaluateHumanAnswer(textField.text ?? "")
        return true
    }

    private func evaluateHumanAnswer(_ answer: String) {
        answerField?.removeFromSuperview()
        answerField = nil

        let isCorrect = gameState.validateAnswer(answer, correctAnswer: clue.answer)
        resolveResult(for: currentResponder, isCorrect: isCorrect)
    }

    // MARK: - AI Answering

    private func presentAIAnswer(for player: GameState.Player) {
        guard let difficulty = player.difficulty else { return }
        let isCorrect = Double.random(in: 0...1) <= difficulty.correctnessProbability
        let response = isCorrect ? clue.answer : randomWrongAnswer()
        aiAnswerLabel.text = "\(player.displayName): What is \(response)?"
        aiAnswerLabel.alpha = 0
        aiAnswerLabel.run(SKAction.fadeIn(withDuration: 0.25))
        resolveResult(for: player, isCorrect: isCorrect)
    }

    private func randomWrongAnswer() -> String {
        let answers = [
            "belly rubs",
            "sniffing mail", "the squeaky toy",
            "dog treats", "herding ducks"
        ]
        return answers.randomElement() ?? "dog treats"
    }

    // MARK: - Scoring

    private func resolveResult(for player: GameState.Player?, isCorrect: Bool) {
        if let wagerResolution = gameState.resolveActiveWager(isCorrect: isCorrect) {
            let sign = wagerResolution.delta >= 0 ? "+" : ""
            statusLabel.text = "Wager: \(wagerResolution.affectedPlayer.displayName) \(sign)$\(wagerResolution.delta)"
        } else {
            let amount = isCorrect ? clue.value : -clue.value
            if let player = player {
                if player.isHuman {
                    gameState.updateCurrentPlayerScore(by: amount)
                } else {
                    gameState.updateScore(for: player, delta: amount)
                }
                let sign = amount >= 0 ? "+" : ""
                statusLabel.text = "\(player.displayName): \(isCorrect ? "Correct" : "Incorrect") (\(sign)$\(amount))"
            } else {
                statusLabel.text = isCorrect ? "Correct" : "Incorrect"
            }
        }

        gameState.advanceTurn()
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.6),
            SKAction.run { [weak self] in self?.finishClue() }
        ]))
    }

    private func finishClue() {
        let nextScene = GameBoardScene(size: size)
        nextScene.scaleMode = scaleMode
        view?.presentScene(nextScene, transition: SKTransition.fade(withDuration: 0.4))
    }
}
