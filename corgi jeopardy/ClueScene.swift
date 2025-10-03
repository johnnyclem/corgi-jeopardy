import SpriteKit
import UIKit

/// Scene responsible for presenting the clue and handling user answers.
class ClueScene: SKScene {
    private let clue: Clue
    private let isWager: Bool
    private let questionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let resultLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var answerField: UITextField?
    private var submitButton: SKLabelNode?

    init(size: CGSize, clue: Clue, isWager: Bool = false) {
        self.clue = clue
        self.isWager = isWager
        super.init(size: size)
        self.scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.07, blue: 0.16, alpha: 1.0)

        questionLabel.text = clue.question
        questionLabel.fontSize = 30
        questionLabel.numberOfLines = 0
        questionLabel.preferredMaxLayoutWidth = size.width * 0.8
        questionLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        addChild(questionLabel)

        resultLabel.fontSize = 26
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        resultLabel.alpha = 0
        addChild(resultLabel)

        let submit = SKLabelNode(fontNamed: "AvenirNext-Bold")
        submit.name = "submitAnswer"
        submit.text = "Submit Answer"
        submit.fontSize = 24
        submit.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        addChild(submit)
        submitButton = submit

        configureTextField(in: view)

        // Play the corgi sound effect when the clue appears.
        run(SKAction.playSoundFileNamed("corgi_bark.wav", waitForCompletion: false))
    }

    private func configureTextField(in view: SKView) {
        let width = min(view.bounds.width * 0.7, 320)
        let textFieldFrame = CGRect(x: (view.bounds.width - width) / 2,
                                    y: view.bounds.height * 0.55,
                                    width: width,
                                    height: 44)
        let textField = UITextField(frame: textFieldFrame)
        textField.placeholder = "Respond in the form of a question"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.autocapitalizationType = .sentences
        textField.delegate = self
        view.addSubview(textField)
        textField.becomeFirstResponder()
        answerField = textField
    }

    private func evaluateAnswer() {
        guard let text = answerField?.text else { return }

        let normalizedResponse = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedAnswer = clue.answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let isQuestionFormat = normalizedResponse.hasPrefix("what is") || normalizedResponse.hasPrefix("who is") || normalizedResponse.hasPrefix("where is")
        let containsAnswer = normalizedResponse.contains(normalizedAnswer)
        let isCorrect = isQuestionFormat && containsAnswer

        let wagerValue = isWager ? GameState.shared.currentWager : clue.value
        let delta = isCorrect ? wagerValue : -wagerValue
        GameState.shared.updateCurrentPlayerScore(by: delta)

        let resultText = isCorrect ? "Correct! +$\(wagerValue)" : "Incorrect! -$\(wagerValue)"
        resultLabel.text = resultText
        resultLabel.fontColor = isCorrect ? .green : .red
        resultLabel.alpha = 1

        answerField?.resignFirstResponder()
        answerField?.isEnabled = false
        submitButton?.alpha = 0.4
        submitButton?.isUserInteractionEnabled = false

        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                self?.returnToBoard()
            }
        ]))
    }

    private func returnToBoard() {
        guard let view = view else { return }
        let boardScene = GameScene(size: view.bounds.size)
        view.presentScene(boardScene, transition: SKTransition.fade(withDuration: 0.5))
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        answerField?.removeFromSuperview()
        answerField = nil
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        if nodes.contains(where: { $0.name == "submitAnswer" }) {
            evaluateAnswer()
        }
    }
}

extension ClueScene: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        evaluateAnswer()
        return true
    }
}
