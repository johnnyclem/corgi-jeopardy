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

        guard let view = self.view as? SKView else { return }

        let scene = MainMenuScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        view.presentScene(scene)

        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        
        guard let skView = view as? SKView else { return }

        let boardScene = GameBoardScene(size: skView.bounds.size)
        boardScene.scaleMode = .resizeFill
        skView.presentScene(boardScene)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        let menuScene = MainMenuScene(size: skView.bounds.size)
        menuScene.scaleMode = .resizeFill

        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.presentScene(menuScene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
