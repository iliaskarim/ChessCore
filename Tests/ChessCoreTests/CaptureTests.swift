import Testing
@testable import ChessCore

struct CaptureTests {
  @Test
  func testDescriptionWithRankDisambiguation() {
    let move = Capture(
      figure: .rook,
      disambiguationRank: .one,
      targetSquare: .init(file: .d, rank: .one)
    )

    #expect(move.description == "R1xd1")
  }

  @Test
  func testDescriptionWithSquareDisambiguation() {
    let move = Capture(
      figure: .rook,
      disambiguationFile: .a,
      disambiguationRank: .one,
      targetSquare: .init(file: .d, rank: .one)
    )

    #expect(move.description == "Ra1xd1")
  }
}
