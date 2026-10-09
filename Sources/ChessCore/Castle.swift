/// A castling move.
///
/// Castling is either kingside or queenside.
public enum Castle: Move, CaseIterable, Hashable {
  /// Kingside castling.
  case short

  /// Queenside castling.
  case long

  public var movingFigure: Piece.Figure? {
    .king
  }

  public var moveTargetSquare: Square? {
    nil
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
}

extension Castle: CustomStringConvertible {
  public var description: String {
    switch self {
    case .short:
      .castlingKingsideNotation

    case .long:
      .castlingQueensideNotation
    }
  }
}
