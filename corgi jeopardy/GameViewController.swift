//
//  GameViewController.swift
//  corgi jeopardy
//
//  Created by John Clem on 10/2/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = view as? SKView else { return }

        let boardScene = GameBoardScene(size: skView.bounds.size)
        boardScene.scaleMode = .resizeFill
        skView.presentScene(boardScene)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
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
