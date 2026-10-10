/// A condition that causes a game to be drawn.
public protocol DrawCondition {
  /// Display name for the draw condition.
  static var name: String { get }

  /// Returns whether the condition draws the game in the given context.
  static func isDraw(in context: DrawContext) -> Bool
}
