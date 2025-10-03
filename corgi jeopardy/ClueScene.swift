import SpriteKit

/// Scene responsible for presenting a clue and resolving wager outcomes.
final class ClueScene: SKScene {
    private let clueValue: Int
    private let resultLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    init(size: CGSize, clueValue: Int) {
        self.clueValue = clueValue
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.11, blue: 0.2, alpha: 1.0)
        configureResultLabel()

        // For demo purposes automatically resolve wager as correct after delay.
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in self?.resolveWager(isCorrect: true) }
        ]))
    }

    private func configureResultLabel() {
        resultLabel.fontSize = 32
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        resultLabel.horizontalAlignmentMode = .center
        resultLabel.verticalAlignmentMode = .center
        addChild(resultLabel)
    }

    func resolveWager(isCorrect: Bool) {
        guard let resolution = GameState.shared.resolveActiveWager(isCorrect: isCorrect) else {
            resultLabel.text = isCorrect ? "Correct! +$\(clueValue)" : "Incorrect! -$\(clueValue)"
            return
        }

        switch resolution.type {
        case .dailyDouble:
            let prefix = isCorrect ? "Correct!" : "Incorrect!"
            let sign = resolution.delta >= 0 ? "+" : ""
            resultLabel.text = "\(prefix) $\(sign)\(resolution.delta)"
        case .dailyDooDoo:
            handleDailyDooDooAnimation(towards: resolution.affectedPlayer, isCorrect: isCorrect, amount: abs(resolution.delta))
        }
    }

    private func handleDailyDooDooAnimation(towards opponent: GameState.Player, isCorrect: Bool, amount: Int) {
        let sign = isCorrect ? "-" : "+"
        resultLabel.text = "Daily Doo-Doo! Opponent \(sign)$\(amount)"

        let pooTexture = SKTexture(imageNamed: "poo")
        let poo = SKSpriteNode(texture: pooTexture)
        poo.size = CGSize(width: 80, height: 80)
        let startX = isCorrect ? size.width * 0.3 : size.width * 0.8
        let targetX = isCorrect ? size.width * 0.8 : size.width * 0.3
        poo.position = CGPoint(x: startX, y: size.height * 0.5)
        poo.alpha = 0.0
        addChild(poo)

        let arcUp = SKAction.move(to: CGPoint(x: (startX + targetX) / 2, y: size.height * 0.75), duration: 0.4)
        arcUp.timingMode = .easeOut
        let arcDown = SKAction.move(to: CGPoint(x: targetX, y: size.height * 0.4), duration: 0.4)
        arcDown.timingMode = .easeIn

        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.8)
        let splat = SKAction.group([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.2)
        ])

        let soundName = isCorrect ? "dooDoo_splat.mp3" : "dooDoo_cheer.mp3"
        let playSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: false)

        let sequence = SKAction.sequence([
            fadeIn,
            SKAction.group([arcUp, rotate]),
            SKAction.group([arcDown, rotate]),
            playSound,
            splat,
            SKAction.removeFromParent()
        ])

        poo.run(sequence)
    }
}
