import XCTest
@testable import ChessCore

final class ChessTests: XCTestCase {
  func testFirstMoves() throws {
    for move in ["a3", "a4", "b3", "b4", "c3", "c4", "d3", "d4", "e3", "e4", "f3", "f4", "g3", "g4", "h3", "h4"] {
      var game = Game()
      try game.move(move)
      print(game)
    }

    for move in ["Na3", "Nc3", "Nf3", "Nh3"] {
      var game = Game()
      try game.move(move)
      print(game)
    }
  }

  func testScholarsMate() throws {
    var game = Game()
    try game.move("e4")
    try game.move("e5")
    try game.move("Qh5")
    try game.move("Nc6")
    try game.move("Bc4")
    try game.move("Nf6")
    try game.move("Qxf7#")
    print(game)
  }

  func testStalemate() throws {
    var game = Game(board: .init(pieces: [
      .init("e5")!: .init(color: .white, figure: .king),
      .init("e8")!: .init(color: .black, figure: .king),
      .init("e7")!: .init(color: .white, figure: .pawn)
    ]))
    try game.move("Ke6")
    print(game)
    XCTAssertTrue(game.isGameOver)
  }
}
