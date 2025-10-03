//
//  FinalJeopardyScene.swift
//  corgi jeopardy
//
//  Created by OpenAI Assistant on 2024-06-01.
//

import Foundation
import SpriteKit
import UIKit

final class FinalJeopardyScene: SKScene {

    struct PlayerState {
        let id: String
        var score: Int
        let isHuman: Bool
        var wager: Int
        var answer: String
        var isCorrect: Bool
        var startingScore: Int

        init(id: String, score: Int, isHuman: Bool) {
            self.id = id
            self.score = score
            self.isHuman = isHuman
            self.wager = 0
            self.answer = ""
            self.isCorrect = false
            self.startingScore = score
        }
    }

    private enum Phase {
        case intro
        case wager
        case answer
        case results
        case complete
    }

    private var players: [PlayerState]
    private let category: String
    private let clue: String
    private let correctResponse: String

    private var infoLabel: SKLabelNode!
    private var categoryLabel: SKLabelNode!
    private var clueLabel: SKLabelNode!
    private var countdownLabel: SKLabelNode!
    private var submitLabel: SKLabelNode?
    private var resultsContainer: SKNode?

    private weak var wagerTextField: UITextField?
    private weak var answerTextField: UITextField?

    private var phase: Phase = .intro
    private var timer: Timer?
    private var timeRemaining: Int = 30

    private var humanPlayerIndex: Int?

    // MARK: - Initializers

    init(size: CGSize, category: String, clue: String, correctResponse: String, players: [PlayerState]) {
        self.category = category
        self.clue = clue
        self.correctResponse = correctResponse
        self.players = players
        super.init(size: size)
        self.humanPlayerIndex = players.firstIndex(where: { $0.isHuman })
    }

