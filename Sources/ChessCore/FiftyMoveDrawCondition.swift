/// Draw by the fifty-move rule.
public struct FiftyMoveDrawCondition: DrawCondition {
  public static var name: String {
    .fiftyMoveRule
  }

  public static func isDraw(in context: DrawContext) -> Bool {
    context.turns.count >= 100 && !context.turns.suffix(100).contains { turn in
      switch turn {
      case let .move(move, _):
        move.movingFigure == .pawn || move.isCapture

      case .end:
        false
      }
    }
  }
}
