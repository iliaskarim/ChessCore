/// A condition that causes a player to win a game.
public protocol WinCondition {
  /// Display name for the win condition.
  static var name: String { get }

  /// Returns the winning color in the given context, if any.
  static func winner(in context: WinContext) -> Piece.Color?
}
