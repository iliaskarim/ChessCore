/// A castling move.
///
/// Castling is either kingside or queenside.
public enum Castling: String, CaseIterable, Move, Hashable, Sendable {
  /// Kingside castling.
  case kingside = "O-O"

  /// Queenside castling.
  case queenside = "O-O-O"

  public var disambiguationFile: Square.File? {
    nil
  }

  public var disambiguationRank: Square.Rank? {
    nil
  }

  public var figure: Piece.Figure {
    .king
  }

  public var isCapture: Bool {
    false
  }

  public var promotion: Piece.Figure? {
    nil
  }
}

extension Castling: CustomStringConvertible {
  public var description: String {
    rawValue
  }
}

extension Castling {
  func requiredEmptySquares(for color: Piece.Color) -> [Square] {
    (self == .kingside ? [.f, .g] : [.b, .c, .d]).map { file in
      .init(file: file, rank: color.backRank)
    }
  }

  func rookSquare(for color: Piece.Color) -> Square {
    .init(file: self == .kingside ? .h : .a, rank: color.backRank)
  }

  func rookTargetSquare(for color: Piece.Color) -> Square {
    .init(file: self == .kingside ? .f : .d, rank: color.backRank)
  }
}

public extension Castling {
  func targetSquare(for color: Piece.Color) -> Square {
    .init(file: self == .kingside ? .g : .c, rank: color.backRank)
  }

  func transforms(for piece: Piece, from square: Square) -> [Board.Transform] {
    // First transform: place the king on rook target square. Legality is
    // checked after each step so the king cannot castle through attack.
    [{ board in
      board.with(
        pieces: board.pieces.filter { key, _ in key != square }
          .merging([
            rookTargetSquare(for: piece.color): piece
          ]) { _, new in new },
        enPassantSquare: nil,
        castlingRights: board.castlingRights(moving: piece, from: square, capturing: nil)
      )
    }, { board in
      let rookSquare = rookSquare(for: piece.color)
      return board.with(
        pieces: board.pieces.filter { key, _ in key != rookSquare }
          .merging([
            targetSquare(for: piece.color): piece,
            rookTargetSquare(for: piece.color): .init(color: piece.color, figure: .rook)
          ]) { _, new in new },
        enPassantSquare: nil,
        castlingRights: board.castlingRights(
          moving: .init(color: piece.color, figure: .rook),
          from: rookSquare,
          capturing: nil
        )
      )
    }]
  }
}
