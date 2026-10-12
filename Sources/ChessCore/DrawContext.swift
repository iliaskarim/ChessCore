/// Context used to evaluate draw conditions.
public struct DrawContext {
  /// Current board state.
  public let board: Board

  let turns: [Turn]

  let positionIdentities: [PositionIdentity]
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
