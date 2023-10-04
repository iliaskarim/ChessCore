import XCTest
@testable import ChessCore

final class ChessTests: XCTestCase {
  private var game = Game(board: [Square(file: .a, rank: .seven): Piece(color: .white, figure: .pawn)])

  func testPromotionToBishop() throws {
    try game.move("a8B")
  }
  
  func testPromotionToKing() {
    XCTAssertThrowsError(try game.move("a8K"))
  }

  func testPromotionToKnight() throws {
    try game.move("a8N")
  }

  func testPromotionToRook() throws {
    try game.move("a8R")
  }

  func testPromotionToQueen() throws {
    try game.move("a8Q")
  }
}
