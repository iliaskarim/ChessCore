import XCTest
@testable import ChessCore

final class ChessTests: XCTestCase {
  func testPromotion() throws {
    var game = Game(board: [Square(file: .a, rank: .seven): Piece(color: .white, figure: .pawn)])
    print(game)
    try game.move("a8Q")
    print(game)
  }
}
