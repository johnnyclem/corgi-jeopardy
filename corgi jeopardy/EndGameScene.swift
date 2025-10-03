import SpriteKit
#if canImport(UIKit)
import UIKit
#endif

/// Displays final scores, highlights the winner, and offers options to replay or return to the menu.
final class EndGameScene: SKScene {
    private enum NodeName {
        static let playAgain = "playAgainButton"
        static let menu = "menuButton"
    }

    private let gameState = GameState.shared
    private var didUpdateHighScore = false

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = SKColor(red: 14.0 / 255.0, green: 10.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
        removeAllChildren()

        didUpdateHighScore = gameState.updateHighScoreIfNeededForHumanWin()

        layoutTitle()
        layoutWinner()
        layoutScores()
        layoutButtons()
        layoutCorgis()
        if didUpdateHighScore {
            layoutHighScoreBanner()
        }
    }

    private func layoutTitle() {
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Final Tally"
        titleLabel.fontSize = 44
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        addChild(titleLabel)
    }

    private func layoutWinner() {
        guard let winner = gameState.winningPlayer else { return }
        let winnerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        winnerLabel.text = "Winner: \(winner.displayName)!"
        winnerLabel.fontSize = 36
        winnerLabel.fontColor = SKColor(red: 255.0 / 255.0, green: 204.0 / 255.0, blue: 0, alpha: 1)
        winnerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 200)
        addChild(winnerLabel)
    }

    private func layoutScores() {
        let players = gameState.orderedPlayersByScore
        guard !players.isEmpty else { return }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let startY = frame.midY + CGFloat(players.count - 1) * 30
        for (index, player) in players.enumerated() {
            let score = gameState.score(for: player)
            let formattedScore = formatter.string(from: NSNumber(value: score)) ?? "\(score)"

            let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            label.text = "\(player.displayName): $\(formattedScore)"
            label.fontSize = 28
            label.fontColor = player.isHuman ? SKColor(red: 0.8, green: 0.95, blue: 1, alpha: 1) : .white
            label.position = CGPoint(x: frame.midX, y: startY - CGFloat(index) * 60)
            addChild(label)
        }
    }

    private func layoutButtons() {
        let playAgain = makeButton(title: "Play Again", name: NodeName.playAgain)
        playAgain.position = CGPoint(x: frame.midX, y: frame.minY + 180)
        addChild(playAgain)

        let menu = makeButton(title: "Main Menu", name: NodeName.menu)
        menu.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        addChild(menu)
    }

    private func layoutCorgis() {
        let left = makeCorgiSprite()
        left.position = CGPoint(x: frame.minX + 120, y: frame.minY + 200)
        addChild(left)

        let right = makeCorgiSprite(flipHorizontally: true)
        right.position = CGPoint(x: frame.maxX - 120, y: frame.minY + 200)
        addChild(right)
    }

    private func layoutHighScoreBanner() {
        let banner = SKShapeNode(rectOf: CGSize(width: size.width * 0.7, height: 70), cornerRadius: 20)
        banner.fillColor = SKColor(red: 255.0 / 255.0, green: 87.0 / 255.0, blue: 0, alpha: 0.85)
        banner.strokeColor = .white
        banner.lineWidth = 3
        banner.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        addChild(banner)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "New High Score!"
        label.fontSize = 28
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = .zero
        label.zPosition = 1
        label.name = "highScoreLabel"
        banner.addChild(label)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.4),
            SKAction.scale(to: 1.0, duration: 0.4)
        ])
        banner.run(SKAction.repeatForever(pulse))
    }

    private func makeButton(title: String, name: String) -> SKNode {
        let container = SKShapeNode(rectOf: CGSize(width: 240, height: 64), cornerRadius: 18)
        container.fillColor = SKColor(red: 54.0 / 255.0, green: 132.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.9)
        container.strokeColor = .white
        container.lineWidth = 3
        container.name = name

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = title
        label.fontSize = 26
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        label.name = name
        container.addChild(label)

        let shine = SKShapeNode(rectOf: CGSize(width: 200, height: 10), cornerRadius: 5)
        shine.fillColor = SKColor.white.withAlphaComponent(0.35)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: 0, y: 18)
        shine.zRotation = .pi / 12
        shine.name = name
        container.addChild(shine)

        let wiggle = SKAction.sequence([
            SKAction.scale(to: 1.03, duration: 0.6),
            SKAction.scale(to: 1.0, duration: 0.6)
        ])
        container.run(SKAction.repeatForever(wiggle))
        return container
    }

    private func makeCorgiSprite(flipHorizontally: Bool = false) -> SKNode {
        #if canImport(UIKit)
        if UIImage(named: "victory_corgi") != nil {
            let sprite = SKSpriteNode(imageNamed: "victory_corgi")
            sprite.xScale = flipHorizontally ? -1 : 1
            sprite.setScale(0.6)
            let bounce = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 20, duration: 0.6),
                SKAction.moveBy(x: 0, y: -20, duration: 0.6)
            ])
            sprite.run(SKAction.repeatForever(bounce))
            return sprite
        }
        #endif

        let placeholder = SKShapeNode(rectOf: CGSize(width: 110, height: 90), cornerRadius: 20)
        placeholder.fillColor = SKColor(red: 249.0 / 255.0, green: 177.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)
        placeholder.strokeColor = .white
        placeholder.lineWidth = 3

        let face = SKShapeNode(circleOfRadius: 18)
        face.fillColor = .white
        face.strokeColor = .brown
        face.position = CGPoint(x: flipHorizontally ? -15 : 15, y: 10)
        placeholder.addChild(face)

        let tail = SKShapeNode(rectOf: CGSize(width: 30, height: 12), cornerRadius: 6)
        tail.fillColor = SKColor(red: 209.0 / 255.0, green: 132.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
        tail.strokeColor = .clear
        tail.position = CGPoint(x: flipHorizontally ? -45 : 45, y: -10)
        placeholder.addChild(tail)

        let wag = SKAction.sequence([
            SKAction.rotate(byAngle: flipHorizontally ? -0.3 : 0.3, duration: 0.3),
            SKAction.rotate(byAngle: flipHorizontally ? 0.3 : -0.3, duration: 0.3)
        ])
        tail.run(SKAction.repeatForever(wag))

        return placeholder
    }

    private func presentScene(named className: String) {
        guard let view = self.view else { return }
        let transition = SKTransition.crossFade(withDuration: 0.6)
        let nextScene = instantiateScene(className: className) ?? SKScene(size: size)
        nextScene.scaleMode = scaleMode
        view.presentScene(nextScene, transition: transition)
    }

    private func instantiateScene(className: String) -> SKScene? {
        guard let bundleName = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else {
            return nil
        }
        let qualifiedName = "\(bundleName).\(className)"
        if let sceneClass = NSClassFromString(qualifiedName) as? SKScene.Type {
            return sceneClass.init(size: size)
        }
        return nil
    }

    private func handlePlayAgainSelection() {
        gameState.resetForNewGame()
        presentScene(named: "GameBoardScene")
    }

    private func handleMenuSelection() {
        gameState.resetForNewGame()
        presentScene(named: "MainMenuScene")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        if tappedNodes.contains(where: { $0.name == NodeName.playAgain }) {
            handlePlayAgainSelection()
        } else if tappedNodes.contains(where: { $0.name == NodeName.menu }) {
            handleMenuSelection()
        }
    }
}
