import SpriteKit

final class GameBoardScene: SKScene {
    private let gameState = GameState.shared
    private var tileNodes: [[SKLabelNode]] = []
    private var isPresentingTransition = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.11, green: 0.13, blue: 0.25, alpha: 1.0)
        removeAllChildren()
        layoutCategoryLabels()
        layoutClueTiles()
        addCorgiHost()
    }

    private func layoutCategoryLabels() {
        let topPadding: CGFloat = size.height * 0.15
        let spacing: CGFloat = size.width / CGFloat(max(gameState.board.count, 1))

        for (index, category) in gameState.board.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = category.title.uppercased()
            label.fontSize = 18
            label.fontColor = .white
            label.position = CGPoint(x: spacing * CGFloat(index) + spacing / 2 - size.width / 2,
                                     y: size.height / 2 - topPadding)
            label.numberOfLines = 0
            label.preferredMaxLayoutWidth = spacing - 16
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            addChild(label)
        }
    }

    private func layoutClueTiles() {
        tileNodes = []
        guard !gameState.board.isEmpty else { return }

        let columns = gameState.board.count
        let rows = gameState.board.first?.clues.count ?? 0

        let horizontalSpacing = size.width / CGFloat(columns)
        let verticalSpacing = size.height * 0.6 / CGFloat(max(rows, 1))
        let startingY = size.height / 2 - size.height * 0.25

        for column in 0..<columns {
            var columnNodes: [SKLabelNode] = []
            for row in 0..<rows {
                let clue = gameState.board[column].clues[row]
                let node = SKLabelNode(fontNamed: "AvenirNext-Bold")
                node.fontSize = 24
                node.fontColor = clue.isRevealed ? SKColor.gray : SKColor(red: 1.0, green: 0.8, blue: 0.1, alpha: 1.0)
                node.text = clue.isRevealed ? "" : "$\(clue.value)"
                node.name = "clue_\(column)_\(row)"
                node.position = CGPoint(x: horizontalSpacing * CGFloat(column) + horizontalSpacing / 2 - size.width / 2,
                                        y: startingY - verticalSpacing * CGFloat(row))
                node.verticalAlignmentMode = .center
                node.horizontalAlignmentMode = .center

                let backdrop = SKShapeNode(rectOf: CGSize(width: horizontalSpacing * 0.85, height: verticalSpacing * 0.75), cornerRadius: 12)
                backdrop.fillColor = SKColor(red: 0.05, green: 0.08, blue: 0.2, alpha: 1.0)
                backdrop.strokeColor = SKColor(red: 0.32, green: 0.46, blue: 0.86, alpha: 1.0)
                backdrop.position = node.position
                backdrop.name = node.name
                addChild(backdrop)

                addChild(node)
                columnNodes.append(node)
            }
            tileNodes.append(columnNodes)
        }
    }

    private func addCorgiHost() {
        let hostNode = SKSpriteNode(color: SKColor(red: 0.95, green: 0.64, blue: 0.2, alpha: 1.0), size: CGSize(width: 120, height: 120))
        hostNode.position = CGPoint(x: 0, y: -size.height / 2 + 120)
        hostNode.name = "corgiHost"
        addChild(hostNode)

        let wag = SKAction.sequence([
            SKAction.scaleX(to: 1.1, duration: 0.2),
            SKAction.scaleX(to: 0.9, duration: 0.2)
        ])
        hostNode.run(SKAction.repeatForever(wag))
    }

    private func presentTransitionScene() {
        guard !isPresentingTransition else { return }
        isPresentingTransition = true

        let transitionScene = TransitionScene(size: size)
        transitionScene.scaleMode = scaleMode
        let reveal = SKTransition.crossFade(withDuration: 1.0)
        view?.presentScene(transitionScene, transition: reveal)
    }

    private func handleClueSelection(categoryIndex: Int, clueIndex: Int) {
        guard gameState.board.indices.contains(categoryIndex) else { return }
        guard gameState.board[categoryIndex].clues.indices.contains(clueIndex) else { return }
        guard !gameState.board[categoryIndex].clues[clueIndex].isRevealed else { return }

        gameState.markClueRevealed(categoryIndex: categoryIndex, clueIndex: clueIndex)
        let node = tileNodes[categoryIndex][clueIndex]
        node.text = ""
        node.fontColor = .gray

        if gameState.allCluesRevealed {
            presentTransitionScene()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            guard let name = node.name, name.hasPrefix("clue_") else { continue }
            let components = name.split(separator: "_")
            guard components.count == 3,
                  let column = Int(components[1]),
                  let row = Int(components[2]) else { continue }
            handleClueSelection(categoryIndex: column, clueIndex: row)
            break
        }
    }
}
