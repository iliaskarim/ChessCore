/// A chess move.
public protocol Move: CustomStringConvertible, Hashable, Sendable {
  /// Moving figure, if the move moves a single piece to a square.
  var movingFigure: Piece.Figure? { get }

  /// Square the move targets, if any.
  var moveTargetSquare: Square? { get }

  /// Whether the move captures.
  var isCapture: Bool { get }

  /// Returns whether this move is structurally the same as another move.
  func isSameMove(as move: any Move) -> Bool
}
