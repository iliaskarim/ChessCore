/// Draw by agreement between players.
public struct AgreementDrawCondition: DrawCondition {
  public static var name: String {
    .agreement
  }

  public static func isDraw(in context: DrawContext) -> Bool {
    guard case .end(nil) = context.turns.last else {
      return false
    }

    return true
  }
}
