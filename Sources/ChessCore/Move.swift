/// A chess move.
///
/// Each move is either a ``Castling`` (castling move) or a ``Translation``
/// (non-castling move). Castling moves record whether castling is kingside or
/// queenside. Non-castling moves record the moving figure, the destination
/// square, whether the move captures, an optional promotion figure, and
/// optional algebraic disambiguation.
public protocol Move: CustomStringConvertible, Sendable {
  /// Disambiguation file, if any.
  var disambiguationFile: Square.File? { get }

  /// Disambiguation rank, if any.
  var disambiguationRank: Square.Rank? { get }

  /// The figure that moves.
  var figure: Piece.Figure { get }

  /// Whether the move captures.
  var isCapture: Bool { get }

  /// Figure to promote to, if any.
  var promotion: Piece.Figure? { get }

  /// Square the moving piece moves to.
  ///
  /// `color` selects the castling rank. Other moves ignore it.
  func targetSquare(for color: Piece.Color) -> Square

  /// One board update for each step of this move.
  func transforms(for piece: Piece, from square: Square) -> [Board.Transform]
}
