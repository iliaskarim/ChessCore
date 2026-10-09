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

    let kingsideCastle = Castle.short
    let queensideCastle = Castle.long
    let kd8 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .eight,
      targetSquare: .init(file: .d, rank: .eight)
    )
    let kf8 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .eight,
      targetSquare: .init(file: .f, rank: .eight)
    )
    let kd7 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .eight,
      targetSquare: .init(file: .d, rank: .seven)
    )
    let ke7 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .eight,
      targetSquare: .init(file: .e, rank: .seven)
    )
    let kf7 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .eight,
      targetSquare: .init(file: .f, rank: .seven)
    )

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

    #expect(actualMovesFromE8ToG8.map(AnyMove.init) == [AnyMove(kingsideCastle)])
    #expect(actualMovesFromE8ToC8.map(AnyMove.init) == [AnyMove(queensideCastle)])
    #expect(actualMovesFromE8ToD8.map(AnyMove.init) == [AnyMove(kd8)])
    #expect(actualMovesFromE8ToF8.map(AnyMove.init) == [AnyMove(kf8)])
    #expect(actualMovesFromE8ToD7.map(AnyMove.init) == [AnyMove(kd7)])
    #expect(actualMovesFromE8ToE7.map(AnyMove.init) == [AnyMove(ke7)])
    #expect(actualMovesFromE8ToF7.map(AnyMove.init) == [AnyMove(kf7)])
  }

  @Test
  func testWhiteCastleMoves() {
    let board: Board = [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook)
    ]

    let kingsideCastle = Castle.short
    let queensideCastle = Castle.long
    let kd1 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .one,
      targetSquare: .init(file: .d, rank: .one)
    )
    let kf1 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .one,
      targetSquare: .init(file: .f, rank: .one)
    )
    let kd2 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .one,
      targetSquare: .init(file: .d, rank: .two)
    )
    let ke2 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .one,
      targetSquare: .init(file: .e, rank: .two)
    )
    let kf2 = Translation(
      figure: .king,
      disambiguationFile: .e,
      disambiguationRank: .one,
      targetSquare: .init(file: .f, rank: .two)
    )

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

    #expect(actualMovesFromE1ToG1.map(AnyMove.init) == [AnyMove(kingsideCastle)])
    #expect(actualMovesFromE1ToC1.map(AnyMove.init) == [AnyMove(queensideCastle)])
    #expect(actualMovesFromE1ToD1.map(AnyMove.init) == [AnyMove(kd1)])
    #expect(actualMovesFromE1ToF1.map(AnyMove.init) == [AnyMove(kf1)])
    #expect(actualMovesFromE1ToD2.map(AnyMove.init) == [AnyMove(kd2)])
    #expect(actualMovesFromE1ToE2.map(AnyMove.init) == [AnyMove(ke2)])
    #expect(actualMovesFromE1ToF2.map(AnyMove.init) == [AnyMove(kf2)])
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
    let nA3 = Translation(
      figure: .knight,
      disambiguationFile: .b,
      disambiguationRank: .one,
      targetSquare: .init(file: .a, rank: .three)
    )

    let nC3 = Translation(
      figure: .knight,
      disambiguationFile: .b,
      disambiguationRank: .one,
      targetSquare: .init(file: .c, rank: .three)
    )

    let actualMovesFromB1 = Board.board.moves(from: .init(file: .b, rank: .one))
    #expect(actualMovesFromB1.count == 2)

    let actualMovesFromB1ToA3 = actualMovesFromB1[.init(file: .a, rank: .three)]
    let actualMovesFromB1ToC3 = actualMovesFromB1[.init(file: .c, rank: .three)]

    #expect(actualMovesFromB1ToA3!.map(AnyMove.init) == [AnyMove(nA3)])
    #expect(actualMovesFromB1ToC3!.map(AnyMove.init) == [AnyMove(nC3)])
  }

  @Test
  func testInitialKnightMovesFromG1() {
    let nF3 = Translation(
      figure: .knight,
      disambiguationFile: .g,
      disambiguationRank: .one,
      targetSquare: .init(file: .f, rank: .three)
    )

    let nH3 = Translation(
      figure: .knight,
      disambiguationFile: .g,
      disambiguationRank: .one,
      targetSquare: .init(file: .h, rank: .three)
    )

    let actualMovesFromG1 = Board.board.moves(from: .init(file: .g, rank: .one))
    #expect(actualMovesFromG1.count == 2)

    let actualMovesFromG1ToF3 = actualMovesFromG1[.init(file: .f, rank: .three)]
    let actualMovesFromG1ToH3 = actualMovesFromG1[.init(file: .h, rank: .three)]

    #expect(actualMovesFromG1ToF3!.map(AnyMove.init) == [AnyMove(nF3)])
    #expect(actualMovesFromG1ToH3!.map(AnyMove.init) == [AnyMove(nH3)])
  }

  @Test
  func testInitialPawnMoves() {
    Square.File.allCases.forEach { file in
      let expectedMoveToRankThree = Translation(
        figure: .pawn,
        disambiguationFile: file,
        disambiguationRank: .two,
        targetSquare: .init(file: file, rank: .three)
      )

      let expectedMoveToRankFour = Translation(
        figure: .pawn,
        disambiguationFile: file,
        disambiguationRank: .two,
        targetSquare: .init(file: file, rank: .four)
      )

      let actualMovesFrom = Board.board.moves(from: .init(file: file, rank: .two))
      #expect(actualMovesFrom.count == 2)

      let actualMovesFromToRankThree = actualMovesFrom[.init(file: file, rank: .three)]
      let actualMovesFromToRankFour = actualMovesFrom[.init(file: file, rank: .four)]

      #expect(actualMovesFromToRankFour!.map(AnyMove.init) == [AnyMove(expectedMoveToRankFour)])
      #expect(actualMovesFromToRankThree!.map(AnyMove.init) == [AnyMove(expectedMoveToRankThree)])
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

    let e1QueenPromotion = Promotion.translation(Translation(
      figure: .pawn,
      disambiguationFile: .e,
      disambiguationRank: .two,
      targetSquare: .init(file: .e, rank: .one)
    ), to: .queen)
    let e1RookPromotion = Promotion.translation(Translation(
      figure: .pawn,
      disambiguationFile: .e,
      disambiguationRank: .two,
      targetSquare: .init(file: .e, rank: .one)
    ), to: .rook)
    let e1BishopPromotion = Promotion.translation(Translation(
      figure: .pawn,
      disambiguationFile: .e,
      disambiguationRank: .two,
      targetSquare: .init(file: .e, rank: .one)
    ), to: .bishop)
    let e1KnightPromotion = Promotion.translation(Translation(
      figure: .pawn,
      disambiguationFile: .e,
      disambiguationRank: .two,
      targetSquare: .init(file: .e, rank: .one)
    ), to: .knight)

    let actualMovesFromE2 = board.moves(from: .init(file: .e, rank: .two))

    #expect(actualMovesFromE2[.init(file: .e, rank: .one)] != nil)
    let actualMovesFromE2ToE1 = actualMovesFromE2[.init(file: .e, rank: .one)]!

    #expect(Set(actualMovesFromE2ToE1.map(AnyMove.init)) == Set([
      e1QueenPromotion, e1RookPromotion, e1BishopPromotion, e1KnightPromotion
    ].map(AnyMove.init)))
  }

  @Test
  func testWhitePromotionMoves() {
    let board: Board = [
      .init(file: .e, rank: .seven): .init(color: .white, figure: .pawn)
    ]

    let e8QueenPromotion = Promotion.translation(Translation(
      figure: .pawn,
      disambiguationFile: .e,
      disambiguationRank: .seven,
      targetSquare: .init(file: .e, rank: .eight)
    ), to: .queen)
    let e8RookPromotion = Promotion.translation(Translation(
      figure: .pawn,
      disambiguationFile: .e,
      disambiguationRank: .seven,
      targetSquare: .init(file: .e, rank: .eight)
    ), to: .rook)
    let e8BishopPromotion = Promotion.translation(Translation(
      figure: .pawn,
      disambiguationFile: .e,
      disambiguationRank: .seven,
      targetSquare: .init(file: .e, rank: .eight)
    ), to: .bishop)
    let e8KnightPromotion = Promotion.translation(Translation(
      figure: .pawn,
      disambiguationFile: .e,
      disambiguationRank: .seven,
      targetSquare: .init(file: .e, rank: .eight)
    ), to: .knight)

    let actualMovesFromE7 = board.moves(from: .init(file: .e, rank: .seven))

    #expect(actualMovesFromE7[.init(file: .e, rank: .eight)] != nil)
    let actualMovesFromE7ToE8 = actualMovesFromE7[.init(file: .e, rank: .eight)]!

    #expect(Set(actualMovesFromE7ToE8.map(AnyMove.init)) == Set([
      e8QueenPromotion, e8RookPromotion, e8BishopPromotion, e8KnightPromotion
    ].map(AnyMove.init)))
  }
}
