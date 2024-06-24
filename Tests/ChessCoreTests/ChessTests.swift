import XCTest
@testable import ChessCore

final class ChessTests: XCTestCase {
  private var game = Game(board: [.init(notation: "a7")!: .init(color: .white, figure: .pawn)])

  func testFirstMoves() throws {
    for move in ["a3", "a4", "b3", "b4", "c3", "c4", "d3", "d4", "e3", "e4", "f3", "f4", "g3", "g4", "h3", "h4"] {
      game = Game()
      try game.move(move)
    }

    for move in ["Na3", "Nc3", "Nf3", "Nh3"] {
      game = Game()
      try game.move(move)
    }
  }

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
    print(game)
  }
  
  func testKingsideCastle() throws {
    var game = Game(board: [
      .init(notation: "e1")!: .init(color: .white, figure: .king),
      .init(notation: "h1")!: .init(color: .white, figure: .rook),
    ])
    print(game)

    try game.move("O-O")
    print(game)
  }

  func testQueensideCastle() throws {
    var game = Game(board: [
      .init(notation: "e1")!: .init(color: .white, figure: .king),
      .init(notation: "a1")!: .init(color: .white, figure: .rook),
    ])
    print(game)

    try game.move("O-O-O")
    print(game)
  }

  func testMoveIntoCheck() throws {
    var game = Game(board: [
      .init(notation: "d6")!: .init(color: .black, figure: .queen),
      .init(notation: "f6")!: .init(color: .black, figure: .pawn),
      .init(notation: "e8")!: .init(color: .white, figure: .king),
      .init(notation: "a7")!: .init(color: .white, figure: .rook),
    ])
    print(game)

    XCTAssertThrowsError(try game.move("Ke7"))
    print(game)
  }

//  func testCaptureOutOfCheck1() throws {
//    var game = Game(board: [
//      .init(notation: "d6")!: .init(color: .white, figure: .queen),
//      .init(notation: "f6")!: .init(color: .white, figure: .pawn),
//      .init(notation: "e8")!: .init(color: .black, figure: .king),
////      .init(notation: "a7")!: .init(color: .black, figure: .rook),
//    ])
//    print(game)
//
//    try game.move("Qe7+")
//    print(game)
//  }
//
//  func testCaptureOutOfCheck2() throws {
//    var game = Game(board: [
//      "e5": .init(color: .white, figure: .queen),
//      "f5": .init(color: .white, figure: .pawn),
//      "a8": .init(color: .white, figure: .rook),
//      "e7": .init(color: .black, figure: .king),
//      "f7": .init(color: .black, figure: .pawn),
//    ])
//    print(game)
//
//    try game.move("Qe6")
//    print(game)
//  }
//
//  func testDisambiguation() throws {
//    var game = Game(board: [
//      "b3": .init(color: .white, figure: .knight),
//    ])
//    print(game)
//
//    try game.move("Nb3d4")
//    print(game)
//  }
//  
//  func testEnPassantCaptureOutOfCheck() throws {
//    var game = Game(board: [
//      "a1": .init(color: .white, figure: .king),
//      "f2": .init(color: .white, figure: .pawn),
//      "e5": .init(color: .black, figure: .king),
//      "g4": .init(color: .black, figure: .pawn),
//      "a4": .init(color: .white, figure: .rook),
//      "a6": .init(color: .white, figure: .rook),
//      "d1": .init(color: .white, figure: .rook),
//      "f8": .init(color: .white, figure: .rook),
//    ])
//    print(game)
//
//    try game.move("f4")
//    print(game)
//
//    try game.move("gxf3")
//    print(game)
//  }
}
