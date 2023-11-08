import XCTest
@testable import ChessCore

final class ChessTests: XCTestCase {
  private var game = Game(board: [Position(file: .a, rank: .seven): Piece(color: .white, figure: .pawn)])

  func testPromotionToBishop() throws {
    try game.move("a8=B")
  }
  
  func testPromotionToKing() {
    XCTAssertThrowsError(try game.move("a8=K"))
  }

  func testPromotionToKnight() throws {
    try game.move("a8=N")
  }

  func testPromotionToRook() throws {
    try game.move("a8=R")
  }

  func testPromotionToQueen() throws {
    try game.move("a8=Q")
  }
}
