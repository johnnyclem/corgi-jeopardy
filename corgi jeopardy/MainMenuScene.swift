import SpriteKit

/// Landing screen for the game that lets players start a session or customize
/// their corgi avatar.
final class MainMenuScene: SKScene {
    private enum MenuState {
        case main
        case customization
    }

    private let gameState = GameState.shared

    private let mainContainer = SKNode()
    private let submenuContainer = SKNode()

    private let titleLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Corgi Jeopardy"
        label.fontSize = 56
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        return label
    }()

    private let playButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Play Game"
        label.fontSize = 36
        label.fontColor = .white
        label.name = "playButton"
        label.verticalAlignmentMode = .center
        return label
    }()

    private let customizeButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = "Customize Corgi"
        label.fontSize = 28
        label.fontColor = .white
        label.name = "customizeButton"
        label.verticalAlignmentMode = .center
        return label
    }()

    private let customizeTitle: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Choose Your Corgi"
        label.fontSize = 42
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        return label
    }()

    private let instructionsLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = "Tap a corgi to select it, then confirm."
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        return label
    }()

    private let confirmButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Confirm"
        label.fontSize = 32
        label.fontColor = .white
        label.name = "confirmButton"
        label.verticalAlignmentMode = .center
        return label
    }()

    private let backButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = "Back"
        label.fontSize = 26
        label.fontColor = .white
        label.name = "backButton"
        label.verticalAlignmentMode = .center
        return label
    }()

    private let selectionIndicator: SKShapeNode = {
        let indicator = SKShapeNode(rectOf: CGSize(width: 150, height: 150), cornerRadius: 20)
        indicator.strokeColor = SKColor.yellow
        indicator.lineWidth = 6
        indicator.zPosition = 10
        indicator.isHidden = true
        return indicator
    }()

    private var menuState: MenuState = .main
    private var avatarNodes: [SKSpriteNode] = []
    private var selectedAvatarName: String? {
        didSet { updateSelectionIndicator() }
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 16 / 255, green: 32 / 255, blue: 64 / 255, alpha: 1)

        addChild(mainContainer)
        addChild(submenuContainer)
        submenuContainer.isHidden = true

        setupMainMenu()
        layoutMainMenu()
    }

    // MARK: - Setup

    private func setupMainMenu() {
        mainContainer.removeAllChildren()
        mainContainer.addChild(titleLabel)
        mainContainer.addChild(playButton)
        mainContainer.addChild(customizeButton)
    }

    private func layoutMainMenu() {
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        customizeButton.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
    }

    private func setupCustomizationMenu() {
        submenuContainer.removeAllChildren()
        submenuContainer.addChild(customizeTitle)
        submenuContainer.addChild(instructionsLabel)
        submenuContainer.addChild(confirmButton)
        submenuContainer.addChild(backButton)
        submenuContainer.addChild(selectionIndicator)

        let avatarNames = gameState.availableAvatarNames
        avatarNodes = avatarNames.enumerated().map { index, name in
            let node = makeAvatarNode(imageName: name, colorIndex: index)
            node.name = "avatar_\(name)"
            return node
        }

        let avatarContainer = SKNode()
        avatarContainer.name = "avatarContainer"
        let spacing = (avatarNodes.first?.size.width ?? 140) + 30
        let totalWidth = CGFloat(max(avatarNodes.count - 1, 0)) * spacing
        let startingX = -totalWidth / 2
        for (index, node) in avatarNodes.enumerated() {
            let positionX = startingX + CGFloat(index) * spacing
            node.position = CGPoint(x: positionX, y: 0)
            avatarContainer.addChild(node)
        }
        avatarContainer.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        submenuContainer.addChild(avatarContainer)

        customizeTitle.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        instructionsLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        confirmButton.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        backButton.position = CGPoint(x: size.width / 2, y: size.height * 0.18)

        selectedAvatarName = gameState.playerAvatars[gameState.humanPlayerId]
        updateSelectionIndicator()
    }

    private func makeAvatarNode(imageName: String, colorIndex: Int) -> SKSpriteNode {
        let avatarSize = CGSize(width: 140, height: 140)
        let texture = SKTexture(imageNamed: imageName)
        if texture.size() == .zero {
            let placeholder = SKSpriteNode(color: placeholderColor(for: colorIndex), size: avatarSize)
            placeholder.name = "avatar_\(imageName)"
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = imageName.replacingOccurrences(of: ".png", with: "").capitalized
            label.fontSize = 20
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            placeholder.addChild(label)
            return placeholder
        } else {
            let sprite = SKSpriteNode(texture: texture, color: .clear, size: avatarSize)
            sprite.name = "avatar_\(imageName)"
            return sprite
        }
    }

    private func placeholderColor(for index: Int) -> SKColor {
        let palette: [SKColor] = [
            SKColor(red: 244 / 255, green: 162 / 255, blue: 97 / 255, alpha: 1),
            SKColor(red: 233 / 255, green: 196 / 255, blue: 106 / 255, alpha: 1),
            SKColor(red: 42 / 255, green: 157 / 255, blue: 143 / 255, alpha: 1),
            SKColor(red: 38 / 255, green: 70 / 255, blue: 83 / 255, alpha: 1),
            SKColor(red: 231 / 255, green: 111 / 255, blue: 81 / 255, alpha: 1)
        ]
        return palette[index % palette.count]
    }

    private func updateSelectionIndicator() {
        guard let selectedName = selectedAvatarName,
              let targetNode = avatarNodes.first(where: { $0.name == "avatar_\(selectedName)" }) else {
            selectionIndicator.isHidden = true
            return
        }

        selectionIndicator.isHidden = false
        selectionIndicator.position = submenuContainer.convert(targetNode.position, from: targetNode.parent ?? submenuContainer)
    }

    // MARK: - Scene transitions

    private func showMainMenu() {
        menuState = .main
        mainContainer.isHidden = false
        submenuContainer.isHidden = true
    }

    private func showCustomizationMenu() {
        menuState = .customization
        mainContainer.isHidden = true
        submenuContainer.isHidden = false
        setupCustomizationMenu()
    }

    private func confirmSelection() {
        guard let avatarName = selectedAvatarName else { return }
        gameState.setAvatar(avatarName, for: gameState.humanPlayerId)
        gameState.assignRandomAvatarsToAI(excluding: [avatarName])
        showMainMenu()
    }

    private func startGame() {
        gameState.ensureAIAvatarsAssigned()
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        switch menuState {
        case .main:
            if nodesAtPoint.contains(where: { $0.name == playButton.name }) {
                startGame()
            } else if nodesAtPoint.contains(where: { $0.name == customizeButton.name }) {
                showCustomizationMenu()
            }
        case .customization:
            if let avatarNode = nodesAtPoint.first(where: { $0.name?.hasPrefix("avatar_") == true }),
               let name = avatarNode.name?.replacingOccurrences(of: "avatar_", with: "") {
                selectedAvatarName = name
            } else if nodesAtPoint.contains(where: { $0.name == confirmButton.name }) {
                confirmSelection()
            } else if nodesAtPoint.contains(where: { $0.name == backButton.name }) {
                showMainMenu()
            }
        }
    }
}
