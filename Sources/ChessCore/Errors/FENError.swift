/// Errors related to Forsyth-Edwards Notation.
public enum FENError: Error, Equatable {
  /// The string does not have the six FEN fields.
  case invalidFieldCount

  /// Piece placement is not eight ranks of eight squares.
  case invalidPlacement

  /// The side to move is not `w` or `b`.
  case invalidSideToMove

  /// Castling rights are not `-` or a combination of `K`, `Q`, `k`, and `q`.
  case invalidCastlingRights

  /// The en passant target is not `-` or a square.
  case invalidEnPassantSquare

  /// The halfmove clock is not a non-negative integer.
  case invalidHalfmoveClock

  /// The fullmove number is not a positive integer.
  case invalidFullmoveNumber
}
