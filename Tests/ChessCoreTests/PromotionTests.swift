import Testing
@testable import ChessCore

struct PromotionTests {
  @Test
  func testCaptureDescription() {
    let move = Promotion.capture(Capture(
      figure: .pawn,
      disambiguationFile: .e,
      targetSquare: .init(file: .d, rank: .eight)
    ), to: .queen)

    #expect(move.description == "exd8=Q")
  }

  @Test
  func testTranslationPromotionForwardsMoveProperties() {
    let promotion = Promotion.translation(Translation(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .eight)
    ), to: .queen)

    #expect(promotion.figure == .queen)
    #expect(promotion.movingFigure == .pawn)
    #expect(promotion.moveTargetSquare == .init(file: .e, rank: .eight))
    #expect(promotion.isCapture == false)
  }

  @Test
  func testCapturePromotionForwardsMoveProperties() {
    let promotion = Promotion.capture(Capture(
      figure: .pawn,
      disambiguationFile: .e,
      targetSquare: .init(file: .d, rank: .eight)
    ), to: .queen)

    #expect(promotion.figure == .queen)
    #expect(promotion.movingFigure == .pawn)
    #expect(promotion.moveTargetSquare == .init(file: .d, rank: .eight))
    #expect(promotion.isCapture == true)
  }
}
