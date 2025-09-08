public extension String {
  /// Standard result notation indicating a Black win.
  static let blackVictoryNotation = "0-1"

  /// SAN marker used in move notation for captures.
  static let captureNotation = "x"

  /// SAN notation for queenside castling.
  static let castleLongNotation = "O-O-O"

  /// SAN notation for kingside castling.
  static let castleShortNotation = "O-O"

  /// Standard result notation indicating a drawn game.
  static let drawNotation = "1/2-1/2"

  /// SAN marker used in move notation for promotions.
  static let promotionNotation = "="

  /// Standard result notation indicating a White win.
  static let whiteVictoryNotation = "1-0"
}
