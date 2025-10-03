//
//  GameViewController.swift
//  corgi jeopardy
//
//  Created by John Clem on 10/2/25.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let skView = view as? SKView else { return }

        let players = [
            FinalJeopardyScene.PlayerState(id: "You", score: 3200, isHuman: true),
            FinalJeopardyScene.PlayerState(id: "Sir Barksalot", score: 2800, isHuman: false),
            FinalJeopardyScene.PlayerState(id: "Lady Wigglebottom", score: 2600, isHuman: false)
        ]

        let scene = FinalJeopardyScene(
            size: skView.bounds.size,
            category: "Legendary Corgis",
            clue: "This corgi accompanied explorers on the first tail-wagging expedition to the North Bark.",
            correctResponse: "What is Sir Barksalot?",
            players: players
        )

        scene.scaleMode = .aspectFill

        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
