/// Draw when the side to move has no legal moves and is not in check.
public struct StalemateDrawCondition: GameDrawCondition {
  public static let name = String.stalemate.lowercased()

  static func isDraw(board: Board, turns _: [Turn]) -> Bool {
    board.status == .stalemate
  }
}
