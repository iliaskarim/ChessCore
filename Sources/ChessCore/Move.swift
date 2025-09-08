/// A chess move.
///
/// Each move is either a ``Castling`` (castling move) or a ``Translation``
/// (non-castling move). Castling moves record whether castling is kingside or
/// queenside. Non-castling moves record the moving figure, the destination
/// square, whether the move captures, an optional promotion figure, and
/// optional algebraic disambiguation.
public enum Move: Hashable {
  /// A castling move.
  ///
  /// Castling is either kingside or queenside.
  public enum Castling: CaseIterable {
    /// Kingside (O-O) castling.
    case kingside

    /// Queenside (O-O-O) castling.
    case queenside
  }

  /// A non-castling move.
  ///
  /// Details include the moving figure, the square the figure moves to,
  /// whether the move captures, an optional promotion figure, and optional
  /// algebraic disambiguation.
  public struct Translation: Hashable {
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

  /// The move is castling.
  case castling(_ castling: Castling)

  /// The move is a non-castling move.
  case translation(_ translation: Translation)

  var isCapture: Bool {
    switch self {
    case let .translation(translation):
      translation.isCapture

    case .castling:
      false
    }
  }
}

extension Move: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .castling(castling):
      "\(castling)"

    case let .translation(translation):
      "\(translation)"
    }
  }
}

extension Move.Castling: CustomStringConvertible {
  public var description: String {
    switch self {
    case .kingside:
      .castlingShortNotation

    case .queenside:
      .castlingLongNotation
    }
  }
}

extension Move.Translation: CustomStringConvertible {
  public var description: String {
    let disambiguation = "\(disambiguationFile?.description ?? "")\(disambiguationRank?.description ?? "")"
    let promotion = promotion.map(\.rawValue).map(String.promotionNotation.appending) ?? ""
    return """
    \(figure.rawValue)\(disambiguation)\(isCapture ? .captureNotation : "")\(targetSquare)\(promotion)
    """
  }
}
