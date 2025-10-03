//
//  ClueScene.swift
//  corgi jeopardy
//
//  Minimal placeholder scene that displays the selected clue.
//

import SpriteKit

final class ClueScene: SKScene {
    private let clue: Clue

    init(size: CGSize, clue: Clue) {
        self.clue = clue
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 20 / 255, green: 20 / 255, blue: 40 / 255, alpha: 1)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "$\(clue.value)"
        titleLabel.fontSize = 48
        titleLabel.fontColor = SKColor(red: 0.96, green: 0.78, blue: 0.22, alpha: 1)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)

        let questionLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        questionLabel.text = clue.question
        questionLabel.fontSize = 32
        questionLabel.fontColor = .white
        questionLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        questionLabel.horizontalAlignmentMode = .center
        questionLabel.verticalAlignmentMode = .center
        questionLabel.numberOfLines = 0
        questionLabel.preferredMaxLayoutWidth = size.width * 0.8
        addChild(questionLabel)

        let instructionLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        instructionLabel.text = "Tap to return"
        instructionLabel.fontSize = 20
        instructionLabel.fontColor = SKColor(white: 0.8, alpha: 1)
        instructionLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        addChild(instructionLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let boardScene = GameBoardScene(size: size)
        boardScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.3)
        view?.presentScene(boardScene, transition: transition)
    }
}
