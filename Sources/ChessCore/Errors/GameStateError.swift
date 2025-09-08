/// Errors related to game state validation.
public enum GameStateError: Error, Equatable {
  /// The operation cannot be performed because the game is over.
  case gameOver
}
