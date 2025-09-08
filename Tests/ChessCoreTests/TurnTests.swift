import Testing
@testable import ChessCore

struct TurnTests {
  @Test
  func testTurnDescriptionForEnd() {
    #expect(Turn.end(victor: .white).description == "1-0")
    #expect(Turn.end(victor: .black).description == "0-1")
    #expect(Turn.end(victor: nil).description == "1/2-1/2")
  }

  @Test
  func testTurnDescriptionForMove() {
    let move = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .four)
    ))
    #expect(Turn.move(move, punctuation: nil).description == "e4")
  }

  @Test
  func testTurnDescriptionForMoveWithPunctuation() {
    let move = Move.translation(.init(
      figure: .queen,
      targetSquare: .init(file: .h, rank: .five)
    ))
    #expect(Turn.move(move, punctuation: .check).description == "Qh5+")
    #expect(Turn.move(move, punctuation: .checkmate).description == "Qh5#")
  }

  @Test
  func testTurnPunctuationDescription() {
    #expect(Turn.Punctuation.check.description == "+")
    #expect(Turn.Punctuation.checkmate.description == "#")
  }
}
