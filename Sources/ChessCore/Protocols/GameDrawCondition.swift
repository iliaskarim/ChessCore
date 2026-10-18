protocol GameDrawCondition: DrawCondition {
  /// Whether the game is drawn by this condition.
  static func isDraw(
    board: Board,
    turns: [Turn],
    boards: [Board]
  ) -> Bool
}
