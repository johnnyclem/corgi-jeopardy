import SpriteKit
import AVFoundation

/// A lightweight wager screen that highlights the corgi companion while the
/// player decides on an amount for Daily Double or Daily Doo-Doo events. This
/// scene focuses on the thematic animations introduced in Ticket 6.1.
final class WagerScene: SKScene {
    private let corgi = CorgiCharacter()
    private let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let promptLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")

    override func didMove(to view: SKView) {
        applyThemedBackground()
        configureLabels()
        layoutCorgi()
    }

    private func applyThemedBackground() {
        backgroundColor = SKColor(red: 0.09, green: 0.13, blue: 0.24, alpha: 1.0)

        let gradient = SKSpriteNode(color: SKColor(red: 0.18, green: 0.28, blue: 0.49, alpha: 0.6), size: CGSize(width: size.width * 0.9, height: size.height * 0.9))
        gradient.zPosition = -1
        gradient.position = CGPoint(x: frame.midX, y: frame.midY)
        gradient.alpha = 0.75
        addChild(gradient)
    }

    private func configureLabels() {
        titleLabel.text = "Daily Double"
        titleLabel.fontSize = 48
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 140)
        addChild(titleLabel)

        promptLabel.text = "Set your wager and tap to see the corgi hype you up!"
        promptLabel.fontSize = 24
        promptLabel.position = CGPoint(x: frame.midX, y: frame.midY - 180)
        addChild(promptLabel)
    }

    private func layoutCorgi() {
        let position = CGPoint(x: frame.midX, y: frame.midY + 80)
        corgi.addToScene(self, position: position)
    }

    func playWagerCelebration() {
        promptLabel.text = "Wager locked in! The corgi is cheering for you."
        corgi.playWagerAnimation()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playWagerCelebration()
    }
}
