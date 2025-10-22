import SpriteKit
import UIKit

final class WagerScene: SKScene {
    private let context: GameState.WagerContext
    private let promptLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let feedbackLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private var wagerField: UITextField?

    private var maximumWager: Int {
        switch context.kind {
        case let .dailyDouble(max):
            return max
        case let .dailyDooDoo(_, max):
            return max
        }
    }

    init(size: CGSize, context: GameState.WagerContext) {
        self.context = context
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = SKColor(red: 10/255, green: 20/255, blue: 48/255, alpha: 1)

        configurePrompt()
        layoutButtons()
        configureTextField(in: view)
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        wagerField?.removeFromSuperview()
        wagerField = nil
    }

    private func configurePrompt() {
        promptLabel.fontSize = 28
        promptLabel.numberOfLines = 0
        promptLabel.preferredMaxLayoutWidth = size.width * 0.8
        promptLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        promptLabel.text = promptText()
        addChild(promptLabel)

        feedbackLabel.fontSize = 20
        feedbackLabel.fontColor = .red
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        feedbackLabel.alpha = 0
        addChild(feedbackLabel)
    }

    private func promptText() -> String {
        switch context.kind {
        case .dailyDouble:
            let max = maximumWager
            return "Daily Double! Wager up to your score: $\(max)"
        case let .dailyDooDoo(opponent, _):
            return "Daily Doo-Doo! Wager up to \(opponent.displayName)'s score."
        }
    }

    private func layoutButtons() {
        let submit = SKLabelNode(fontNamed: "AvenirNext-Bold")
        submit.text = "Submit Wager"
        submit.name = "submit"
        submit.fontSize = 24
        submit.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        addChild(submit)

        let cancel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        cancel.text = "Cancel"
        cancel.name = "cancel"
        cancel.fontSize = 20
        cancel.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        addChild(cancel)
    }

    private func configureTextField(in view: SKView) {
        let width = min(view.bounds.width * 0.6, 280)
        let frame = CGRect(x: (view.bounds.width - width) / 2,
                           y: view.bounds.height * 0.5,
                           width: width,
                           height: 44)
        let field = UITextField(frame: frame)
        field.borderStyle = .roundedRect
        field.keyboardType = .numberPad
        field.placeholder = "Enter wager"
        view.addSubview(field)
        field.becomeFirstResponder()
        wagerField = field
    }

    private func showValidation(message: String) {
        feedbackLabel.text = message
        feedbackLabel.alpha = 1
        feedbackLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3)
        ]))
    }

    private func submitWager() {
        guard let text = wagerField?.text, let value = Int(text) else {
            showValidation(message: "Please enter a valid number.")
            return
        }

        guard value >= 0 && value <= maximumWager else {
            showValidation(message: "Wager must be between 0 and $\(maximumWager).")
            return
        }

        GameState.shared.setActiveWager(amount: value, for: context)
        presentClueScene()
    }

    private func presentClueScene() {
        guard let view = view else { return }
        let clueScene = ClueScene(size: view.bounds.size, clue: context.clue)
        clueScene.scaleMode = scaleMode
        view.presentScene(clueScene, transition: SKTransition.crossFade(withDuration: 0.4))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        if nodes.contains(where: { $0.name == "submit" }) {
            submitWager()
        } else if nodes.contains(where: { $0.name == "cancel" }) {
            GameState.shared.clearWager()
            presentClueScene()
        }
    }
}
