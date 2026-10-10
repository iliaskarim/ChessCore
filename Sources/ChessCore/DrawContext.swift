/// Context used to evaluate draw conditions.
public struct DrawContext {
  /// Current board state.
  public let board: Board

  let turns: [Turn]
  let positionIdentities: [PositionIdentity]

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

  var isDrawByThreefoldRepetition: Bool {
    guard let currentPositionIdentity = positionIdentities.last else {
      return false
    }

    return positionIdentities.filter { positionIdentity in
      positionIdentity == currentPositionIdentity
    }
    .count >= 3
  }

  init(board: Board, turns: [Turn], positionIdentities: [PositionIdentity]) {
    self.board = board
    self.turns = turns
    self.positionIdentities = positionIdentities
  }
}

struct PositionIdentity: Hashable {
  let pieces: [Square: Piece]

  let toMove: Piece.Color

  let enPassantSquare: Square?

  let castlingRights: Set<CastlingRight>
}

struct CastlingRight: Hashable {
  let color: Piece.Color

  let castle: Castle
}
