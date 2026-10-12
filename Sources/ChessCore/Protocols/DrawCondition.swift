/// A condition that automatically draws a game.
public protocol DrawCondition {
  /// Human-readable draw condition name used in status descriptions.
  static var name: String { get }
}

protocol GameDrawCondition: DrawCondition {
  /// Whether the game is drawn by this condition.
  static func isDraw(board: Board, turns: [Turn]) -> Bool
}
