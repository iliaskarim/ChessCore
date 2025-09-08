import Testing
@testable import ChessCore

struct MoveTests {
  // MARK: - Is Capture

  @Test
  func testCastlingMoveIsCapture() {
    #expect(!Move.castling(.kingside).isCapture)
    #expect(!Move.castling(.queenside).isCapture)
  }

  @Test
  func testTranslationMoveIsCapture() {
    let xe5 = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .five),
      isCapture: true
    ))
    #expect(xe5.isCapture)

    let e5 = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .five)
    ))
    #expect(!e5.isCapture)
  }
}