    required init?(coder aDecoder: NSCoder) {
        self.category = "Corgi History"
        self.clue = "This royal breed hails from Wales and is known for its herding prowess."
        self.correctResponse = "What is the Pembroke Welsh Corgi?"
        self.players = [
            PlayerState(id: "You", score: 2000, isHuman: true),
            PlayerState(id: "AI Pup", score: 2200, isHuman: false),
            PlayerState(id: "AI Tail", score: 1800, isHuman: false)
        ]
        super.init(coder: aDecoder)
        self.humanPlayerIndex = players.firstIndex(where: { $0.isHuman })
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 16/255, green: 27/255, blue: 64/255, alpha: 1)
        setupLabels()
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.run { [weak self] in
                self?.enterWagerPhase()
            }
        ]))
    }

    override func willMove(from view: SKView) {
        removeTextFields()
        timer?.invalidate()
    }

    // MARK: - Setup

    private func setupLabels() {
        infoLabel = createLabel(fontSize: 34, fontWeight: .bold)
        infoLabel.position = CGPoint(x: size.width / 2, y: size.height - 90)
        infoLabel.text = "Final Jeopardy!"
        addChild(infoLabel)

        categoryLabel = createLabel(fontSize: 30, fontWeight: .semibold)
        categoryLabel.position = CGPoint(x: size.width / 2, y: size.height - 150)
        categoryLabel.alpha = 0
        addChild(categoryLabel)

        clueLabel = createLabel(fontSize: 28, fontWeight: .regular)
        clueLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 60)
        clueLabel.alpha = 0
        addChild(clueLabel)

        countdownLabel = createLabel(fontSize: 26, fontWeight: .medium)
        countdownLabel.position = CGPoint(x: size.width - 80, y: size.height - 80)
        countdownLabel.horizontalAlignmentMode = .right
        countdownLabel.text = "30"
        countdownLabel.alpha = 0
        addChild(countdownLabel)
    }

    private func createLabel(fontSize: CGFloat, fontWeight: UIFont.Weight) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = fontSize
        label.fontColor = .white
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = size.width - 80
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }

    private func presentSubmitButton(with title: String) {
        if submitLabel == nil {
            let submit = SKLabelNode(fontNamed: "AvenirNext-Bold")
            submit.fontSize = 30
            submit.fontColor = UIColor(red: 255/255, green: 214/255, blue: 0/255, alpha: 1)
            submit.position = CGPoint(x: size.width / 2, y: 120)
            submit.name = "submitButton"
            addChild(submit)
            submitLabel = submit
        }
        submitLabel?.text = title
        submitLabel?.alpha = 1
    }

    // MARK: - Phases

    private func enterWagerPhase() {
        guard phase == .intro else { return }
        phase = .wager
        infoLabel.text = "Place your wagers!"

        assignAIWagers()
        showHumanWagerField()
        presentSubmitButton(with: "Submit Wager")
    }

    private func assignAIWagers() {
        for index in players.indices where !players[index].isHuman {
            let score = max(players[index].score, 0)
            guard score > 0 else {
                players[index].wager = 0
                continue
            }
            let lowerBound = max(0, min(score, Int(Double(score) * 0.5)))
            let wagerRange = lowerBound...score
            players[index].wager = Int.random(in: wagerRange)
        }
    }

    private func showHumanWagerField() {
        guard let view = self.view, let humanIndex = humanPlayerIndex else { return }
        let maxWager = max(players[humanIndex].score, 0)

        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 1, alpha: 0.9)
        textField.placeholder = "Enter wager (0-\(maxWager))"
        textField.textAlignment = .center
        textField.delegate = self
        textField.accessibilityIdentifier = "FinalJeopardyWagerTextField"

        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            textField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])

        textField.becomeFirstResponder()
        wagerTextField = textField
    }

    private func hideWagerField() {
        wagerTextField?.resignFirstResponder()
        wagerTextField?.removeFromSuperview()
    }

    private func revealCategory() {
        infoLabel.text = "Get ready for the category!"
        categoryLabel.text = "Category: \(category)"
        categoryLabel.run(SKAction.fadeIn(withDuration: 0.5))

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { [weak self] in
                self?.revealClue()
            }
        ]))
    }

    private func revealClue() {
        clueLabel.text = clue
        clueLabel.alpha = 0
        clueLabel.run(SKAction.fadeIn(withDuration: 0.5))

        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.run { [weak self] in
                self?.startAnswerPhase()
            }
        ]))
    }

    private func startAnswerPhase() {
        guard phase == .wager else { return }
        phase = .answer
        infoLabel.text = "Submit your response in the form of a question!"
        presentSubmitButton(with: "Submit Answer")
        showHumanAnswerField()
        startCountdown()
    }

    private func showHumanAnswerField() {
        guard let view = self.view else { return }
        hideWagerField()

        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 1, alpha: 0.92)
        textField.placeholder = "Your Final Jeopardy response"
        textField.textAlignment = .left
        textField.delegate = self
        textField.accessibilityIdentifier = "FinalJeopardyAnswerTextField"

        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            textField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])

        textField.becomeFirstResponder()
        answerTextField = textField
    }

    private func hideAnswerField() {
        answerTextField?.resignFirstResponder()
        answerTextField?.removeFromSuperview()
    }

    private func startCountdown() {
        timeRemaining = 30
        countdownLabel.text = "30"
        countdownLabel.alpha = 1

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] timer in
            self?.tickCountdown(timer: timer)
        })
    }

    private func tickCountdown(timer: Timer) {
        guard phase == .answer else {
            timer.invalidate()
            return
        }

        timeRemaining -= 1
        countdownLabel.text = "\(max(timeRemaining, 0))"

        if timeRemaining <= 0 {
            timer.invalidate()
            completeAnswerPhase(triggeredByTimer: true)
        }
    }

    private func completeAnswerPhase(triggeredByTimer: Bool = false) {
        guard phase == .answer else { return }
        phase = .results

        timer?.invalidate()
        countdownLabel.run(SKAction.fadeOut(withDuration: 0.3))

        if let humanIndex = humanPlayerIndex {
            let response = answerTextField?.text ?? ""
            players[humanIndex].answer = response.trimmingCharacters(in: .whitespacesAndNewlines)
            players[humanIndex].isCorrect = evaluate(answer: players[humanIndex].answer)
        }

        hideAnswerField()
        submitLabel?.run(SKAction.fadeOut(withDuration: 0.3))

        generateAIMoves()
        applyScoreChanges()
        showResults(triggeredByTimer: triggeredByTimer)
    }

    private func generateAIMoves() {
        for index in players.indices where !players[index].isHuman {
            let shouldBeCorrect = Bool.random()
            if shouldBeCorrect {
                players[index].answer = correctResponse
                players[index].isCorrect = true
            } else {
                let fillerResponses = [
                    "What is extra belly rubs?",
                    "Who is Sir Wiggles?",
                    "What are squeaky toys?",
                    "Who is Queen Barkbeth?"
                ]
                players[index].answer = fillerResponses.randomElement() ?? "No response"
                players[index].isCorrect = evaluate(answer: players[index].answer)
            }
        }
    }

    private func applyScoreChanges() {
        for index in players.indices {
            let wager = players[index].wager
            if players[index].isCorrect {
                players[index].score += wager
            } else {
                players[index].score -= wager
            }
        }
    }

    private func showResults(triggeredByTimer: Bool) {
        infoLabel.text = triggeredByTimer ? "Time's up! Let's reveal the answers." : "Let's reveal the answers!"

        resultsContainer?.removeFromParent()
        let container = SKNode()
        container.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
        addChild(container)
        resultsContainer = container

        var yOffset: CGFloat = CGFloat(players.count - 1) * 60 / 2
        for player in players {
            let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            label.fontSize = 24
            label.fontColor = .white
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center

            let displayedAnswer = player.answer.isEmpty ? "No answer" : ""\(player.answer)""
            let delta = player.score - player.startingScore
            let deltaText = delta >= 0 ? "+\(delta)" : "\(delta)"
            let correctness = player.isCorrect ? "✅" : "❌"
            label.text = "\(player.id): \(displayedAnswer) \(correctness)  Wager: \(player.wager)  Score: \(player.score) (\(deltaText))"
            label.position = CGPoint(x: 0, y: yOffset)
            container.addChild(label)
            yOffset -= 60
        }

        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.2),
            SKAction.run { [weak self] in
                self?.declareWinner()
            }
        ]))
    }

    private func declareWinner() {
        guard phase == .results else { return }
        phase = .complete

        let topScore = players.map { $0.score }.max() ?? 0
        let winners = players.filter { $0.score == topScore }
        if winners.isEmpty {
            infoLabel.text = "Everyone needs more practice!"
        } else if winners.count == 1 {
            infoLabel.text = "\(winners[0].id) wins Final Jeopardy!"
        } else {
            let names = winners.map { $0.id }.joined(separator: " & ")
            infoLabel.text = "It's a tie! \(names) celebrate together!"
        }

        launchConfetti()
        startCorgiDance()
    }

    // MARK: - Helpers

    private func evaluate(answer: String) -> Bool {
        guard !answer.isEmpty else { return false }
        let normalizedGuess = normalize(answer: answer)
        let normalizedCorrect = normalize(answer: correctResponse)
        return normalizedGuess == normalizedCorrect
    }

    private func normalize(answer: String) -> String {
        var processed = answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let prefixes = ["what is", "who is", "where is", "what's", "who's", "where's"]
        for prefix in prefixes {
            if processed.hasPrefix(prefix) {
                processed = String(processed.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        processed = processed.unicodeScalars.filter { allowed.contains($0) }.map { Character($0) }.reduce(into: "") { partialResult, character in
            partialResult.append(character)
        }
        processed = processed.replacingOccurrences(of: "  ", with: " ")
        return processed.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submitWager() {
        guard let humanIndex = humanPlayerIndex else {
            hideWagerField()
            revealCategory()
            return
        }

        guard let text = wagerTextField?.text, let wagerValue = Int(text) else {
            flashInvalidInput()
            return
        }

        let maxWager = max(players[humanIndex].score, 0)
        let validWager = max(0, min(wagerValue, maxWager))
        players[humanIndex].wager = validWager
        hideWagerField()
        submitLabel?.run(SKAction.fadeOut(withDuration: 0.3))

        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.run { [weak self] in
                self?.revealCategory()
            }
        ]))
    }

    private func submitAnswer() {
        completeAnswerPhase()
    }

    private func flashInvalidInput() {
        guard let field = wagerTextField else { return }
        field.layer.borderColor = UIColor.systemRed.cgColor
        field.layer.borderWidth = 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            field.layer.borderWidth = 0
        }
    }

    private func removeTextFields() {
        hideWagerField()
        hideAnswerField()
    }

    private func launchConfetti() {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 120
        emitter.particleLifetime = 4
        emitter.particleSpeed = 160
        emitter.particleSpeedRange = 80
        emitter.particleAlpha = 0.9
        emitter.particleAlphaRange = 0.2
        emitter.particleScale = 0.35
        emitter.particleScaleRange = 0.2
        emitter.particleRotation = .pi
        emitter.particleRotationRange = .pi
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 8
        emitter.particleColorSequence = nil
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = .alpha
        emitter.particleColor = .systemPink

        let colors: [UIColor] = [.systemPink, .systemTeal, .systemYellow, .white]
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: colors, times: [0, 0.3, 0.6, 1.0])
        emitter.particleTexture = makeParticleTexture()

        addChild(emitter)

        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 4.0),
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }

    private func makeParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }

    private func startCorgiDance() {
        let corgiSize = CGSize(width: 140, height: 110)
        let corgiNode: SKSpriteNode
        if let texture = SKTexture(imageNamedIfAvailable: "corgiDance") {
            corgiNode = SKSpriteNode(texture: texture, size: corgiSize)
        } else {
            corgiNode = SKSpriteNode(color: UIColor(red: 255/255, green: 183/255, blue: 77/255, alpha: 1), size: corgiSize)
            corgiNode.addCorgiDetails()
        }

        corgiNode.position = CGPoint(x: size.width / 2, y: 200)
        corgiNode.zPosition = 10
        corgiNode.name = "corgiDanceNode"
        addChild(corgiNode)

        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: .pi / 12, duration: 0.25),
            SKAction.rotate(byAngle: -.pi / 6, duration: 0.25),
            SKAction.rotate(byAngle: .pi / 12, duration: 0.25)
        ])
        let hopUp = SKAction.moveBy(x: 0, y: 30, duration: 0.25)
        hopUp.timingMode = .easeOut
        let hopDown = SKAction.moveBy(x: 0, y: -30, duration: 0.25)
        hopDown.timingMode = .easeIn
        let hopSequence = SKAction.sequence([hopUp, hopDown])
        let sparkle = SKAction.group([wiggle, hopSequence])
        corgiNode.run(SKAction.repeatForever(sparkle))
    }

    // MARK: - Touch Handling

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        guard tappedNodes.contains(where: { $0.name == "submitButton" }) else { return }

        switch phase {
        case .wager:
            submitWager()
        case .answer:
            submitAnswer()
        default:
            break
        }
    }
}

