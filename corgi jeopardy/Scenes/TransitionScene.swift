import SpriteKit

final class TransitionScene: SKScene {
    private let gameState = GameState.shared
    private let displayDuration: TimeInterval = 3.0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.09, blue: 0.18, alpha: 1.0)
        addTitleLabel()
        addScoreboard()
        addCelebrationCorgi()
        scheduleAdvance()
    }

    private func addTitleLabel() {
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Next up: \(gameState.currentRound.displayName)"
        title.fontSize = 32
        title.fontColor = SKColor(red: 1.0, green: 0.89, blue: 0.4, alpha: 1.0)
        title.position = CGPoint(x: 0, y: size.height / 2 - 120)
        addChild(title)
    }

    private func addScoreboard() {
        let sortedScores = gameState.playerScores.sorted { $0.value > $1.value }
        for (index, entry) in sortedScores.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = "\(entry.key): $\(entry.value)"
            label.fontSize = 24
            label.fontColor = .white
            label.position = CGPoint(x: 0, y: size.height / 2 - 200 - CGFloat(index) * 40)
            addChild(label)
        }
    }

    private func addCelebrationCorgi() {
        let corgi = SKSpriteNode(color: SKColor(red: 0.95, green: 0.74, blue: 0.33, alpha: 1.0), size: CGSize(width: 150, height: 150))
        corgi.position = CGPoint(x: 0, y: -40)
        addChild(corgi)

        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: .pi / 16, duration: 0.2),
            SKAction.rotate(byAngle: -.pi / 8, duration: 0.2),
            SKAction.rotate(byAngle: .pi / 16, duration: 0.2)
        ])
        let hop = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.2),
            SKAction.moveBy(x: 0, y: -20, duration: 0.2)
        ])
        let dance = SKAction.group([SKAction.repeatForever(wiggle), SKAction.repeatForever(hop)])
        corgi.run(dance)
    }

    private func scheduleAdvance() {
        run(SKAction.sequence([
            SKAction.wait(forDuration: displayDuration),
            SKAction.run { [weak self] in
                self?.advanceToNextRound()
            }
        ]))
    }

    private func advanceToNextRound() {
        let next = gameState.nextRound()

        switch next {
        case .jeopardy, .doubleJeopardy:
            let nextBoard = GameBoardScene(size: size)
            nextBoard.scaleMode = scaleMode
            let transition = SKTransition.flipHorizontal(withDuration: 1.0)
            view?.presentScene(nextBoard, transition: transition)
        case .finalJeopardy:
            let finalScene = FinalJeopardyScene(size: size)
            finalScene.scaleMode = scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            view?.presentScene(finalScene, transition: transition)
        }
    }
}
