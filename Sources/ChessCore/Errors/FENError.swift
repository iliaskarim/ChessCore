import Foundation

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

extension FENError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .invalidFieldCount:
      "A FEN has six fields: placement, side to move, castling, "
        + "en passant, halfmove clock, and fullmove number."

    case .invalidPlacement:
      "Piece placement must be eight ranks of eight squares."

    case .invalidSideToMove:
      "The side to move must be w or b."

    case .invalidCastlingRights:
      "Castling rights must be - or a combination of K, Q, k, and q."

    case .invalidEnPassantSquare:
      "The en passant target must be - or a square."

    case .invalidHalfmoveClock:
      "The halfmove clock must be a non-negative integer."

    case .invalidFullmoveNumber:
      "The fullmove number must be a positive integer."
    }
  }
}
