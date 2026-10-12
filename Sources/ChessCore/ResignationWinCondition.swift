/// Win by resignation.
public struct ResignationWinCondition: WinCondition {
  public static var name: String {
    "resignation"
  }

  public static func winner(in context: WinContext) -> Piece.Color? {
    guard case let .end(victor?) = context.turns.last else {
      return nil
    }

    return victor
  }
}
