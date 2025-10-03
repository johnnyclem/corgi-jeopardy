import SpriteKit

/// Represents a reusable corgi companion sprite that can perform themed
/// animations (idle, celebration, sad, and wager) and trigger matching sound
/// effects. The character expects texture atlases named "CorgiIdle",
/// "CorgiCelebrate", "CorgiSad", and "CorgiWager" to exist in the asset
/// catalogue. When textures are missing the class gracefully falls back to
/// color-based sprites so that development builds continue running.
final class CorgiCharacter {
    enum AnimationType {
        case idle
        case celebrate
        case sad
        case wager

        var actionKey: String {
            switch self {
            case .idle:
                return "corgi-idle"
            case .celebrate:
                return "corgi-celebrate"
            case .sad:
                return "corgi-sad"
            case .wager:
                return "corgi-wager"
            }
        }
    }

    private(set) lazy var node: SKSpriteNode = {
        let sprite = SKSpriteNode(texture: idleTextures.first)
        if idleTextures.isEmpty {
            sprite.color = SKColor(red: 0.95, green: 0.73, blue: 0.44, alpha: 1.0)
            sprite.size = CGSize(width: 180, height: 180)
        }
        sprite.zPosition = 5
        return sprite
    }()

    private let idleTextures: [SKTexture]
    private let celebrateTextures: [SKTexture]
    private let sadTextures: [SKTexture]
    private let wagerTextures: [SKTexture]

    private var currentActionKey: String?

    init(texturePrefix: String = "Corgi") {
        idleTextures = CorgiCharacter.loadTextures(atlasNamed: "\(texturePrefix)Idle")
        celebrateTextures = CorgiCharacter.loadTextures(atlasNamed: "\(texturePrefix)Celebrate")
        sadTextures = CorgiCharacter.loadTextures(atlasNamed: "\(texturePrefix)Sad")
        wagerTextures = CorgiCharacter.loadTextures(atlasNamed: "\(texturePrefix)Wager")
    }

    func addToScene(_ scene: SKScene, position: CGPoint) {
        node.removeFromParent()
        node.position = position
        scene.addChild(node)
        play(animation: .idle, loop: true)
    }

    func play(animation: AnimationType, loop: Bool = false) {
        let textures: [SKTexture]
        let sound: CorgiSoundPlayer.SoundEffect?
        switch animation {
        case .idle:
            textures = idleTextures
            sound = nil
        case .celebrate:
            textures = celebrateTextures
            sound = .bark
        case .sad:
            textures = sadTextures
            sound = .whimper
        case .wager:
            textures = wagerTextures
            sound = nil
        }

        if let sound = sound {
            CorgiSoundPlayer.shared.play(sound)
        }

        guard !textures.isEmpty else { return }

        let animationAction = SKAction.animate(with: textures, timePerFrame: 0.1, resize: false, restore: loop)
        let key = animation.actionKey
        currentActionKey = key

        node.removeAction(forKey: key)

        if loop {
            node.run(SKAction.repeatForever(animationAction), withKey: key)
        } else {
            let completion = SKAction.run { [weak self] in
                guard let self = self else { return }
                self.currentActionKey = nil
                self.play(animation: .idle, loop: true)
            }
            node.run(SKAction.sequence([animationAction, completion]), withKey: key)
        }
    }

    func reactToCorrectAnswer() {
        play(animation: .celebrate)
    }

    func reactToIncorrectAnswer() {
        play(animation: .sad)
    }

    func playWagerAnimation() {
        play(animation: .wager)
    }

    private static func loadTextures(atlasNamed name: String) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: name)
        let sortedNames = atlas.textureNames.sorted()
        guard !sortedNames.isEmpty else { return [] }
        return sortedNames.map { atlas.textureNamed($0) }
    }
}
