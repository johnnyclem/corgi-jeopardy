import Foundation
import AVFoundation

/// A lightweight audio helper responsible for playing short corgi themed
/// sound effects throughout the game. The class preloads the bark and
/// whimper audio clips (expected to live in the main bundle) and provides
/// a simple `play(_:)` API so that individual scenes do not need to manage
/// their own instances of `AVAudioPlayer`.
final class CorgiSoundPlayer {
    static let shared = CorgiSoundPlayer()

    enum SoundEffect: CaseIterable {
        case bark
        case whimper

        var resourceName: String {
            switch self {
            case .bark:
                return "bark"
            case .whimper:
                return "whimper"
            }
        }

        var fileExtension: String { "mp3" }
    }

    private var players: [SoundEffect: AVAudioPlayer] = [:]

    private init() {
        preloadPlayers()
    }

    private func preloadPlayers() {
        for effect in SoundEffect.allCases {
            guard let url = Bundle.main.url(forResource: effect.resourceName, withExtension: effect.fileExtension) else {
                #if DEBUG
                print("[Audio] Missing resource for \(effect.resourceName).\(effect.fileExtension)")
                #endif
                continue
            }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[effect] = player
            } catch {
                #if DEBUG
                print("[Audio] Failed to load sound \(effect.resourceName):", error)
                #endif
            }
        }
    }

    func play(_ effect: SoundEffect) {
        guard let player = players[effect] else { return }
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
        player.play()
    }
}
