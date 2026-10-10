/// Draw by agreement between players.
public struct AgreementDrawCondition: DrawCondition {
  public static var name: String {
    .agreement
  }

  public static func isDraw(in context: DrawContext) -> Bool {
    context.isDrawByAgreement
  }
}
