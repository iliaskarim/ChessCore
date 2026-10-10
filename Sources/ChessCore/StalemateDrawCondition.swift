/// Draw by stalemate.
public struct StalemateDrawCondition: DrawCondition {
  public static var name: String {
    .stalemate.lowercased()
  }

  public static func isDraw(in context: DrawContext) -> Bool {
    context.board.status == .stalemate
  }
}
