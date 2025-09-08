/// Errors related to move validation.
public enum MoveError: Error, Equatable {
  /// More than one legal move matches the requested move.
  case ambiguousMove(candidates: [Move])

  /// No legal move matches the requested move.
  case illegalMove
}
