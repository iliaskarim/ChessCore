/// A hashable type-erased move.
public struct AnyMove: Move, Hashable {
  private let move: any Move

  /// Creates a type-erased move.
  ///
  /// - Parameter move: The move to erase.
  public init(_ move: any Move) {
    self.move = move
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

  public var description: String {
    move.description
  }

  public func isSameMove(as move: any Move) -> Bool {
    if let move = move as? Self {
      return self.move.isSameMove(as: move.move)
    }

    return self.move.isSameMove(as: move)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.move.isSameMove(as: rhs.move)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(AnyHashable(move))
  }
}
