import XCTest
@testable import Chess

final class ChessTests: XCTestCase {
  func testFoolsMate() {
    var game = Game()
    XCTAssertNoThrow(try game.move("f3"))
    XCTAssertNoThrow(try game.move("e6"))
    XCTAssertNoThrow(try game.move("g4"))
    XCTAssertNoThrow(try game.move("Qh4#"))
    XCTAssertEqual(game.victor, .white

    )
  }
}
