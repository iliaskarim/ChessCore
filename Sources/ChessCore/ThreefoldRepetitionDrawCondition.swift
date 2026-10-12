/// Draw by threefold repetition.
public struct ThreefoldRepetitionDrawCondition: DrawCondition {
  public static var name: String {
    "threefold repetition"
  }

  public static func isDraw(in context: DrawContext) -> Bool {
    guard let currentPositionIdentity = context.positionIdentities.last else {
      return false
    }

    return context.positionIdentities.filter { positionIdentity in
      positionIdentity == currentPositionIdentity
    }
    .count >= 3
  }
}
