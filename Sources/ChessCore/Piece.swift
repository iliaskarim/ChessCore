/// A model representing a chess piece.
public struct Piece: Equatable {
  /// Color
  public enum Color: String, CaseIterable {
    case white
    case black
    
    /// Opposite color
    var opposite: Color {
      switch self {
      case .white: 
        return .black

      case .black: 
        return .white
      }
    }
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
