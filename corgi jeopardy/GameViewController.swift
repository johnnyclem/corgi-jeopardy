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
        presentInitialScene()
    }

    private func presentInitialScene() {
        guard let view = self.view as? SKView else { return }
        let scene = GameBoardScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
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
