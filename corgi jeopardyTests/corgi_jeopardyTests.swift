// SpriteKit debugging tips:
// - Use the `showsPhysics` and `showsFields` properties on `SKView` to visualize nodes during touch handling.
// - Enable `showsFPS` and `showsNodeCount` to verify that scene transitions finish and resources are deallocated.
// - Log `touchesBegan`, `touchesMoved`, and `touchesEnded` with node names to confirm gesture routing when debugging custom buttons.
// - During transitions, confirm `presentScene(_:transition:)` is called on the main thread and set `view?.ignoresSiblingOrder = false` when
//   testing zPosition ordering issues.
// - Pause the scene (`isPaused = true`) while stepping through touch responders in Xcode to avoid missing events.
// - When touches seem unresponsive, ensure `isUserInteractionEnabled` is true on the relevant nodes and that gesture recognizers are not
//   intercepting touches before SpriteKit.
