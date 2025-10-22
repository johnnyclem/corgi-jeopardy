import SpriteKit

final class GameBoardScene: SKScene {
    private let gameState = GameState.shared
    private var tileNodes: [String: SKSpriteNode] = [:]

    private let columns = 6
    private let rows = 5

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = SKColor(red: 9/255, green: 26/255, blue: 64/255, alpha: 1)
        removeAllChildren()
        tileNodes.removeAll()

        addHost()
        layoutCategories()
        layoutClues()
    }

    private func addHost() {
        let hostTexture = SKTexture(imageNamed: "corgiHost")
        let hostNode: SKSpriteNode
        if hostTexture.size() == .zero {
            hostNode = SKSpriteNode(color: SKColor(red: 0.95, green: 0.74, blue: 0.33, alpha: 1), size: CGSize(width: 160, height: 160))
        } else {
            hostNode = SKSpriteNode(texture: hostTexture)
            hostNode.size = CGSize(width: 160, height: 160)
        }
        hostNode.position = CGPoint(x: -size.width / 2 + 120, y: -size.height / 2 + 160)
        addChild(hostNode)

        let wag = SKAction.sequence([
            SKAction.scaleX(to: 1.05, duration: 0.25),
            SKAction.scaleX(to: 0.95, duration: 0.25)
        ])
        hostNode.run(SKAction.repeatForever(wag))
    }

    private func layoutCategories() {
        let availableWidth = size.width * 0.9
        let columnWidth = availableWidth / CGFloat(columns)
        let topMargin = size.height * 0.1
        let labelHeight = size.height * 0.08
        let startX = -availableWidth / 2

        for (index, category) in gameState.board.enumerated() {
            let background = SKShapeNode(rectOf: CGSize(width: columnWidth - 6, height: labelHeight), cornerRadius: 12)
            background.fillColor = SKColor(red: 0.0, green: 0.2, blue: 0.7, alpha: 1)
            background.strokeColor = .white
            background.lineWidth = 2
            background.position = CGPoint(x: startX + CGFloat(index) * columnWidth + columnWidth / 2,
                                           y: size.height / 2 - topMargin)
            addChild(background)

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = category.title.uppercased()
            label.fontSize = min(22, columnWidth * 0.22)
            label.fontColor = .white
            label.numberOfLines = 2
            label.preferredMaxLayoutWidth = columnWidth - 16
            label.verticalAlignmentMode = .center
            label.position = background.position
            addChild(label)
        }
    }

    private func layoutClues() {
        let availableWidth = size.width * 0.9
        let availableHeight = size.height * 0.55
        let columnWidth = availableWidth / CGFloat(columns)
        let rowHeight = availableHeight / CGFloat(rows)
        let startX = -availableWidth / 2
        let startY = size.height / 2 - size.height * 0.25

        for column in 0..<columns {
            for row in 0..<rows {
                guard let clue = gameState.clue(atColumn: column, row: row) else { continue }
                let nodeName = tileName(column: column, row: row)
                let tileSize = CGSize(width: columnWidth - 8, height: rowHeight - 8)
                let tile = SKSpriteNode(color: SKColor(red: 0.0, green: 0.1, blue: 0.45, alpha: 1), size: tileSize)
                tile.position = CGPoint(x: startX + CGFloat(column) * columnWidth + columnWidth / 2,
                                        y: startY - CGFloat(row) * rowHeight)
                tile.name = nodeName
                tile.zPosition = 1

                let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
                label.fontSize = min(32, rowHeight * 0.45)
                label.text = "$\(clue.value)"
                label.name = "label-\(nodeName)"
                label.verticalAlignmentMode = .center
                label.horizontalAlignmentMode = .center
                label.zPosition = 2
                tile.addChild(label)

                applyAppearance(for: clue, tile: tile, label: label)

                addChild(tile)
                tileNodes[nodeName] = tile
            }
        }
    }

    private func applyAppearance(for clue: GameState.Clue, tile: SKSpriteNode, label: SKLabelNode) {
        if clue.isRevealed {
            tile.color = SKColor(white: 0.35, alpha: 1)
            label.fontColor = SKColor(white: 0.8, alpha: 1)
            label.text = ""
        } else {
            tile.color = SKColor(red: 0.0, green: 0.1, blue: 0.45, alpha: 1)
            label.fontColor = SKColor(red: 0.96, green: 0.78, blue: 0.22, alpha: 1)
            label.text = "$\(clue.value)"
        }
    }

    private func tileName(column: Int, row: Int) -> String {
        "tile-\(column)-\(row)"
    }

    // MARK: - Touch Handling

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        guard let tile = tappedNodes.first(where: { node in
            if let sprite = node as? SKSpriteNode, sprite.name?.hasPrefix("tile-") == true { return true }
            if let label = node as? SKLabelNode, let parent = label.parent as? SKSpriteNode, parent.name?.hasPrefix("tile-") == true { return true }
            return false
        }) else { return }

        let targetTile: SKSpriteNode
        if let sprite = tile as? SKSpriteNode {
            targetTile = sprite
        } else if let label = tile as? SKLabelNode, let parent = label.parent as? SKSpriteNode {
            targetTile = parent
        } else {
            return
        }

        handleSelection(for: targetTile)
    }

    private func handleSelection(for tile: SKSpriteNode) {
        guard let name = tile.name else { return }
        let components = name.split(separator: "-")
        guard components.count == 3,
              let column = Int(components[1]),
              let row = Int(components[2]),
              var clue = gameState.clue(atColumn: column, row: row),
              !clue.isRevealed else { return }

        gameState.markClueRevealed(atColumn: column, row: row)
        if let label = tile.childNode(withName: "label-\(name)") as? SKLabelNode,
           let updatedClue = gameState.clue(atColumn: column, row: row) {
            applyAppearance(for: updatedClue, tile: tile, label: label)
        }

        gameState.lastSelectedClue = clue

        if let context = gameState.wagerContext(for: clue) {
            presentWagerScene(with: context)
        } else {
            presentClueScene(for: clue)
        }
    }

    private func presentClueScene(for clue: GameState.Clue) {
        let nextScene = ClueScene(size: size, clue: clue)
        nextScene.scaleMode = scaleMode
        view?.presentScene(nextScene, transition: SKTransition.fade(withDuration: 0.4))
    }

    private func presentWagerScene(with context: GameState.WagerContext) {
        let nextScene = WagerScene(size: size, context: context)
        nextScene.scaleMode = scaleMode
        view?.presentScene(nextScene, transition: SKTransition.crossFade(withDuration: 0.4))
    }

    func returnFromClue() {
        if gameState.allCluesRevealed {
            handleRoundCompletion()
        }
    }

    private func handleRoundCompletion() {
        let nextRound = gameState.advanceToNextRound()
        switch nextRound {
        case .jeopardy, .doubleJeopardy:
            let board = GameBoardScene(size: size)
            board.scaleMode = scaleMode
            view?.presentScene(board, transition: SKTransition.flipHorizontal(withDuration: 0.6))
        case .finalJeopardy:
            let end = EndGameScene(size: size)
            end.scaleMode = scaleMode
            view?.presentScene(end, transition: SKTransition.fade(withDuration: 0.6))
        }
    }
}
