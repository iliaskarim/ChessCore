/// Draw when the same position occurs for the third time.
public struct ThreefoldRepetitionDrawCondition: GameDrawCondition {
  public static let name = String.threefoldRepetition

  static func isDraw(
    turns _: [Turn],
    boards: [Board]
  ) -> Bool {
    let currentBoard = boards.last!

    return boards.filter { board in
      board.repeats(currentBoard)
    }
    .count >= 3
  }
}
