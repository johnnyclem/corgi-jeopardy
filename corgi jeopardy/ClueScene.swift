import SpriteKit
import UIKit

final class ClueScene: SKScene, UITextFieldDelegate {
    private let clue: Clue
    private let gameState = GameState.shared

    private var questionLabel: SKLabelNode!
    private var promptLabel: SKLabelNode!
    private var responderLabel: SKLabelNode?
    private var corgiNode: SKSpriteNode!

    private var hasBuzzed = false
    private var currentResponder: String?
    private var answerTextField: UITextField?
    private var aiBuzzTimers: [String: Timer] = [:]
    private var isAwaitingAnswer = false

    init(size: CGSize, clue: Clue) {
        self.clue = clue
        GameState.shared.lastSelectedClue = clue
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
        backgroundColor = SKColor(named: "ClueBackground") ?? SKColor.systemIndigo
        setupQuestionLabel()
        setupPromptLabel()
        setupCorgiNode()
        scheduleAIBuzzes()
    }

    private func setupQuestionLabel() {
        questionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        questionLabel.text = clue.question
        questionLabel.fontSize = min(36, size.width * 0.06)
        questionLabel.numberOfLines = 0
        questionLabel.preferredMaxLayoutWidth = size.width * 0.8
        questionLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        questionLabel.horizontalAlignmentMode = .center
        questionLabel.verticalAlignmentMode = .center
        questionLabel.alpha = 0
        addChild(questionLabel)

        let fade = SKAction.fadeIn(withDuration: 0.5)
        questionLabel.run(fade)
    }

