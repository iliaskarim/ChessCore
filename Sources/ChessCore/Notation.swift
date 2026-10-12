/// Written chess notation.
///
/// ``Result`` is the notation for a finished game. ``Marker`` is a mark inside
/// a SAN move.
public enum Notation {
  /// A mark inside SAN move notation.
  ///
  /// A capture is marked `x`. A promotion is marked `=`.
  public enum Marker: String, CaseIterable, Sendable {
    /// Capture.
    case capture = "x"

    /// Promotion.
    case promotion = "="
  }

  /// A finished game's result notation.
  ///
  /// Results are White's win (`1-0`), Black's win (`0-1`), or a draw
  /// (`1/2-1/2`).
  public enum Result: String, CaseIterable, Sendable {
    /// White wins.
    case whiteVictory = "1-0"

    /// Black wins.
    case blackVictory = "0-1"

    /// The game is drawn.
    case draw = "1/2-1/2"
  }
}
