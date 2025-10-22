import SpriteKit

/// Landing screen for the game that lets the player start a new session or pick
/// a corgi avatar.  The scene intentionally keeps logic lightweight so that it
/// can run on both device and in automated UI tests without needing UIKit
/// subclasses.
final class MainMenuScene: SKScene {
    private enum MenuState {
        case main
        case customization
    }

    private let gameState = GameState.shared

    private let mainContainer = SKNode()
    private let customizationContainer = SKNode()
    private let selectionIndicator = SKShapeNode(rectOf: CGSize(width: 150, height: 150), cornerRadius: 22)

    private let titleLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Corgi Jeopardy"
        label.fontSize = 56
        label.fontColor = .white
        return label
    }()

    private let playButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Play Game"
        label.name = "playButton"
        label.fontSize = 36
        label.fontColor = .white
        return label
    }()

    private let customizeButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = "Customize Corgi"
        label.name = "customizeButton"
        label.fontSize = 30
        label.fontColor = .white
        return label
    }()

    private let backButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = "Back"
        label.name = "backButton"
        label.fontSize = 26
        label.fontColor = .white
        return label
    }()

    private let confirmButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Confirm"
        label.name = "confirmButton"
        label.fontSize = 32
        label.fontColor = .white
        return label
    }()

    private var menuState: MenuState = .main
    private var avatarNodes: [SKSpriteNode] = []
    private var selectedAvatarName: String? {
        didSet { updateSelectionIndicator() }
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = SKColor(red: 16/255, green: 32/255, blue: 64/255, alpha: 1)

        addChild(mainContainer)
        addChild(customizationContainer)
        customizationContainer.isHidden = true

        setupMainMenu()
        layoutMainMenu()
        configureSelectionIndicator()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutMainMenu()
        if menuState == .customization {
            layoutCustomizationMenu()
        }
    }

    // MARK: - Menu Construction

    private func setupMainMenu() {
        mainContainer.removeAllChildren()
        mainContainer.addChild(titleLabel)
        mainContainer.addChild(playButton)
        mainContainer.addChild(customizeButton)
    }

    private func layoutMainMenu() {
        let midX = size.width / 2
        titleLabel.position = CGPoint(x: midX, y: size.height * 0.65)
        playButton.position = CGPoint(x: midX, y: size.height * 0.45)
        customizeButton.position = CGPoint(x: midX, y: size.height * 0.35)
    }

    private func configureSelectionIndicator() {
        selectionIndicator.strokeColor = SKColor.yellow
        selectionIndicator.lineWidth = 6
        selectionIndicator.isHidden = true
        selectionIndicator.zPosition = 10
        customizationContainer.addChild(selectionIndicator)
    }

    private func showCustomizationMenu() {
        menuState = .customization
        mainContainer.isHidden = true
        customizationContainer.isHidden = false
        buildCustomizationMenu()
        layoutCustomizationMenu()
    }

    private func showMainMenu() {
        menuState = .main
        mainContainer.isHidden = false
        customizationContainer.isHidden = true
    }

    private func buildCustomizationMenu() {
        customizationContainer.removeAllChildren()
        customizationContainer.addChild(selectionIndicator)
        customizationContainer.addChild(backButton)
        customizationContainer.addChild(confirmButton)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Choose Your Corgi"
        title.fontSize = 42
        title.fontColor = .white
        title.name = "customizationTitle"
        customizationContainer.addChild(title)

        let instructions = SKLabelNode(fontNamed: "AvenirNext-Regular")
        instructions.text = "Tap a corgi to select it, then confirm."
        instructions.fontSize = 24
        instructions.fontColor = .white
        instructions.name = "customizationInstructions"
        customizationContainer.addChild(instructions)

        avatarNodes = gameState.availableAvatarNames.enumerated().map { index, name in
            let sprite = makeAvatarNode(named: name, fallbackIndex: index)
            sprite.name = "avatar_\(name)"
            return sprite
        }

        let avatarContainer = SKNode()
        avatarContainer.name = "avatarContainer"
        let spacing = (avatarNodes.first?.size.width ?? 140) + 30
        let totalWidth = CGFloat(max(avatarNodes.count - 1, 0)) * spacing
        let startX = -totalWidth / 2
        for (index, node) in avatarNodes.enumerated() {
            node.position = CGPoint(x: startX + CGFloat(index) * spacing, y: 0)
            avatarContainer.addChild(node)
        }
        customizationContainer.addChild(avatarContainer)

        selectedAvatarName = gameState.playerAvatars[gameState.humanPlayerId]
        updateSelectionIndicator()
    }

    private func layoutCustomizationMenu() {
        guard let title = customizationContainer.childNode(withName: "customizationTitle") as? SKLabelNode,
              let instructions = customizationContainer.childNode(withName: "customizationInstructions") as? SKLabelNode,
              let avatarContainer = customizationContainer.childNode(withName: "avatarContainer") else { return }

        let midX = size.width / 2
        title.position = CGPoint(x: midX, y: size.height * 0.72)
        instructions.position = CGPoint(x: midX, y: size.height * 0.62)
        avatarContainer.position = CGPoint(x: midX, y: size.height * 0.45)
        confirmButton.position = CGPoint(x: midX, y: size.height * 0.25)
        backButton.position = CGPoint(x: midX, y: size.height * 0.18)
        updateSelectionIndicator()
    }

    private func makeAvatarNode(named imageName: String, fallbackIndex: Int) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: imageName)
        let size = CGSize(width: 140, height: 140)
        if texture.size() == .zero {
            let colors: [SKColor] = [
                SKColor(red: 244/255, green: 162/255, blue: 97/255, alpha: 1),
                SKColor(red: 233/255, green: 196/255, blue: 106/255, alpha: 1),
                SKColor(red: 42/255, green: 157/255, blue: 143/255, alpha: 1),
                SKColor(red: 38/255, green: 70/255, blue: 83/255, alpha: 1),
                SKColor(red: 231/255, green: 111/255, blue: 81/255, alpha: 1)
            ]
            let node = SKSpriteNode(color: colors[fallbackIndex % colors.count], size: size)
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = imageName.replacingOccurrences(of: ".png", with: "").capitalized
            label.fontSize = 18
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            node.addChild(label)
            return node
        }

        let sprite = SKSpriteNode(texture: texture, color: .clear, size: size)
        return sprite
    }

    private func updateSelectionIndicator() {
        guard menuState == .customization,
              let selectedName = selectedAvatarName,
              let targetNode = avatarNodes.first(where: { $0.name == "avatar_\(selectedName)" }) else {
            selectionIndicator.isHidden = true
            return
        }

        selectionIndicator.isHidden = false
        let targetPosition = customizationContainer.convert(targetNode.position, from: targetNode.parent ?? customizationContainer)
        selectionIndicator.position = targetPosition
    }

    // MARK: - Navigation

    private func confirmSelection() {
        guard let avatar = selectedAvatarName else { return }
        gameState.setAvatar(avatar, for: gameState.humanPlayerId)
        gameState.assignRandomAvatarsToAI(excluding: [avatar])
        showMainMenu()
    }

    private func startGame() {
        gameState.ensureAIAvatarsAssigned()
        gameState.resetForNewGame()
        let nextScene = GameBoardScene(size: size)
        nextScene.scaleMode = scaleMode
        view?.presentScene(nextScene, transition: SKTransition.fade(withDuration: 0.5))
    }

    // MARK: - Touch Handling

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        switch menuState {
        case .main:
            if nodes.contains(where: { $0 === playButton }) {
                startGame()
            } else if nodes.contains(where: { $0 === customizeButton }) {
                showCustomizationMenu()
            }
        case .customization:
            if nodes.contains(where: { $0 === backButton }) {
                showMainMenu()
            } else if nodes.contains(where: { $0 === confirmButton }) {
                confirmSelection()
            } else if let tappedAvatar = nodes.first(where: { $0.name?.hasPrefix("avatar_") == true }) {
                selectedAvatarName = tappedAvatar.name?.replacingOccurrences(of: "avatar_", with: "")
            }
        }
    }
}