    private func setupPromptLabel() {
        promptLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        promptLabel.text = "Tap anywhere to buzz in!"
        promptLabel.fontSize = min(24, size.width * 0.045)
        promptLabel.position = CGPoint(x: frame.midX, y: frame.minY + 120)
        promptLabel.alpha = 0
        addChild(promptLabel)

        let fade = SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.fadeIn(withDuration: 0.3)
        ])
        promptLabel.run(fade)
    }

    private func setupCorgiNode() {
        let corgiTextureName = gameState.avatarName(for: gameState.currentTurn) ?? "corgi_host"
        let texture = SKTexture(imageNamed: corgiTextureName)
        corgiNode = SKSpriteNode(texture: texture)
        corgiNode.size = CGSize(width: 160, height: 160)
        corgiNode.position = CGPoint(x: frame.midX, y: frame.minY + 220)
        corgiNode.alpha = texture.size() == .zero ? 0.0 : 1.0
        if corgiNode.alpha == 0.0 {
            corgiNode.color = .orange
            corgiNode.colorBlendFactor = 1.0
            corgiNode.alpha = 1.0
        }
        addChild(corgiNode)
    }

    private func scheduleAIBuzzes() {
        guard !gameState.aiPlayers.isEmpty else { return }
        let difficulty = gameState.difficulty
        for ai in gameState.aiPlayers {
            let range = difficulty.buzzDelayRange
            let randomDelay = Double.random(in: range)
            let timer = Timer.scheduledTimer(withTimeInterval: randomDelay, repeats: false) { [weak self] _ in
                self?.handleAIBuzz(player: ai)
            }
            aiBuzzTimers[ai] = timer
        }
    }

    private func invalidateTimers() {
        aiBuzzTimers.values.forEach { $0.invalidate() }
        aiBuzzTimers.removeAll()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !hasBuzzed, !isAwaitingAnswer else { return }
        handleBuzz(player: gameState.playerOrder.first ?? "Player1")
    }

    private func handleBuzz(player: String) {
        guard !hasBuzzed else { return }
        hasBuzzed = true
        currentResponder = player
        promptLabel.text = "\(player) buzzed in!"
        invalidateTimers()
        isAwaitingAnswer = true
        presentAnswerInput(for: player)
    }

    private func presentAnswerInput(for player: String) {
        if let responderLabel = responderLabel {
            responderLabel.removeFromParent()
        }
        responderLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        responderLabel?.text = "Answer:"
        responderLabel?.fontSize = min(28, size.width * 0.05)
        responderLabel?.position = CGPoint(x: frame.midX, y: frame.midY - 160)
        if let responderLabel = responderLabel {
            addChild(responderLabel)
        }

        if gameState.aiPlayers.contains(player) {
            run(SKAction.sequence([
                SKAction.wait(forDuration: 0.6),
                SKAction.run { [weak self] in
                    self?.handleAIAnswer(for: player)
                }
            ]))
        } else {
            guard let view = view else { return }
            let textField = UITextField(frame: CGRect(x: 40, y: view.bounds.height * 0.65, width: view.bounds.width - 80, height: 44))
            textField.borderStyle = .roundedRect
            textField.placeholder = "Respond in the form of a question..."
            textField.returnKeyType = .done
            textField.autocapitalizationType = .sentences
            textField.delegate = self
            textField.accessibilityIdentifier = "clueAnswerTextField"
            view.addSubview(textField)
            textField.becomeFirstResponder()
            answerTextField = textField
        }
    }

    private func handleAIBuzz(player: String) {
        guard !hasBuzzed else { return }
        handleBuzz(player: player)
    }

    private func handleAIAnswer(for player: String) {
        let aiDifficulty = gameState.difficulty
        let answerIsCorrect = Double.random(in: 0...1) <= aiDifficulty.correctnessProbability
        let answerText: String
        if answerIsCorrect {
            answerText = "What is \(clue.answer)?"
        } else {
            answerText = "What is corgi fluff?"
        }
        showAIResponse(text: "\(player): \(answerText)")
        processAnswer(answerText, for: player)
    }

    private func showAIResponse(text: String) {
        if let responderLabel = responderLabel {
            responderLabel.removeFromParent()
        }
        let aiLabel = SKLabelNode(fontNamed: "AvenirNext-Italic")
        aiLabel.text = text
        aiLabel.fontSize = min(24, size.width * 0.04)
        aiLabel.position = CGPoint(x: frame.midX, y: frame.midY - 160)
        aiLabel.numberOfLines = 0
        aiLabel.preferredMaxLayoutWidth = size.width * 0.8
        addChild(aiLabel)
        responderLabel = aiLabel
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, let player = currentResponder else { return false }
        textField.resignFirstResponder()
        processAnswer(text, for: player)
        return true
    }

    private func processAnswer(_ answer: String, for player: String) {
        guard isAwaitingAnswer else { return }
        isAwaitingAnswer = false
        answerTextField?.removeFromSuperview()
        answerTextField = nil

        let isCorrect = validate(answer: answer)
        let amount = gameState.wager ?? clue.value
        if isCorrect {
            gameState.updateScore(player: player, amount: amount)
        } else {
            gameState.updateScore(player: player, amount: -amount)
        }
        runCorgiReaction(correct: isCorrect)
        showResult(isCorrect: isCorrect, player: player)

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { [weak self] in
                self?.returnToBoard()
            }
        ]))
    }

    private func validate(answer: String) -> Bool {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return false }
        let validPrefixes = ["what is", "who is", "where is", "what are", "who are", "where are"]
        guard validPrefixes.contains(where: { trimmed.hasPrefix($0) }) else { return false }
        let sanitizedAnswer = clue.answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.contains(sanitizedAnswer)
    }

    private func showResult(isCorrect: Bool, player: String) {
        let resultLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resultLabel.text = isCorrect ? "Correct! +$\(gameState.wager ?? clue.value)" : "Incorrect! -$\(gameState.wager ?? clue.value)"
        resultLabel.fontSize = min(30, size.width * 0.05)
        resultLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        resultLabel.fontColor = isCorrect ? .systemGreen : .systemRed
        addChild(resultLabel)

        let fade = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ])
        resultLabel.run(fade)
    }

    private func runCorgiReaction(correct: Bool) {
        let jumpUp = SKAction.moveBy(x: 0, y: correct ? 80 : -40, duration: 0.2)
        jumpUp.timingMode = .easeOut
        let jumpDown = SKAction.moveBy(x: 0, y: correct ? -80 : 40, duration: 0.3)
        jumpDown.timingMode = .easeIn
        let colorize = SKAction.colorize(with: correct ? .systemYellow : .systemBlue, colorBlendFactor: 0.6, duration: 0.2)
        let soundName = correct ? "bark.mp3" : "whimper.mp3"
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: false)

        let reactionSequence = SKAction.sequence([
            SKAction.group([jumpUp, colorize, soundAction]),
            jumpDown,
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
        ])
        corgiNode.run(reactionSequence)
    }

    private func returnToBoard() {
        answerTextField?.removeFromSuperview()
        answerTextField = nil
        gameState.lastSelectedClue = nil
        invalidateTimers()
        let nextScene = GameBoardScene(size: size)
        let transition = SKTransition.fade(withDuration: 0.6)
        view?.presentScene(nextScene, transition: transition)
//
//  ClueScene.swift
//  corgi jeopardy
//
//  Minimal placeholder scene that displays the selected clue.
//

import SpriteKit

final class ClueScene: SKScene {
    private let clue: Clue

    init(size: CGSize, clue: Clue) {
        self.clue = clue
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 20 / 255, green: 20 / 255, blue: 40 / 255, alpha: 1)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "$\(clue.value)"
        titleLabel.fontSize = 48
        titleLabel.fontColor = SKColor(red: 0.96, green: 0.78, blue: 0.22, alpha: 1)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)

        let questionLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        questionLabel.text = clue.question
        questionLabel.fontSize = 32
        questionLabel.fontColor = .white
        questionLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        questionLabel.horizontalAlignmentMode = .center
        questionLabel.verticalAlignmentMode = .center
        questionLabel.numberOfLines = 0
        questionLabel.preferredMaxLayoutWidth = size.width * 0.8
        addChild(questionLabel)

        let instructionLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        instructionLabel.text = "Tap to return"
        instructionLabel.fontSize = 20
        instructionLabel.fontColor = SKColor(white: 0.8, alpha: 1)
        instructionLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        addChild(instructionLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let boardScene = GameBoardScene(size: size)
        boardScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.3)
        view?.presentScene(boardScene, transition: transition)
    }
}
