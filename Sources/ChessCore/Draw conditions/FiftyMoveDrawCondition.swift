private extension AnyMove {
  var isIrreversible: Bool {
    figure == .pawn || isCapture
  }
}

/// Draw after fifty full moves without a pawn move or capture.
public struct FiftyMoveDrawCondition: GameDrawCondition {
  public static let name = String.fiftyMoveRule

  static func isDraw(board _: Board, turns: [Turn]) -> Bool {
    turns.reversed().prefix { turn in
      switch turn {
      case let .move(move, _):
        !move.isIrreversible

      case .end:
        false
      }
    }
    .count >= 100
  }
}
