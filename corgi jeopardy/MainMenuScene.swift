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
import UIKit

final class MainMenuScene: SKScene {

    private enum MenuNodeName: String {
        case newGame = "menu_new_game"
        case difficulty = "menu_difficulty"
        case highScores = "menu_high_scores"
        case quit = "menu_quit"
        case difficultyEasy = "menu_difficulty_easy"
        case difficultyMedium = "menu_difficulty_medium"
        case difficultyHard = "menu_difficulty_hard"
    }

    private enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var nodeName: MenuNodeName {
            switch self {
            case .easy:
                return .difficultyEasy
            case .medium:
                return .difficultyMedium
            case .hard:
                return .difficultyHard
            }
        }
    }

    private let buttonFontName = "AvenirNext-Bold"
    private var buttonLabels: [MenuNodeName: SKLabelNode] = [:]
    private var difficultyOptions: [Difficulty: SKLabelNode] = [:]
    private var difficultySelectionLabel: SKLabelNode?
    private var feedbackLabel: SKLabelNode?
    private var difficultyMenuVisible = false
    private var selectedDifficulty: Difficulty = .easy {
        didSet {
            difficultySelectionLabel?.text = "Difficulty: \(selectedDifficulty.rawValue)"
            updateDifficultyHighlight()
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        addBackground()
        addMenu()
        startCorgiFloaters()
        selectedDifficulty = .easy
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutMenuNodes()
    }

    private func addBackground() {
        let background = SKSpriteNode(texture: gradientTexture(for: size))
        background.name = "corgi_background"
        background.zPosition = -2
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.colorBlendFactor = 0
        addChild(background)

        let overlay = SKSpriteNode(color: UIColor(white: 0, alpha: 0.15), size: size)
        overlay.name = "corgi_background_overlay"
        overlay.zPosition = -1
        overlay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.alpha = 0.7
        addChild(overlay)
    }

    private func addMenu() {
        let titleLabel = SKLabelNode(fontNamed: buttonFontName)
        titleLabel.text = "Corgi Jeopardy"
        titleLabel.fontSize = 52
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)

        let buttons: [(MenuNodeName, String)] = [
            (.newGame, "New Game"),
            (.difficulty, "Difficulty"),
            (.highScores, "High Scores"),
            (.quit, "Quit")
        ]

        for (nodeName, title) in buttons {
            let label = SKLabelNode(fontNamed: buttonFontName)
            label.text = title
            label.fontSize = 36
            label.fontColor = .white
            label.name = nodeName.rawValue
            label.zPosition = 1
            label.horizontalAlignmentMode = .center
            buttonLabels[nodeName] = label
            addChild(label)
        }

        let difficultyLabel = SKLabelNode(fontNamed: buttonFontName)
        difficultyLabel.text = "Difficulty: \(selectedDifficulty.rawValue)"
        difficultyLabel.fontSize = 24
        difficultyLabel.fontColor = UIColor(white: 0.95, alpha: 0.9)
        difficultyLabel.horizontalAlignmentMode = .center
        difficultyLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        addChild(difficultyLabel)
        difficultySelectionLabel = difficultyLabel

        for difficulty in Difficulty.allCases {
            let optionLabel = SKLabelNode(fontNamed: buttonFontName)
            optionLabel.text = difficulty.rawValue
            optionLabel.fontSize = 24
            optionLabel.fontColor = UIColor(white: 0.9, alpha: 0.9)
            optionLabel.name = difficulty.nodeName.rawValue
            optionLabel.alpha = 0.0
            optionLabel.isHidden = true
            optionLabel.horizontalAlignmentMode = .center
            addChild(optionLabel)
            difficultyOptions[difficulty] = optionLabel
        }

        let feedback = SKLabelNode(fontNamed: buttonFontName)
        feedback.fontSize = 20
        feedback.fontColor = UIColor(white: 0.95, alpha: 0.85)
        feedback.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        feedback.alpha = 0.0
        feedback.horizontalAlignmentMode = .center
        addChild(feedback)
        feedbackLabel = feedback

        layoutMenuNodes()
        updateDifficultyHighlight()
    }

    private func layoutMenuNodes() {
        let buttonSpacing: CGFloat = 60
        let startY = size.height * 0.6
        let centerX = size.width / 2

        let order: [MenuNodeName] = [.newGame, .difficulty, .highScores, .quit]
        for (index, name) in order.enumerated() {
            guard let label = buttonLabels[name] else { continue }
            let positionY = startY - CGFloat(index) * buttonSpacing
            label.position = CGPoint(x: centerX, y: positionY)
        }

        var difficultyY = startY - buttonSpacing
        difficultyY -= 40
        for (offset, difficulty) in Difficulty.allCases.enumerated() {
            if let option = difficultyOptions[difficulty] {
                option.position = CGPoint(x: centerX, y: difficultyY - CGFloat(offset) * 36)
            }
        }

        difficultySelectionLabel?.position = CGPoint(x: centerX, y: difficultyY + 40)
        feedbackLabel?.position = CGPoint(x: centerX, y: size.height * 0.2)

        if let background = childNode(withName: "corgi_background") as? SKSpriteNode {
            background.position = CGPoint(x: size.width / 2, y: size.height / 2)
            background.size = size
            background.texture = gradientTexture(for: size)
        }

        if let overlay = childNode(withName: "corgi_background_overlay") as? SKSpriteNode {
            overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
            overlay.size = size
        }
    }

    private func updateDifficultyHighlight() {
        for (difficulty, label) in difficultyOptions {
            let isSelected = difficulty == selectedDifficulty
            label.fontColor = isSelected ? UIColor.systemYellow : UIColor(white: 0.9, alpha: 0.9)
        }
    }

    private func toggleDifficultyMenu() {
        difficultyMenuVisible.toggle()
        let targetAlpha: CGFloat = difficultyMenuVisible ? 1.0 : 0.0
        let nodes = difficultyOptions.values
        for node in nodes {
            node.isHidden = false
            node.run(SKAction.fadeAlpha(to: targetAlpha, duration: 0.2))
            if !difficultyMenuVisible {
                node.run(SKAction.sequence([SKAction.wait(forDuration: 0.21), SKAction.run { node.isHidden = true }]))
            }
        }
    }

    private func showFeedback(_ message: String) {
        feedbackLabel?.removeAllActions()
        feedbackLabel?.text = message
        feedbackLabel?.alpha = 1.0
        let sequence = SKAction.sequence([
            SKAction.wait(forDuration: 1.4),
            SKAction.fadeOut(withDuration: 0.3)
        ])
        feedbackLabel?.run(sequence)
    }

    private func presentGameBoard() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let boardScene = GameBoardScene(size: size)
        boardScene.scaleMode = .resizeFill
        view?.presentScene(boardScene, transition: transition)
    }

    private func startCorgiFloaters() {
        removeAction(forKey: "corgi_background_animation")

        let spawn = SKAction.run { [weak self] in
            guard let self = self else { return }

            let emojiChoices = ["🐶", "🐾", "🦴", "🐕"]
            let emoji = emojiChoices.randomElement() ?? "🐶"
            let node = SKLabelNode(fontNamed: self.buttonFontName)
            node.text = emoji
            node.fontSize = CGFloat.random(in: 32...52)
            node.alpha = 0.0
            node.zPosition = -0.5
            let minX = self.size.width * 0.2
            let maxX = self.size.width * 0.8
            node.position = CGPoint(x: CGFloat.random(in: minX...maxX), y: -self.size.height * 0.1)
            self.addChild(node)

            let moveDistance = self.size.height + 200
            let duration = TimeInterval.random(in: 10.0...16.0)
            let move = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: moveDistance, duration: duration)
            move.timingMode = .easeInEaseOut

            let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: duration * 0.25)
            fadeIn.timingMode = .easeIn
            let fadeOut = SKAction.fadeOut(withDuration: duration * 0.25)
            fadeOut.timingMode = .easeOut

            let rotateRange: CGFloat = .pi / 12
            let rotation = SKAction.rotate(byAngle: CGFloat.random(in: -rotateRange...rotateRange), duration: duration)
            rotation.timingMode = .easeInEaseOut

            let group = SKAction.group([move, SKAction.sequence([fadeIn, SKAction.wait(forDuration: duration * 0.5), fadeOut]), rotation])
            let sequence = SKAction.sequence([group, .removeFromParent()])
            node.run(sequence)
        }

        let wait = SKAction.wait(forDuration: 1.8, withRange: 1.2)
        let sequence = SKAction.sequence([spawn, wait])
        run(SKAction.repeatForever(sequence), withKey: "corgi_background_animation")
    }

    private func gradientTexture(for size: CGSize) -> SKTexture {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        let renderSize = CGSize(width: width, height: height)

        let topColor = UIColor(red: 253 / 255, green: 227 / 255, blue: 171 / 255, alpha: 1)
        let bottomColor = UIColor(red: 245 / 255, green: 190 / 255, blue: 129 / 255, alpha: 1)

        let renderer = UIGraphicsImageRenderer(size: renderSize)
        let image = renderer.image { context in
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [topColor.cgColor, bottomColor.cgColor] as CFArray, locations: [0, 1]) {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: renderSize.height),
                    end: CGPoint(x: 0, y: 0),
                    options: []
                )
            } else {
                context.cgContext.setFillColor(bottomColor.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: renderSize))
            }
        }

        return SKTexture(image: image)
    }

    private func handleMenuSelection(_ name: MenuNodeName) {
        switch name {
        case .newGame:
            showFeedback("Loading \(selectedDifficulty.rawValue) game...")
            presentGameBoard()
        case .difficulty:
            toggleDifficultyMenu()
        case .highScores:
            showFeedback("High Scores coming soon!")
        case .quit:
            showFeedback("Thanks for playing!")
        case .difficultyEasy:
            selectedDifficulty = .easy
            difficultyMenuVisible = true
            toggleDifficultyMenu()
        case .difficultyMedium:
            selectedDifficulty = .medium
            difficultyMenuVisible = true
            toggleDifficultyMenu()
        case .difficultyHard:
            selectedDifficulty = .hard
            difficultyMenuVisible = true
            toggleDifficultyMenu()
        }
    }

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
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            guard let nodeName = node.name, let menuName = MenuNodeName(rawValue: nodeName) else { continue }
            handleMenuSelection(menuName)
            break
        }
    }
}
