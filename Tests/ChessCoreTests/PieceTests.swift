import Testing
@testable import ChessCore

struct PieceTests {
  // MARK: - Piece.Color

  @Test
  func testPieceColorBackRank() {
    #expect(Piece.Color.white.backRank == .one)
    #expect(Piece.Color.black.backRank == .eight)
  }

  @Test
  func testPieceColorForwardUnitVector() {
    #expect(Piece.Color.white.forwardUnitVector.files == 0)
    #expect(Piece.Color.white.forwardUnitVector.ranks == 1)

    #expect(Piece.Color.black.forwardUnitVector.files == 0)
    #expect(Piece.Color.black.forwardUnitVector.ranks == -1)
  }

  @Test
  func testPieceColorOpposite() {
    #expect(Piece.Color.white.opposite == .black)
    #expect(Piece.Color.black.opposite == .white)
  }

  @Test
  func testPieceColorPawnSinglePushRankFromStartRank() {
    #expect(Piece.Color.white.pawnSinglePushTargetRankFromStart == .three)
    #expect(Piece.Color.black.pawnSinglePushTargetRankFromStart == .six)
  }

  @Test
  func testPieceColorPawnDoublePushRankFromStartRank() {
    #expect(Piece.Color.white.pawnDoublePushTargetRankFromStart == .four)
    #expect(Piece.Color.black.pawnDoublePushTargetRankFromStart == .five)
  }

  @Test
  func testPieceColorPawnStartRank() {
    #expect(Piece.Color.white.pawnStartRank == .two)
    #expect(Piece.Color.black.pawnStartRank == .seven)
  }
}
