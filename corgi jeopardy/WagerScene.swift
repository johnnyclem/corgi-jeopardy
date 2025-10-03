import SpriteKit
import UIKit

/// Scene that collects wager input for Daily Double and Daily Doo-Doo specials.
final class WagerScene: SKScene, UITextFieldDelegate {
    private let wagerType: GameState.WagerType
    private let opponent: GameState.Player?
    private let clueValue: Int
    private let promptLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let feedbackLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let submitButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var wagerTextField: UITextField?

    init(size: CGSize, wagerType: GameState.WagerType, opponent: GameState.Player? = nil, clueValue: Int) {
        self.wagerType = wagerType
        self.opponent = opponent
        self.clueValue = clueValue
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func dailyDooDooScene(size: CGSize, clueValue: Int) -> WagerScene {
        let targetOpponent = GameState.shared.defaultDailyDooDooOpponent(excluding: GameState.shared.currentPlayer)
        return WagerScene(size: size, wagerType: .dailyDooDoo, opponent: targetOpponent, clueValue: clueValue)
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.11, green: 0.16, blue: 0.29, alpha: 1.0)
        configurePrompt()
        configureTextField(in: view)
        configureSubmitButton()
        configureFeedbackLabel()
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        removeTextField()
    }

    private func configurePrompt() {
        promptLabel.fontSize = 34
        promptLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        promptLabel.numberOfLines = 0
        promptLabel.preferredMaxLayoutWidth = size.width * 0.8
        promptLabel.verticalAlignmentMode = .center
        promptLabel.horizontalAlignmentMode = .center

        let text: String
        switch wagerType {
        case .dailyDouble:
            let playerScore = GameState.shared.score(for: GameState.shared.currentPlayer)
            text = "Daily Double!\nWager up to your score: $\(playerScore)"
        case .dailyDooDoo:
            let opponentPlayer = opponent ?? GameState.shared.defaultDailyDooDooOpponent(excluding: GameState.shared.currentPlayer)
            let opponentScore = opponentPlayer.map { GameState.shared.score(for: $0) } ?? 0
            text = "Daily Doo-Doo!\nWager opponent's score: $\(opponentScore)"
        }

        promptLabel.text = text
        addChild(promptLabel)
    }

    private func configureTextField(in view: SKView) {
        let textField = UITextField(frame: CGRect(x: view.frame.midX - 120, y: view.frame.midY - 25, width: 240, height: 50))
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.placeholder = "Enter wager"
        textField.delegate = self
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        textField.textAlignment = .center
        view.addSubview(textField)
        textField.becomeFirstResponder()
        wagerTextField = textField
    }

    private func configureSubmitButton() {
        submitButton.fontSize = 30
        submitButton.text = "Submit Wager"
        submitButton.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        submitButton.name = "submit"
        addChild(submitButton)
    }

    private func configureFeedbackLabel() {
        feedbackLabel.fontSize = 22
        feedbackLabel.fontColor = .red
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        feedbackLabel.verticalAlignmentMode = .center
        feedbackLabel.horizontalAlignmentMode = .center
        feedbackLabel.numberOfLines = 0
        feedbackLabel.preferredMaxLayoutWidth = size.width * 0.8
        feedbackLabel.alpha = 0.0
        addChild(feedbackLabel)
    }

    private func showFeedback(_ text: String) {
        feedbackLabel.text = text
        feedbackLabel.alpha = 1.0
        let fade = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3)
        ])
        feedbackLabel.run(fade)
    }

    private func removeTextField() {
        wagerTextField?.removeFromSuperview()
        wagerTextField = nil
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        if nodes.contains(submitButton) {
            submitTapped()
        }
    }

    private func submitTapped() {
        guard let text = wagerTextField?.text, !text.isEmpty, let amount = Int(text) else {
            showFeedback("Enter a valid number!")
            return
        }

        let maxWager: Int
        switch wagerType {
        case .dailyDouble:
            maxWager = max(GameState.shared.score(for: GameState.shared.currentPlayer), 0)
        case .dailyDooDoo:
            maxWager = GameState.shared.maxDailyDooDooWager(against: opponent)
        }

        guard amount >= 0 else {
            showFeedback("Wager must be at least $0")
            return
        }

        guard amount <= maxWager else {
            showFeedback("Wager can't exceed $\(maxWager)")
            return
        }

        GameState.shared.setActiveWager(amount: amount, type: wagerType, opponent: opponent)

        removeTextField()

        // Transition to clue scene would normally happen here.
        if let view = view {
            let clueScene = ClueScene(size: size, clueValue: clueValue)
            view.presentScene(clueScene, transition: .doorsOpenVertical(withDuration: 0.5))
        }
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow numeric characters.
        if string.isEmpty { return true }
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
    }
}
