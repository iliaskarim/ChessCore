/// Draw when the side to move has no legal moves and is not in check.
public struct StalemateDrawCondition: GameDrawCondition {
  public static let name = String.stalemate.lowercased()

  static func isDraw(
    turns _: [Turn],
    boards: [Board]
  ) -> Bool {
    boards.last!.status == .stalemate
  }
}
