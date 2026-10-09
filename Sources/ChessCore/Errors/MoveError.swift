/// Errors related to move validation.
public enum MoveError: Error, Equatable {
  /// More than one legal move matches the requested move.
  case ambiguousMove(candidates: [any Move])

  /// No legal move matches the requested move.
  case illegalMove

  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.ambiguousMove(lhsCandidates), .ambiguousMove(rhsCandidates)):
      lhsCandidates.map(AnyMove.init) == rhsCandidates.map(AnyMove.init)

    case (.illegalMove, .illegalMove):
      true

    default:
      false
    }
  }
}
