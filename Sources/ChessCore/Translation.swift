/// A non-castling move.
///
/// Details include the moving figure, the square the figure moves to, whether
/// the move captures, an optional promotion figure, and optional algebraic
/// disambiguation.
public struct Translation: Move, Hashable, Sendable {
  /// Moving figure.
  public let figure: Piece.Figure

  /// Square the figure moves to.
  public let targetSquare: Square

  /// Whether the move captures.
  public let isCapture: Bool

  /// Figure to promote to, if any.
  public let promotion: Piece.Figure?

  /// Disambiguation file, if any.
  public let disambiguationFile: Square.File?

  /// Disambiguation rank, if any.
  public let disambiguationRank: Square.Rank?

  /// Creates a translation describing a non-castling move.
  ///
  /// - Parameters:
  ///   - figure: The moving figure.
  ///   - targetSquare: The square the figure moves to.
  ///   - isCapture: Whether the move captures. Defaults to `false`.
  ///   - promotion: The figure to promote to, if any. Defaults to `nil`.
  ///   - disambiguationFile: The disambiguation file, if any. Defaults to `nil`.
  ///   - disambiguationRank: The disambiguation rank, if any. Defaults to `nil`.
  public init(
    figure: Piece.Figure,
    targetSquare: Square,
    isCapture: Bool = false,
    promotion: Piece.Figure? = nil,
    disambiguationFile: Square.File? = nil,
    disambiguationRank: Square.Rank? = nil
  ) {
    self.figure = figure
    self.isCapture = isCapture
    self.promotion = promotion
    self.disambiguationFile = disambiguationFile
    self.disambiguationRank = disambiguationRank
    self.targetSquare = targetSquare
  }
}

extension Translation: CustomStringConvertible {
  public var description: String {
    figure.rawValue.appending(disambiguationDescription)
      .appending(isCapture ? Notation.Marker.capture.rawValue : "")
      .appending(targetSquare.description)
      .appending(promotionDescription)
  }

  private var disambiguationDescription: String {
    "\(disambiguationFile?.description ?? "")\(disambiguationRank?.description ?? "")"
  }

  private var promotionDescription: String {
    promotion.map(\.rawValue).map(Notation.Marker.promotion.rawValue.appending) ?? ""
  }
}

public extension Translation {
  func targetSquare(for _: Piece.Color) -> Square {
    targetSquare
  }

  func transforms(for piece: Piece, from square: Square) -> [Board.Transform] {
    [{ board in
      let capturesEnPassant = piece.figure == .pawn && targetSquare == board.enPassantSquare
      let capturedSquare = capturesEnPassant
        ? board.enPassantSquare + .init(
          files: 0,
          ranks: -piece.color.forwardUnitVector.ranks
        )
        : board[targetSquare].map { _ in targetSquare }

      return board.with(
        pieces: board.pieces.filter { key, _ in
          key != square && capturedSquare.map { key != $0 } ?? true
        }
        .merging([
          targetSquare: .init(
            color: piece.color,
            figure: promotion ?? piece.figure
          )
        ]) { _, new in new },
        enPassantSquare: piece.figure == .pawn
          && abs(targetSquare.rank.rawValue - square.rank.rawValue) == 2
          ? Square.Rank(rawValue: (targetSquare.rank.rawValue + square.rank.rawValue) / 2).map { rank in
            Square(file: targetSquare.file, rank: rank)
          }
          : nil,
        castlingRights: board.castlingRights(moving: piece, from: square, to: targetSquare)
      )
    }]
  }
}
