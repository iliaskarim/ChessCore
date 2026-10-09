import Testing
@testable import ChessCore

struct CastleTests {
  @Test
  func testLongDescription() {
    #expect(Castle.long.description == "O-O-O")
  }

  @Test
  func testShortDescription() {
    #expect(Castle.short.description == "O-O")
  }
}
