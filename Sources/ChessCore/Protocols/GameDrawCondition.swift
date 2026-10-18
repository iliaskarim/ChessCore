protocol GameDrawCondition: DrawCondition {
  /// Whether the game is drawn by this condition.
  static func isDraw(
    turns: [Turn],
    boards: [Board]
  ) -> Bool
}
