import Testing
@testable import ChessCore

struct TranslationTests {
  @Test
  func testDescription() {
    let move = Translation(
      figure: .bishop,
      targetSquare: .init(file: .c, rank: .four)
    )

    #expect(move.description == "Bc4")
  }
}
