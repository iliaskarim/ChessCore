import Testing
@testable import ChessCore

struct PieceTests {
  @Test
  func testPieceColorBackRank() {
    #expect(Piece.Color.white.backRank == .one)
    #expect(Piece.Color.black.backRank == .eight)
  }

  @Test
  func testPieceColorBlackDescription() {
    #expect(Piece.Color.black.description == "Black")
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
  func testPieceColorPawnStartForwardOneRank() {
    #expect(Piece.Color.white.pawnStartForwardOneRank == .three)
    #expect(Piece.Color.black.pawnStartForwardOneRank == .six)
  }

  @Test
  func testPieceColorPawnStartForwardTwoRanks() {
    #expect(Piece.Color.white.pawnStartForwardTwoRanks == .four)
    #expect(Piece.Color.black.pawnStartForwardTwoRanks == .five)
  }

  @Test
  func testPieceColorPawnStartRank() {
    #expect(Piece.Color.white.pawnStartRank == .two)
    #expect(Piece.Color.black.pawnStartRank == .seven)
  }

  @Test
  func testPieceColorWhiteDescription() {
    #expect(Piece.Color.white.description == "White")
  }
}