// MARK: - UITextFieldDelegate

extension FinalJeopardyScene: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == answerTextField {
            submitAnswer()
        } else if textField == wagerTextField {
            submitWager()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == wagerTextField {
            let allowed = CharacterSet.decimalDigits
            if string.rangeOfCharacter(from: allowed.inverted) != nil {
                return false
            }
        }
        return true
    }
}

// MARK: - Convenience Extensions

private extension SKTexture {
    convenience init?(imageNamedIfAvailable name: String) {
        if UIImage(named: name) != nil {
            self.init(imageNamed: name)
        } else {
            return nil
        }
    }
}

private extension SKSpriteNode {
    func addCorgiDetails() {
        let earLeft = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(x: -40, y: 40, width: 30, height: 40), cornerRadius: 8).cgPath)
        earLeft.fillColor = UIColor(red: 255/255, green: 204/255, blue: 128/255, alpha: 1)
        earLeft.strokeColor = .clear
        earLeft.zPosition = 1
        addChild(earLeft)

        let earRight = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(x: 10, y: 40, width: 30, height: 40), cornerRadius: 8).cgPath)
        earRight.fillColor = UIColor(red: 255/255, green: 204/255, blue: 128/255, alpha: 1)
        earRight.strokeColor = .clear
        earRight.zPosition = 1
        addChild(earRight)

        let face = SKShapeNode(path: UIBezierPath(ovalIn: CGRect(x: -40, y: -10, width: 80, height: 60)).cgPath)
        face.fillColor = .white
        face.strokeColor = .clear
        face.zPosition = 2
        addChild(face)

        let eyeLeft = SKShapeNode(circleOfRadius: 6)
        eyeLeft.fillColor = .black
        eyeLeft.position = CGPoint(x: -20, y: 10)
        eyeLeft.zPosition = 3
        addChild(eyeLeft)

        let eyeRight = SKShapeNode(circleOfRadius: 6)
        eyeRight.fillColor = .black
        eyeRight.position = CGPoint(x: 20, y: 10)
        eyeRight.zPosition = 3
        addChild(eyeRight)

        let nosePath = UIBezierPath()
        nosePath.move(to: CGPoint(x: -6, y: -5))
        nosePath.addLine(to: CGPoint(x: 6, y: -5))
        nosePath.addLine(to: CGPoint(x: 0, y: -15))
        nosePath.close()

        let nose = SKShapeNode(path: nosePath.cgPath)
        nose.fillColor = .black
        nose.strokeColor = .clear
        nose.zPosition = 3
        addChild(nose)

        let tail = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(x: 60, y: -10, width: 26, height: 20), cornerRadius: 10).cgPath)
        tail.fillColor = UIColor(red: 255/255, green: 204/255, blue: 128/255, alpha: 1)
        tail.strokeColor = .clear
        tail.zPosition = 1
        addChild(tail)

        let wagLeft = SKAction.rotate(byAngle: .pi / 12, duration: 0.15)
        let wagRight = wagLeft.reversed()
        tail.run(SKAction.repeatForever(SKAction.sequence([wagLeft, wagRight])))
    }
}
