import SpriteKit

final class GameBoardScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(named: "BoardBackground") ?? .systemBlue
        if childNode(withName: "placeholder") == nil {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "Game Board Placeholder"
            label.fontSize = min(32, size.width * 0.06)
            label.position = CGPoint(x: frame.midX, y: frame.midY)
            label.name = "placeholder"
            addChild(label)
        }
    }
//
//  GameBoardScene.swift
//  corgi jeopardy
//
//  Displays the Jeopardy style board with categories, clues and a corgi host.
//

import SpriteKit

final class GameBoardScene: SKScene {
    private let gameState = GameState.shared
    private var tileNodes: [[SKSpriteNode]] = []
    private var hostNode: SKSpriteNode?

    private let numberOfColumns = 6
    private let numberOfRows = 5

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 9 / 255, green: 26 / 255, blue: 64 / 255, alpha: 1)
        hostNode = nil
        removeAllChildren()
        layoutCategories()
        layoutClueTiles()
        addHostIfNeeded()
    }

    private func layoutCategories() {
        let topMargin: CGFloat = size.height * 0.1
        let sideMargin: CGFloat = size.width * 0.05
        let availableWidth = size.width - (sideMargin * 2)
        let columnWidth = availableWidth / CGFloat(numberOfColumns)
        let labelHeight = size.height * 0.1
        let baseY = size.height - topMargin - (labelHeight / 2)

        for (column, category) in gameState.board.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = category.title.uppercased()
            label.fontColor = .white
            label.fontSize = min(22, columnWidth * 0.25)
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.numberOfLines = 2
            label.preferredMaxLayoutWidth = columnWidth - 8

            let positionX = sideMargin + (columnWidth * (CGFloat(column) + 0.5))
            label.position = CGPoint(x: positionX, y: baseY)

            let background = SKSpriteNode(color: SKColor(red: 0.0, green: 0.2, blue: 0.7, alpha: 1), size: CGSize(width: columnWidth - 6, height: labelHeight))
            background.position = label.position
            background.zPosition = 0
            addChild(background)

            label.zPosition = 1
            addChild(label)
        }
    }

    private func layoutClueTiles() {
        tileNodes = Array(repeating: [], count: numberOfColumns)

        let sideMargin: CGFloat = size.width * 0.05
        let topOffset: CGFloat = size.height * 0.3
        let bottomMargin: CGFloat = size.height * 0.1
        let availableHeight = size.height - topOffset - bottomMargin
        let availableWidth = size.width - (sideMargin * 2)
        let columnWidth = availableWidth / CGFloat(numberOfColumns)
        let rowHeight = availableHeight / CGFloat(numberOfRows)

        for column in 0..<numberOfColumns {
            var columnTiles: [SKSpriteNode] = []
            for row in 0..<numberOfRows {
                let tileSize = CGSize(width: columnWidth - 8, height: rowHeight - 8)
                let tile = SKSpriteNode(color: SKColor(red: 0.0, green: 0.1, blue: 0.45, alpha: 1), size: tileSize)
                tile.name = nodeNameForTile(column: column, row: row)
                tile.zPosition = 0

                let positionX = sideMargin + (columnWidth * (CGFloat(column) + 0.5))
                let positionY = size.height - topOffset - (rowHeight * (CGFloat(row) + 0.5))
                tile.position = CGPoint(x: positionX, y: positionY)

                let valueLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
                valueLabel.fontSize = min(32, rowHeight * 0.4)
                valueLabel.fontColor = SKColor(red: 0.96, green: 0.78, blue: 0.22, alpha: 1)
                valueLabel.verticalAlignmentMode = .center
                valueLabel.horizontalAlignmentMode = .center
                valueLabel.zPosition = 1
                valueLabel.name = "label-\(tile.name ?? "")"

                if let clue = gameState.clue(atColumn: column, row: row) {
                    valueLabel.text = "$\(clue.value)"
                    applyAppearance(for: clue, tile: tile, label: valueLabel)
                } else {
                    valueLabel.text = "--"
                }

                tile.addChild(valueLabel)
                addChild(tile)

                columnTiles.append(tile)
            }
            tileNodes[column] = columnTiles
        }
    }

    private func applyAppearance(for clue: Clue, tile: SKSpriteNode, label: SKLabelNode) {
        if clue.isRevealed {
            tile.color = SKColor(white: 0.35, alpha: 1)
            label.fontColor = SKColor(white: 0.8, alpha: 1)
        } else {
            tile.color = SKColor(red: 0.0, green: 0.1, blue: 0.45, alpha: 1)
            label.fontColor = SKColor(red: 0.96, green: 0.78, blue: 0.22, alpha: 1)
        }
    }

    private func addHostIfNeeded() {
        guard hostNode == nil else { return }

        let texture = SKTexture(imageNamed: "corgiHost")
        let host = SKSpriteNode(texture: texture)
        host.size = CGSize(width: size.width * 0.2, height: size.width * 0.2)
        host.anchorPoint = CGPoint(x: 0.5, y: 0)
        host.position = CGPoint(x: -host.size.width, y: size.height * 0.05)
        host.zPosition = 5
        addChild(host)
        hostNode = host

        let enter = SKAction.moveTo(x: size.width * 0.15, duration: 0.6)
        enter.timingMode = .easeOut
        let wag = SKAction.sequence([
            SKAction.scaleX(to: 1.05, duration: 0.2),
            SKAction.scaleX(to: 0.95, duration: 0.2)
        ])
        let wagRepeat = SKAction.repeat(wag, count: 3)
        host.run(SKAction.sequence([enter, wagRepeat]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        guard let tileNode = nodes.compactMap({ node -> SKSpriteNode? in
            if let sprite = node as? SKSpriteNode, sprite.name?.hasPrefix("tile-") == true {
                return sprite
            }
            if let label = node as? SKLabelNode, let parent = label.parent as? SKSpriteNode, parent.name?.hasPrefix("tile-") == true {
                return parent
            }
            return nil
        }).first else { return }

        handleSelection(for: tileNode)
    }

    private func handleSelection(for tileNode: SKSpriteNode) {
        guard let name = tileNode.name else { return }
        let components = name.split(separator: "-")
        guard components.count == 3,
              let column = Int(components[1]),
              let row = Int(components[2]),
              let clue = gameState.clue(atColumn: column, row: row),
              !clue.isRevealed else { return }

        gameState.markClueRevealed(atColumn: column, row: row)
        if let label = tileNode.children.compactMap({ $0 as? SKLabelNode }).first,
           let updatedClue = gameState.clue(atColumn: column, row: row) {
            applyAppearance(for: updatedClue, tile: tileNode, label: label)
        }

        transitionToClueScene(with: clue)
    }

    private func transitionToClueScene(with clue: Clue) {
        let nextScene = ClueScene(size: size, clue: clue)
        nextScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(nextScene, transition: transition)
    }

    private func nodeNameForTile(column: Int, row: Int) -> String {
        return "tile-\(column)-\(row)"
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
