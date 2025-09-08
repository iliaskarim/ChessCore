/// A chess move.
///
/// Each move is either a ``Castle`` (castling move) or a ``Translation``
/// (non-castling move). Castling moves record whether castling is kingside or
/// queenside. Non-castling moves record the moving figure, whether the move
/// captures, optional promotion figure, optional algebraic disambiguation, and
/// the square the figure moves to.
public enum Move: Hashable {
  /// A castling move.
  ///
  /// Castling is either kingside or queenside.
  public enum Castle: CaseIterable {
    /// Kingside castling.
    case short

    /// Queenside castling.
    case long
  }

  /// A non-castling move.
  ///
  /// Details include the moving figure, whether the move captures, optional
  /// promotion figure, optional algebraic disambiguation, and the square the figure
  /// moves to.
  public struct Translation: Hashable {
    /// Moving figure.
    public let figure: Piece.Figure

    /// Whether the move captures.
    public let isCapture: Bool

    /// Figure to promote to, if any.
    public let promotion: Piece.Figure?

    /// Disambiguation file, if any.
    public let disambiguationFile: Square.File?

    /// Disambiguation rank, if any.
    public let disambiguationRank: Square.Rank?

    /// Square the figure moves to.
    public let targetSquare: Square

    /// Creates a translation describing a non-castling move.
    ///
    /// - Parameters:
    ///   - figure: The moving figure.
    ///   - isCapture: Whether the move captures.
    ///   - promotion: The figure to promote to, if any.
    ///   - disambiguationFile: The disambiguation file, if any.
    ///   - disambiguationRank: The disambiguation rank, if any.
    ///   - targetSquare: The square the figure moves to.
    public init(
      figure: Piece.Figure,
      isCapture: Bool,
      promotion: Piece.Figure?,
      disambiguationFile: Square.File?,
      disambiguationRank: Square.Rank?,
      targetSquare: Square
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
  case castle(_ castle: Castle)

  /// The move is a non-castling move.
  case translation(_ translation: Translation)

  var isCapture: Bool {
    switch self {
    case let .translation(translation):
      translation.isCapture

    case .castle:
      false
    }
  }
}

extension Move: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .castle(castle):
      "\(castle)"

    case let .translation(translation):
      "\(translation)"
    }
  }
}

extension Move.Castle: CustomStringConvertible {
  public var description: String {
    switch self {
    case .short:
      .castleShortNotation

    case .long:
      .castleLongNotation
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
