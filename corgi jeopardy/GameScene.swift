import SpriteKit

/// Lightweight placeholder gameplay scene that demonstrates avatar placement.
final class GameScene: SKScene {
    private let gameState = GameState.shared
    private var avatarContainers: [SKNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 10 / 255, green: 54 / 255, blue: 109 / 255, alpha: 1)
        removeAllChildren()
        avatarContainers.removeAll()

        addTitle()
        displaySelectedAvatars()
    }

    private func addTitle() {
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Let the Games Begin!"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitle.text = "Avatars are ready for action."
        subtitle.fontSize = 24
        subtitle.fontColor = .white
        subtitle.position = CGPoint(x: size.width / 2, y: title.position.y - 60)
        addChild(subtitle)
    }

    private func displaySelectedAvatars() {
        let players = gameState.playerOrder
        guard !players.isEmpty else { return }

        let avatarSize = CGSize(width: 140, height: 140)
        let spacing = avatarSize.width + 40
        let totalWidth = CGFloat(max(players.count - 1, 0)) * spacing
        let startingX = size.width / 2 - totalWidth / 2
        let baselineY = size.height * 0.45

        for (index, playerId) in players.enumerated() {
            let container = SKNode()
            container.position = CGPoint(x: startingX + CGFloat(index) * spacing, y: baselineY)
            addChild(container)
            avatarContainers.append(container)

            let avatarName = gameState.avatarName(for: playerId)
            let avatarNode = makeAvatarSprite(named: avatarName, fallbackIndex: index)
            avatarNode.size = avatarSize
            container.addChild(avatarNode)

            let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nameLabel.text = playerId
            nameLabel.fontSize = 24
            nameLabel.fontColor = .white
            nameLabel.verticalAlignmentMode = .center
            nameLabel.horizontalAlignmentMode = .center
            nameLabel.position = CGPoint(x: 0, y: -avatarSize.height / 2 - 26)
            container.addChild(nameLabel)
        }
    }

    private func makeAvatarSprite(named imageName: String, fallbackIndex: Int) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: imageName)
        if texture.size() == .zero {
            let colors: [SKColor] = [
                SKColor(red: 244 / 255, green: 162 / 255, blue: 97 / 255, alpha: 1),
                SKColor(red: 233 / 255, green: 196 / 255, blue: 106 / 255, alpha: 1),
                SKColor(red: 42 / 255, green: 157 / 255, blue: 143 / 255, alpha: 1),
                SKColor(red: 38 / 255, green: 70 / 255, blue: 83 / 255, alpha: 1),
                SKColor(red: 231 / 255, green: 111 / 255, blue: 81 / 255, alpha: 1)
            ]
            let node = SKSpriteNode(color: colors[fallbackIndex % colors.count], size: CGSize(width: 140, height: 140))
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = imageName.replacingOccurrences(of: ".png", with: "").capitalized
            label.fontSize = 20
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            node.addChild(label)
            return node
        }

        return SKSpriteNode(texture: texture)
    }
}
