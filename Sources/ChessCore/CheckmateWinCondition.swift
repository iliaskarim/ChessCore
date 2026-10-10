/// Win by checkmate.
public struct CheckmateWinCondition: WinCondition {
  public static var name: String {
    .checkmate.lowercased()
  }

  public static func winner(in context: WinContext) -> Piece.Color? {
    context.board.status == .checkmate ? context.toMove.opposite : nil
  }
}
