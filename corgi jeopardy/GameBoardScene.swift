import SpriteKit

final class GameBoardScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.1, alpha: 1.0)
        addPlaceholderLabel()
    }

    private func addPlaceholderLabel() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Game Board Coming Soon"
        label.fontSize = 44
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if let label = children.first(where: { $0 is SKLabelNode }) {
            label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        }
    }
}
