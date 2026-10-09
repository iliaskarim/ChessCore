import Testing
@testable import ChessCore

struct AnyMoveTests {
  @Test
  func testEqualMovesCompareEqualAfterErasure() {
    let lhs = AnyMove(Translation(
      figure: .knight,
      targetSquare: .init(file: .f, rank: .three)
    ))
    let rhs = AnyMove(Translation(
      figure: .knight,
      targetSquare: .init(file: .f, rank: .three)
    ))

    #expect(lhs == rhs)
  }

  @Test
  func testEqualMovesCollapseInSetAfterErasure() {
    let move = Translation(
      figure: .knight,
      targetSquare: .init(file: .f, rank: .three)
    )
    let moves: Set<AnyMove> = [
      AnyMove(move),
      AnyMove(move)
    ]

    #expect(moves.count == 1)
  }

  @Test
  func testDifferentMoveKindsDoNotCompareEqualAfterErasure() {
    let translation = AnyMove(Translation(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .four)
    ))
    let capture = AnyMove(Capture(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .four)
    ))

    #expect(translation != capture)
  }

  @Test
  func testDisambiguationIsPartOfErasedMoveEquality() {
    let fileDisambiguatedMove = AnyMove(Translation(
      figure: .knight,
      disambiguationFile: .b,
      targetSquare: .init(file: .d, rank: .two)
    ))
    let rankDisambiguatedMove = AnyMove(Translation(
      figure: .knight,
      disambiguationRank: .one,
      targetSquare: .init(file: .d, rank: .two)
    ))

    #expect(fileDisambiguatedMove != rankDisambiguatedMove)
  }
}
