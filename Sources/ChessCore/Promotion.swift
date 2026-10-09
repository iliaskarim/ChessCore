/// A promoting move.
public enum Promotion: Move, Hashable {
  /// A non-capturing promotion.
  case translation(_ translation: Translation, to: Piece.Figure)

  /// A capturing promotion.
  case capture(_ capture: Capture, to: Piece.Figure)

  /// The move being promoted.
  public var move: any Move {
    switch self {
    case let .translation(translation, _):
      translation

    case let .capture(capture, _):
      capture
    }
  }

  /// Figure to promote to.
  public var figure: Piece.Figure {
    switch self {
    case let .translation(_, figure), let .capture(_, figure):
      figure
    }
  }

  public var movingFigure: Piece.Figure? {
    move.movingFigure
  }

  public var moveTargetSquare: Square? {
    move.moveTargetSquare
  }

  public var isCapture: Bool {
    move.isCapture
  }

  public func isSameMove(as move: any Move) -> Bool {
    guard let move = move as? Self else {
      return false
    }

    return self == move
  }
}

extension Promotion: CustomStringConvertible {
  public var description: String {
    "\(move)\(String.promotionNotation)\(figure.rawValue)"
  }
}
