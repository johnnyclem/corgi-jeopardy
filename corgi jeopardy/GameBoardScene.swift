import SpriteKit

final class GameBoardScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(named: "BoardBackground") ?? .systemBlue
        if childNode(withName: "placeholder") == nil {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "Game Board Placeholder"
            label.fontSize = min(32, size.width * 0.06)
            label.position = CGPoint(x: frame.midX, y: frame.midY)
            label.name = "placeholder"
            addChild(label)
        }
    }
}
