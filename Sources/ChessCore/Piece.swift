/// A chess piece.
///
/// Each piece is identified by its ``Color`` (side) and ``Figure`` (kind).
public struct Piece: Equatable, Sendable {
  /// A piece's color.
  ///
  /// A color identifies which side a piece belongs to.
  public enum Color: String, CaseIterable, Sendable {
    case white, black

    /// Opposing piece color.
    public var opposite: Self {
      self == .white ? .black : .white
    }

    var backRank: Square.Rank {
      self == .white ? .one : .eight
    }

    var forwardUnitVector: Board.Vector {
      .init(files: 0, ranks: self == .white ? 1 : -1)
    }

    var pawnDoublePushTargetRank: Square.Rank {
      .init(rawValue: pawnSinglePushTargetRank.rawValue + forwardUnitVector.ranks)!
    }

    var pawnSinglePushTargetRank: Square.Rank {
      .init(rawValue: pawnRank.rawValue + forwardUnitVector.ranks)!
    }

    var pawnRank: Square.Rank {
      .init(rawValue: backRank.rawValue + forwardUnitVector.ranks)!
    }
  }

  /// A piece's figure.
  ///
  /// A figure identifies the kind of chess piece.
  public enum Figure: String, CaseIterable, Sendable {
    case king = "K"

    case queen = "Q"

    case rook = "R"

    case bishop = "B"

    case knight = "N"

    case pawn = ""
  }

  /// Piece color.
  public let color: Color

  /// Piece figure.
  public let figure: Figure

  /// Creates a piece from a color and figure.
  ///
  /// - Parameters:
  ///   - color: The piece's color.
  ///   - figure: The piece's figure.
  public init(color: Color, figure: Figure) {
    self.color = color
    self.figure = figure
  }
}

extension Piece: CustomDebugStringConvertible {
  public var debugDescription: String {
    color == .white ? figure.debugDescription : figure.debugDescription.lowercased()
  }
}

extension Piece.Color: CustomStringConvertible {
  public var description: String {
    rawValue.capitalized
  }
}

extension Piece.Figure: CustomDebugStringConvertible {
  public var debugDescription: String {
    self == .pawn ? "P" : rawValue
  }
}
