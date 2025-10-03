import SpriteKit
import AVFoundation

/// Displays an active clue and reacts with corgi themed animations and sound
/// effects whenever the player or AI answers the question. The scene is
/// intentionally lightweight for now; the focus of Ticket 6.1 is providing a
/// reusable home for the corgi animations and integrating the bark/whimper
/// audio cues.
final class ClueScene: SKScene {
    private let corgi = CorgiCharacter()
    private let clueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let instructionLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")

    override func didMove(to view: SKView) {
        applyThemedBackground()
        configureLabels()
        layoutCorgi()
    }

    private func applyThemedBackground() {
        backgroundColor = SKColor(red: 0.11, green: 0.15, blue: 0.28, alpha: 1.0)

        let vignette = SKShapeNode(rectOf: CGSize(width: size.width * 0.95, height: size.height * 0.95), cornerRadius: 32)
        vignette.fillColor = SKColor(red: 0.08, green: 0.12, blue: 0.23, alpha: 0.8)
        vignette.strokeColor = SKColor(red: 0.36, green: 0.55, blue: 0.93, alpha: 0.6)
        vignette.lineWidth = 4
        vignette.zPosition = -1
        vignette.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(vignette)
    }

    private func configureLabels() {
        clueLabel.text = "Corgi Clue Placeholder"
        clueLabel.fontSize = 42
        clueLabel.numberOfLines = 0
        clueLabel.preferredMaxLayoutWidth = size.width * 0.8
        clueLabel.position = CGPoint(x: frame.midX, y: frame.midY - 120)
        addChild(clueLabel)

        instructionLabel.text = "Tap left side for correct (bark), right side for wrong (whimper)."
        instructionLabel.fontSize = 20
        instructionLabel.position = CGPoint(x: frame.midX, y: clueLabel.position.y - 80)
        addChild(instructionLabel)
    }

    private func layoutCorgi() {
        let position = CGPoint(x: frame.midX, y: frame.midY + 160)
        corgi.addToScene(self, position: position)
    }

    func showCorrectAnswerAnimation() {
        instructionLabel.text = "Great job! The corgi is celebrating."
        corgi.reactToCorrectAnswer()
    }

    func showIncorrectAnswerAnimation() {
        instructionLabel.text = "Oh no! The corgi looks so sad."
        corgi.reactToIncorrectAnswer()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if location.x < frame.midX {
            showCorrectAnswerAnimation()
        } else {
            showIncorrectAnswerAnimation()
        }
    }
}
