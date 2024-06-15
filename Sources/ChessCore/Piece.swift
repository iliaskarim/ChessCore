/// A model representing a chess piece.
public struct Piece: Equatable {
  /// Color
  enum Color: String, CaseIterable {
    case white
    case black
  }

  /// Figure
  enum Figure: String, CaseIterable {
    case bishop = "B"
    case king = "K"
    case knight = "N"
    case pawn = "X"
    case queen = "Q"
    case rook = "R"
  }

  /// Color
  let color: Color

  /// Figure
  let figure: Figure
}
