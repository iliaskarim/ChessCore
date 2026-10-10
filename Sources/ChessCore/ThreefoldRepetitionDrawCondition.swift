/// Draw by threefold repetition.
public struct ThreefoldRepetitionDrawCondition: DrawCondition {
  public static var name: String {
    "threefold repetition"
  }

  public static func isDraw(in context: DrawContext) -> Bool {
    context.isDrawByThreefoldRepetition
  }
}
