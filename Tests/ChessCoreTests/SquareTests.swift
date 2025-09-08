import Testing
@testable import ChessCore

struct SquareTests {
  @Test
  func testSquareDescription() {
    #expect(Square(file: .e, rank: .four).description == "e4")
  }

  @Test
  func testSquareFileDescription() {
    #expect(Square.File.a.description == "a")
    #expect(Square.File.h.description == "h")
  }

  @Test
  func testSquareRankDescription() {
    #expect(Square.Rank.one.description == "1")
    #expect(Square.Rank.eight.description == "8")
  }
}
