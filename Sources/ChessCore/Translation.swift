/// A non-capturing, non-promoting move to another square.
public struct Translation: Move, Hashable {
  /// Moving figure.
  public let figure: Piece.Figure

  /// Disambiguation file, if any.
  public let disambiguationFile: Square.File?

  /// Disambiguation rank, if any.
  public let disambiguationRank: Square.Rank?

  /// Square the figure moves to.
  public let targetSquare: Square

  public var movingFigure: Piece.Figure? {
    figure
  }

  public var moveTargetSquare: Square? {
    targetSquare
  }

  public var isCapture: Bool {
    false
  }

  public func isSameMove(as move: any Move) -> Bool {
    guard let move = move as? Self else {
      return false
    }

    return self == move
  }

  /// Creates a translation describing a non-castling move.
  ///
  /// - Parameters:
  ///   - figure: The moving figure.
  ///   - disambiguationFile: The disambiguation file, if any.
  ///   - disambiguationRank: The disambiguation rank, if any.
  ///   - targetSquare: The square the figure moves to.
  public init(
    figure: Piece.Figure,
    disambiguationFile: Square.File? = nil,
    disambiguationRank: Square.Rank? = nil,
    targetSquare: Square
  ) {
    self.figure = figure
    self.disambiguationFile = disambiguationFile
    self.disambiguationRank = disambiguationRank
    self.targetSquare = targetSquare
  }
}

extension Translation: CustomStringConvertible {
  public var description: String {
    let disambiguation = "\(disambiguationFile?.description ?? "")\(disambiguationRank?.description ?? "")"
    return "\(figure.rawValue)\(disambiguation)\(targetSquare)"
  }
}
