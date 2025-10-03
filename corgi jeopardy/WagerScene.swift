import SpriteKit
import UIKit

/// Scene displayed when a player hits a Daily Double and must enter a wager.
class WagerScene: SKScene {
    private let clue: Clue
    private let promptLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let feedbackLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private var wagerField: UITextField?
    private let maxWager: Int

    init(size: CGSize, clue: Clue) {
        self.clue = clue
        self.maxWager = max(0, GameState.shared.currentPlayerScore)
        super.init(size: size)
        self.scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black

        promptLabel.text = "Daily Double! Wager up to your score: $\(maxWager)"
        promptLabel.fontSize = 28
        promptLabel.numberOfLines = 0
        promptLabel.preferredMaxLayoutWidth = size.width * 0.8
        promptLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        addChild(promptLabel)

        feedbackLabel.fontSize = 20
        feedbackLabel.fontColor = .red
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        feedbackLabel.alpha = 0
        addChild(feedbackLabel)

        let submitButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        submitButton.name = "submitButton"
        submitButton.text = "Submit Wager"
        submitButton.fontSize = 24
        submitButton.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        addChild(submitButton)

        let cancelButton = SKLabelNode(fontNamed: "AvenirNext-Regular")
        cancelButton.name = "cancelButton"
        cancelButton.text = "Cancel"
        cancelButton.fontSize = 20
        cancelButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        addChild(cancelButton)

        configureTextField(in: view)
    }

    private func configureTextField(in view: SKView) {
        let width = min(view.bounds.width * 0.6, 280)
        let textFieldFrame = CGRect(x: (view.bounds.width - width) / 2,
                                    y: view.bounds.height * 0.45,
                                    width: width,
                                    height: 44)
        let textField = UITextField(frame: textFieldFrame)
        textField.placeholder = "Enter wager"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.becomeFirstResponder()
        view.addSubview(textField)
        wagerField = textField
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        wagerField?.removeFromSuperview()
        wagerField = nil
    }

    private func showValidation(message: String) {
        feedbackLabel.text = message
        feedbackLabel.alpha = 1
        feedbackLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3)
        ]))
    }

    private func validateAndProceed() {
        guard let text = wagerField?.text, let wager = Int(text) else {
            showValidation(message: "Please enter a valid number.")
            return
        }

        guard wager >= 0 && wager <= maxWager else {
            showValidation(message: "Wager must be between 0 and $\(maxWager).")
            return
        }

        GameState.shared.currentWager = wager
        presentClueScene()
    }

    private func presentClueScene() {
        guard let view = view else { return }
        let clueScene = ClueScene(size: view.bounds.size, clue: clue, isWager: true)
        view.presentScene(clueScene, transition: SKTransition.crossFade(withDuration: 0.5))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        if nodes.contains(where: { $0.name == "submitButton" }) {
            validateAndProceed()
        } else if nodes.contains(where: { $0.name == "cancelButton" }) {
            wagerField?.text = ""
            presentClueScene()
        }
    }
}
