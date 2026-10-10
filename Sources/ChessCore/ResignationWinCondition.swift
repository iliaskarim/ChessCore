/// Win by resignation.
public struct ResignationWinCondition: WinCondition {
  public static var name: String {
    "resignation"
  }

  public static func winner(in context: WinContext) -> Piece.Color? {
    context.resignationVictor
  }
}
