import Testing
@testable import ChessCore

struct MoveTests {
  @Test
  func testMoveDescriptionForLongCastle() {
    #expect(Move.castle(.long).description == "O-O-O")
  }

  @Test
  func testMoveDescriptionForShortCastle() {
    #expect(Move.castle(.short).description == "O-O")
  }

  @Test
  func testMoveDescriptionForTranslation() {
    let move = Move.translation(.init(
      figure: .bishop,
      targetSquare: .init(file: .c, rank: .four)
    ))

    #expect(move.description == "Bc4")
  }

  @Test
  func testMoveDescriptionForTranslationWithCaptureAndPromotion() {
    let move = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .d, rank: .eight),
      isCapture: true,
      promotion: .queen,
      disambiguationFile: .e
    ))

    #expect(move.description == "exd8=Q")
  }

  @Test
  func testMoveDescriptionForTranslationWithRankDisambiguation() {
    let move = Move.translation(.init(
      figure: .rook,
      targetSquare: .init(file: .d, rank: .one),
      isCapture: true,
      disambiguationRank: .one
    ))

    #expect(move.description == "R1xd1")
  }

  @Test
  func testMoveDescriptionForTranslationWithSquareDisambiguation() {
    let move = Move.translation(.init(
      figure: .rook,
      targetSquare: .init(file: .d, rank: .one),
      isCapture: true,
      disambiguationFile: .a,
      disambiguationRank: .one
    ))

    #expect(move.description == "Ra1xd1")
  }

  @Test
  func testMoveIsCaptureForCastling() {
    #expect(!Move.castle(.short).isCapture)
    #expect(!Move.castle(.long).isCapture)
  }

  @Test
  func testMoveIsCaptureForTranslation() {
    let captureMove = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .five),
      isCapture: true
    ))
    #expect(captureMove.isCapture)

    let nonCaptureMove = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .five)
    ))
    #expect(!nonCaptureMove.isCapture)
  }
}
