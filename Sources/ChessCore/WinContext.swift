/// Context used to evaluate win conditions.
public struct WinContext {
  /// Current board state.
  public let board: Board

  /// Side to move.
  public let toMove: Piece.Color

  let turns: [Turn]

  init(board: Board, turns: [Turn], toMove: Piece.Color) {
    self.board = board
    self.turns = turns
    self.toMove = toMove
  }
}
