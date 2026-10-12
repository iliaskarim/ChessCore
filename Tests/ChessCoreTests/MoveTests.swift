import Testing
@testable import ChessCore

private extension Square {
  static let e5 = Self(file: .e, rank: .five)
}

struct MoveTests {
  @Test
  func castlingMoveIsCapture() {
    #expect(!Move.castling(.kingside).isCapture)
    #expect(!Move.castling(.queenside).isCapture)
  }

  @Test
  func translationMoveIsCapture() {
    let xe5 = Move.translation(.init(
      figure: .pawn,
      targetSquare: .e5,
      isCapture: true
    ))
    #expect(xe5.isCapture)

    let e5 = Move.translation(.init(
      figure: .pawn,
      targetSquare: .e5
    ))
    #expect(!e5.isCapture)
  }
}
