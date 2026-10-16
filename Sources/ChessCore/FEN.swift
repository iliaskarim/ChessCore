private extension Piece {
  var fen: String {
    let symbol = figure == .pawn ? "P" : figure.rawValue
    return color == .white ? symbol : symbol.lowercased()
  }
}

extension Board {
  /// Forsyth-Edwards Notation for this position.
  ///
  /// Fields are piece placement, the side to move, castling rights, the en
  /// passant target square, the halfmove clock, and the fullmove number. A new
  /// board starts at halfmove 0 and fullmove 1. Applying a move advances both.
  public var fen: String {
    [
      fenPlacement,
      toMove == .white ? "w" : "b",
      fenCastling,
      enPassantSquare?.description ?? "-",
      String(halfmoveClock),
      String(fullmoveNumber)
    ].joined(separator: " ")
  }

  private var fenCastling: String {
    let marks = [
      (Piece.Color.white, Castling.kingside, "K"),
      (.white, .queenside, "Q"),
      (.black, .kingside, "k"),
      (.black, .queenside, "q")
    ].compactMap { color, side, mark in
      hasCastlingRight(side, for: color) ? mark : nil
    }
    .joined()

    return marks.isEmpty ? "-" : marks
  }

  private var fenPlacement: String {
    Square.Rank.allCases.reversed().map(fenRank).joined(separator: "/")
  }

  private func fenRank(_ rank: Square.Rank) -> String {
    var empty = 0
    var text = ""
    for file in Square.File.allCases {
      if let piece = pieces[.init(file: file, rank: rank)] {
        if empty > 0 {
          text.append(String(empty))
          empty = 0
        }

        text.append(piece.fen)
      } else {
        empty += 1
      }
    }

    if empty > 0 {
      text.append(String(empty))
    }

    return text
  }
}
