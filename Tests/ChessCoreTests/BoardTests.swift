import Testing
@testable import ChessCore

struct BoardTests {
  private class MockBoardDataSource: BoardDataSource {
    let toMove: Piece.Color

    private let onDeinit: () -> Void

    func hasPieceMoved(_ _: Piece, from _: Square) -> Bool {
      false
    }

    init(toMove: Piece.Color = .white, onDeinit: @escaping (() -> Void) = {}) {
      self.toMove = toMove
      self.onDeinit = onDeinit
    }

    deinit {
      onDeinit()
    }
  }

  @Test
  func testBoardStatusDescription() {
    #expect(Board.Status.check.description == "Check")
    #expect(Board.Status.checkmate.description == "Checkmate")
    #expect(Board.Status.stalemate.description == "Stalemate")
  }

  @Test
  func testDataSourceDeinitCalled() {
    var board = Board.board
    var deinitCalled = false
    var dataSource: BoardDataSource? = MockBoardDataSource {
      deinitCalled = true
    }
    board.dataSource = dataSource
    dataSource = nil

    #expect(deinitCalled)
  }

  // MARK: - Castling

  @Test
  func testBlackCastleMoves() {
    var board: Board = [
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .a, rank: .eight): .init(color: .black, figure: .rook),
      .init(file: .h, rank: .eight): .init(color: .black, figure: .rook)
    ]
    let dataSource = MockBoardDataSource(toMove: .black)
    board.dataSource = dataSource

