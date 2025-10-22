import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        presentInitialScene()
    }

    private func presentInitialScene() {
        guard let skView = view as? SKView else { return }
        let menu = MainMenuScene(size: skView.bounds.size)
        menu.scaleMode = .aspectFill
        skView.presentScene(menu)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
