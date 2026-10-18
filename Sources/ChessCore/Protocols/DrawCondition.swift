/// A condition that automatically draws a game.
public protocol DrawCondition {
  /// Human-readable draw condition name used in status descriptions.
  static var name: String { get }
}