    let kingsideCastle = Move.castle(.short)
    let queensideCastle = Move.castle(.long)
    let kd8 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .d, rank: .eight),
      disambiguationFile: .e,
      disambiguationRank: .eight
    ))
    let kf8 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .f, rank: .eight),
      disambiguationFile: .e,
      disambiguationRank: .eight
    ))
    let kd7 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .d, rank: .seven),
      disambiguationFile: .e,
      disambiguationRank: .eight
    ))
    let ke7 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .e, rank: .seven),
      disambiguationFile: .e,
      disambiguationRank: .eight
    ))
    let kf7 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .f, rank: .seven),
      disambiguationFile: .e,
      disambiguationRank: .eight
    ))

    let actualMovesFromE8 = board.moves(from: .init(file: .e, rank: .eight))
    #expect(actualMovesFromE8.count == 7)

    #expect(actualMovesFromE8[.init(file: .g, rank: .eight)] != nil)
    #expect(actualMovesFromE8[.init(file: .c, rank: .eight)] != nil)
    #expect(actualMovesFromE8[.init(file: .d, rank: .eight)] != nil)
    #expect(actualMovesFromE8[.init(file: .f, rank: .eight)] != nil)
    #expect(actualMovesFromE8[.init(file: .d, rank: .seven)] != nil)
    #expect(actualMovesFromE8[.init(file: .e, rank: .seven)] != nil)
    #expect(actualMovesFromE8[.init(file: .f, rank: .seven)] != nil)

    let actualMovesFromE8ToG8 = actualMovesFromE8[.init(file: .g, rank: .eight)]!
    let actualMovesFromE8ToC8 = actualMovesFromE8[.init(file: .c, rank: .eight)]!
    let actualMovesFromE8ToD8 = actualMovesFromE8[.init(file: .d, rank: .eight)]!
    let actualMovesFromE8ToF8 = actualMovesFromE8[.init(file: .f, rank: .eight)]!
    let actualMovesFromE8ToD7 = actualMovesFromE8[.init(file: .d, rank: .seven)]!
    let actualMovesFromE8ToE7 = actualMovesFromE8[.init(file: .e, rank: .seven)]!
    let actualMovesFromE8ToF7 = actualMovesFromE8[.init(file: .f, rank: .seven)]!

    #expect(actualMovesFromE8ToG8 == [kingsideCastle])
    #expect(actualMovesFromE8ToC8 == [queensideCastle])
    #expect(actualMovesFromE8ToD8 == [kd8])
    #expect(actualMovesFromE8ToF8 == [kf8])
    #expect(actualMovesFromE8ToD7 == [kd7])
    #expect(actualMovesFromE8ToE7 == [ke7])
    #expect(actualMovesFromE8ToF7 == [kf7])
  }

  @Test
  func testWhiteCastleMoves() {
    let board: Board = [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook)
    ]

    let kingsideCastle = Move.castle(.short)
    let queensideCastle = Move.castle(.long)
    let kd1 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .d, rank: .one),
      disambiguationFile: .e,
      disambiguationRank: .one
    ))
    let kf1 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .f, rank: .one),
      disambiguationFile: .e,
      disambiguationRank: .one
    ))
    let kd2 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .d, rank: .two),
      disambiguationFile: .e,
      disambiguationRank: .one
    ))
    let ke2 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .e, rank: .two),
      disambiguationFile: .e,
      disambiguationRank: .one
    ))
    let kf2 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .f, rank: .two),
      disambiguationFile: .e,
      disambiguationRank: .one
    ))

    let actualMovesFromE1 = board.moves(from: .init(file: .e, rank: .one))
    #expect(actualMovesFromE1.count == 7)

    #expect(actualMovesFromE1[.init(file: .g, rank: .one)] != nil)
    #expect(actualMovesFromE1[.init(file: .c, rank: .one)] != nil)
    #expect(actualMovesFromE1[.init(file: .d, rank: .one)] != nil)
    #expect(actualMovesFromE1[.init(file: .f, rank: .one)] != nil)
    #expect(actualMovesFromE1[.init(file: .d, rank: .two)] != nil)
    #expect(actualMovesFromE1[.init(file: .e, rank: .two)] != nil)
    #expect(actualMovesFromE1[.init(file: .f, rank: .two)] != nil)

    let actualMovesFromE1ToG1 = actualMovesFromE1[.init(file: .g, rank: .one)]!
    let actualMovesFromE1ToC1 = actualMovesFromE1[.init(file: .c, rank: .one)]!
    let actualMovesFromE1ToD1 = actualMovesFromE1[.init(file: .d, rank: .one)]!
    let actualMovesFromE1ToF1 = actualMovesFromE1[.init(file: .f, rank: .one)]!
    let actualMovesFromE1ToD2 = actualMovesFromE1[.init(file: .d, rank: .two)]!
    let actualMovesFromE1ToE2 = actualMovesFromE1[.init(file: .e, rank: .two)]!
    let actualMovesFromE1ToF2 = actualMovesFromE1[.init(file: .f, rank: .two)]!

    #expect(actualMovesFromE1ToG1 == [kingsideCastle])
    #expect(actualMovesFromE1ToC1 == [queensideCastle])
    #expect(actualMovesFromE1ToD1 == [kd1])
    #expect(actualMovesFromE1ToF1 == [kf1])
    #expect(actualMovesFromE1ToD2 == [kd2])
    #expect(actualMovesFromE1ToE2 == [ke2])
    #expect(actualMovesFromE1ToF2 == [kf2])
  }

  // MARK: - Initial position

  @Test
  func testInitialBoardSetup() {
    let board = Board.board
    #expect(board.count == 32)

    let backRank: [Square.File: Piece.Figure] = [
      .a: .rook, .b: .knight, .c: .bishop, .d: .queen,
      .e: .king, .f: .bishop, .g: .knight, .h: .rook
    ]

    for file in Square.File.allCases {
      #expect(board[.init(file: file, rank: .one)] == .init(
        color: .white,
        figure: backRank[file]!
      ))
      #expect(board[.init(file: file, rank: .two)] == .init(
        color: .white,
        figure: .pawn
      ))
      #expect(board[.init(file: file, rank: .seven)] == .init(
        color: .black,
        figure: .pawn
      ))
      #expect(board[.init(file: file, rank: .eight)] == .init(
        color: .black,
        figure: backRank[file]!
      ))
    }

    for square in [Square.Rank.three, .four, .five, .six].flatMap({ rank in
      Square.File.allCases.map { file in
        Square(file: file, rank: rank)
      }
    }) {
      #expect(board[square] == nil)
    }
  }

  @Test
  func testInitialKnightMovesFromB1() {
    let nA3 = Move.translation(.init(
      figure: .knight,
      targetSquare: .init(file: .a, rank: .three),
      disambiguationFile: .b,
      disambiguationRank: .one
    ))

    let nC3 = Move.translation(.init(
      figure: .knight,
      targetSquare: .init(file: .c, rank: .three),
      disambiguationFile: .b,
      disambiguationRank: .one
    ))

    let actualMovesFromB1 = Board.board.moves(from: .init(file: .b, rank: .one))
    #expect(actualMovesFromB1.count == 2)

    let actualMovesFromB1ToA3 = actualMovesFromB1[.init(file: .a, rank: .three)]
    let actualMovesFromB1ToC3 = actualMovesFromB1[.init(file: .c, rank: .three)]

    #expect(actualMovesFromB1ToA3 == [nA3])
    #expect(actualMovesFromB1ToC3 == [nC3])
  }

  @Test
  func testInitialKnightMovesFromG1() {
    let nF3 = Move.translation(.init(
      figure: .knight,
      targetSquare: .init(file: .f, rank: .three),
      disambiguationFile: .g,
      disambiguationRank: .one
    ))

    let nH3 = Move.translation(.init(
      figure: .knight,
      targetSquare: .init(file: .h, rank: .three),
      disambiguationFile: .g,
      disambiguationRank: .one
    ))

    let actualMovesFromG1 = Board.board.moves(from: .init(file: .g, rank: .one))
    #expect(actualMovesFromG1.count == 2)

    let actualMovesFromG1ToF3 = actualMovesFromG1[.init(file: .f, rank: .three)]
    let actualMovesFromG1ToH3 = actualMovesFromG1[.init(file: .h, rank: .three)]

    #expect(actualMovesFromG1ToF3 == [nF3])
    #expect(actualMovesFromG1ToH3 == [nH3])
  }

  @Test
  func testInitialPawnMoves() {
    Square.File.allCases.forEach { file in
      let expectedMoveToRankThree = Move.translation(.init(
        figure: .pawn,
        targetSquare: .init(file: file, rank: .three),
        disambiguationFile: file,
        disambiguationRank: .two
      ))

      let expectedMoveToRankFour = Move.translation(.init(
        figure: .pawn,
        targetSquare: .init(file: file, rank: .four),
        disambiguationFile: file,
        disambiguationRank: .two
      ))

      let actualMovesFrom = Board.board.moves(from: .init(file: file, rank: .two))
      #expect(actualMovesFrom.count == 2)

      let actualMovesFromToRankThree = actualMovesFrom[.init(file: file, rank: .three)]
      let actualMovesFromToRankFour = actualMovesFrom[.init(file: file, rank: .four)]

      #expect(actualMovesFromToRankFour == [expectedMoveToRankFour])
      #expect(actualMovesFromToRankThree == [expectedMoveToRankThree])
    }
  }

  // MARK: - Promotion

  @Test
  func testBlackPromotionMoves() {
    var board: Board = [
      .init(file: .e, rank: .two): .init(color: .black, figure: .pawn)
    ]
    let dataSource = MockBoardDataSource(toMove: .black)
    board.dataSource = dataSource

    let e1QueenPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .one),
      promotion: .queen,
      disambiguationFile: .e,
      disambiguationRank: .two
    ))
    let e1RookPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .one),
      promotion: .rook,
      disambiguationFile: .e,
      disambiguationRank: .two
    ))
    let e1BishopPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .one),
      promotion: .bishop,
      disambiguationFile: .e,
      disambiguationRank: .two
    ))
    let e1KnightPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .one),
      promotion: .knight,
      disambiguationFile: .e,
      disambiguationRank: .two
    ))

    let actualMovesFromE2 = board.moves(from: .init(file: .e, rank: .two))

    #expect(actualMovesFromE2[.init(file: .e, rank: .one)] != nil)
    let actualMovesFromE2ToE1 = actualMovesFromE2[.init(file: .e, rank: .one)]!

    #expect(Set(actualMovesFromE2ToE1) == Set([
      e1QueenPromotion, e1RookPromotion, e1BishopPromotion, e1KnightPromotion
    ]))
  }

  @Test
  func testWhitePromotionMoves() {
    let board: Board = [
      .init(file: .e, rank: .seven): .init(color: .white, figure: .pawn)
    ]

    let e8QueenPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .eight),
      promotion: .queen,
      disambiguationFile: .e,
      disambiguationRank: .seven
    ))
    let e8RookPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .eight),
      promotion: .rook,
      disambiguationFile: .e,
      disambiguationRank: .seven
    ))
    let e8BishopPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .eight),
      promotion: .bishop,
      disambiguationFile: .e,
      disambiguationRank: .seven
    ))
    let e8KnightPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .e, rank: .eight),
      promotion: .knight,
      disambiguationFile: .e,
      disambiguationRank: .seven
    ))

    let actualMovesFromE7 = board.moves(from: .init(file: .e, rank: .seven))

    #expect(actualMovesFromE7[.init(file: .e, rank: .eight)] != nil)
    let actualMovesFromE7ToE8 = actualMovesFromE7[.init(file: .e, rank: .eight)]!

    #expect(Set(actualMovesFromE7ToE8) == Set([
      e8QueenPromotion, e8RookPromotion, e8BishopPromotion, e8KnightPromotion
    ]))
  }
}
