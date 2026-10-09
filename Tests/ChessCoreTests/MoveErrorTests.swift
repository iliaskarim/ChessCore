import Testing
@testable import ChessCore

struct MoveErrorTests {
  @Test
  func testAmbiguousMoveErrorsWithEqualCandidatesCompareEqual() {
    let lhs = MoveError.ambiguousMove(candidates: [
      Translation(
        figure: .knight,
        targetSquare: .init(file: .f, rank: .three)
      ),
      Capture(
        figure: .pawn,
        disambiguationFile: .e,
        targetSquare: .init(file: .d, rank: .five)
      )
    ])
    let rhs = MoveError.ambiguousMove(candidates: [
      Translation(
        figure: .knight,
        targetSquare: .init(file: .f, rank: .three)
      ),
      Capture(
        figure: .pawn,
        disambiguationFile: .e,
        targetSquare: .init(file: .d, rank: .five)
      )
    ])

    #expect(lhs == rhs)
  }

  @Test
  func testAmbiguousMoveErrorsWithDifferentCandidateOrderDoNotCompareEqual() {
    let translation = Translation(
      figure: .knight,
      targetSquare: .init(file: .f, rank: .three)
    )
    let capture = Capture(
      figure: .pawn,
      disambiguationFile: .e,
      targetSquare: .init(file: .d, rank: .five)
    )

    #expect(
      MoveError.ambiguousMove(candidates: [translation, capture])
        != MoveError.ambiguousMove(candidates: [capture, translation])
    )
  }

  @Test
  func testAmbiguousMoveErrorsWithDifferentCandidatesDoNotCompareEqual() {
    #expect(
      MoveError.ambiguousMove(candidates: [
        Translation(
          figure: .knight,
          targetSquare: .init(file: .f, rank: .three)
        )
      ])
        != MoveError.ambiguousMove(candidates: [
          Translation(
            figure: .knight,
            targetSquare: .init(file: .d, rank: .two)
          )
        ])
    )
  }
}
