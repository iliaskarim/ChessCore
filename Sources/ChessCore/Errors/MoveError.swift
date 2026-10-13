/// Errors related to move validation.
public enum MoveError: Error, Equatable {
  /// More than one legal move matches the requested move.
  case ambiguousMove(candidates: [AnyMove])

  /// No legal move matches the requested move.
  case illegalMove

  /// The move leaves the mover in check.
  case illegalMoveIntoCheck
}
