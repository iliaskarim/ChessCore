/// Context used to evaluate draw conditions.
public struct DrawContext {
  /// Current board state.
  public let board: Board

  let turns: [Turn]

  var isDrawByAgreement: Bool {
    guard case .end(nil) = turns.last else {
      return false
    }

    return true
  }

  var isDrawByFiftyMoveRule: Bool {
    turns.count >= 100 && !turns.suffix(100).contains { turn in
      switch turn {
      case let .move(move, _):
        move.movingFigure == .pawn || move.isCapture

      case .end:
        false
      }
    }
  }

  init(board: Board, turns: [Turn]) {
    self.board = board
    self.turns = turns
  }
}
