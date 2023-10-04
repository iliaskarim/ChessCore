import XCTest
@testable import ChessCore

final class ChessTests: XCTestCase {
  private var game = Game(board: [Square(file: .a, rank: .seven): Piece(color: .white, figure: .pawn)])

  func testPromotionToBishop() throws {
    print(game)
    try game.move("a8B")
    print(game)
  }

  func testPromotionToKnight() throws {
    print(game)
    try game.move("a8N")
    print(game)
  }

  func testPromotionToRook() throws {
    print(game)
    try game.move("a8R")
    print(game)
  }

  func testPromotionToQueen() throws {
    print(game)
    try game.move("a8Q")
    print(game)
  }
}
