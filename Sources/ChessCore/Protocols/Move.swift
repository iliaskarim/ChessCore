/// A chess move.
public protocol Move: CustomStringConvertible, Hashable, Sendable {
  /// Whether the move captures.
  var isCapture: Bool { get }

  /// Square the move targets, if any.
  var moveTargetSquare: Square? { get }

  /// Moving figure, if the move moves a single piece to a square.
  var movingFigure: Piece.Figure? { get }

  /// Returns whether this move is structurally the same as another move.
  func isSameMove(as move: any Move) -> Bool
}
