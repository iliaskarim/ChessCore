import Testing
@testable import ChessCore

struct PieceTests {
  // MARK: - Piece.Color

  @Test
  func pieceColorBackRank() {
    #expect(Piece.Color.white.backRank == .one)
    #expect(Piece.Color.black.backRank == .eight)
  }

  @Test
  func pieceColorForwardUnitVector() {
    #expect(Piece.Color.white.forwardUnitVector.files == 0)
    #expect(Piece.Color.white.forwardUnitVector.ranks == 1)

    #expect(Piece.Color.black.forwardUnitVector.files == 0)
    #expect(Piece.Color.black.forwardUnitVector.ranks == -1)
  }

  @Test
  func pieceColorOpposite() {
    #expect(Piece.Color.white.opposite == .black)
    #expect(Piece.Color.black.opposite == .white)
  }

  @Test
  func pieceColorPawnSinglePushTargetRank() {
    #expect(Piece.Color.white.pawnSinglePushTargetRank == .three)
    #expect(Piece.Color.black.pawnSinglePushTargetRank == .six)
  }

  @Test
  func pieceColorPawnDoublePushTargetRank() {
    #expect(Piece.Color.white.pawnDoublePushTargetRank == .four)
    #expect(Piece.Color.black.pawnDoublePushTargetRank == .five)
  }

  @Test
  func pieceColorPawnRank() {
    #expect(Piece.Color.white.pawnRank == .two)
    #expect(Piece.Color.black.pawnRank == .seven)
  }
}
