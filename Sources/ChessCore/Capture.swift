/// A capturing move.
public struct Capture: Move, Hashable {
  /// The captured move's translation.
  public let translation: Translation

  init(_ translation: Translation) {
    self.translation = translation
  }

  /// Creates a capture describing a non-castling move.
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
    translation = .init(
      figure: figure,
      disambiguationFile: disambiguationFile,
      disambiguationRank: disambiguationRank,
      targetSquare: targetSquare
    )
  }

  public var movingFigure: Piece.Figure? {
    translation.figure
  }

  public var moveTargetSquare: Square? {
    translation.targetSquare
  }

  public var isCapture: Bool {
    true
  }

  public func isSameMove(as move: any Move) -> Bool {
    guard let move = move as? Self else {
      return false
    }

    return self == move
  }
}

extension Capture: CustomStringConvertible {
  public var description: String {
    let disambiguation = """
    \(translation.disambiguationFile?.description ?? "")\(translation.disambiguationRank?.description ?? "")
    """
    return """
    \(translation.figure.rawValue)\(disambiguation)\(String.captureNotation)\(translation.targetSquare)
    """
  }
}
