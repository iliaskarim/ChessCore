/// Draw by the fifty-move rule.
public struct FiftyMoveDrawCondition: DrawCondition {
  public static var name: String {
    .fiftyMoveRule
  }

  public static func isDraw(in context: DrawContext) -> Bool {
    context.isDrawByFiftyMoveRule
  }
}
