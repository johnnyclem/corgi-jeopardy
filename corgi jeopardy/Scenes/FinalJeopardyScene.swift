import SpriteKit

final class FinalJeopardyScene: SKScene {
    private let gameState = GameState.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.12, blue: 0.2, alpha: 1.0)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Final Jeopardy!"
        title.fontSize = 36
        title.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.35, alpha: 1.0)
        title.position = CGPoint(x: 0, y: size.height / 2 - 120)
        addChild(title)

        let info = SKLabelNode(fontNamed: "AvenirNext-Regular")
        info.text = "Final round logic coming soon. Scores carry over!"
        info.fontSize = 22
        info.fontColor = .white
        info.position = CGPoint(x: 0, y: 0)
        addChild(info)

        var offset: CGFloat = -80
        for (player, score) in gameState.playerScores.sorted(by: { $0.value > $1.value }) {
            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = "\(player): $\(score)"
            label.fontSize = 24
            label.fontColor = .white
            label.position = CGPoint(x: 0, y: offset)
            addChild(label)
            offset -= 40
        }
    }
}
