/// Draw by player agreement.
public struct AgreementDrawCondition: GameDrawCondition {
  public static let name = String.agreement

  static func isDraw(board _: Board, turns: [Turn]) -> Bool {
    turns.last == .end(victor: nil)
  }
}
