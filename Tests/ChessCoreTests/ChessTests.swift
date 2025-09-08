import XCTest
@testable import ChessCore

final class ChessTests: XCTestCase {
 func testFirstMoves() throws {
   let game = Game()
   #expect([.init(notation: "a3")!, .init(notation: "c3")!].allSatisfy(game.board.moves(from: .init(notation: "b1")!).contains))
   #expect([.init(notation: "f3")!, .init(notation: "h3")!].allSatisfy(game.board.moves(from: .init(notation: "g1")!).contains))
   
   for file in Square.File.allCases {
      #expect([
        .init(file: file, rank: .three),
        .init(file: file, rank: .four)
      ].allSatisfy(game.board.moves(from: .init(file: file, rank: .two)).contains))
    }
  }

  func testScholarsMate() throws {
    var game = Game()
    try game.move(notation: "e4")
    try game.move(notation: "e5")
    try game.move(notation: "Qh5")
    try game.move(notation: "Nc6")
    try game.move(notation: "Bc4")
    try game.move(notation: "Nf6")
    try game.move(notation: "Qxf7#")
    print(game)
    #expect(game.isGameOver)
  }

  func testStalemate() throws {
    var game = Game(board: .init(pieces: [
      .init(notation: "e5")!: .init(color: .white, figure: .king),
      .init(notation: "e8")!: .init(color: .black, figure: .king),
      .init(notation: "e7")!: .init(color: .white, figure: .pawn)
    ]))
    try game.move(notation: "Ke6")
    print(game)
    XCTAssertTrue(game.isGameOver)
  }
}
