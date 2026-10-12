/// Draw when the same position occurs for the third time.
public struct ThreefoldRepetitionDrawCondition: GameDrawCondition {
  public static let name = String.threefoldRepetition

  static func isDraw(
    board _: Board,
    turns _: [Turn],
    boards: [Board]
  ) -> Bool {
    guard let currentBoard = boards.last else {
      return false
    }

    return boards.filter { board in
      board.repeats(currentBoard)
    }
    .count >= 3
  }
}
