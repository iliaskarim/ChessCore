import Testing
@testable import ChessCore

struct BoardTests {
  private class MockBoardDataSource: BoardDataSource {
    let toMove: Piece.Color

    func hasPieceMoved(_ _: Piece, from _: Square) -> Bool {
      false
    }

    init(toMove: Piece.Color = .white) {
      self.toMove = toMove
    }
  }

  @Test
  func dataSourceIsWeaklyHeld() {
    var board = Board.board
    var dataSource: BoardDataSource? = MockBoardDataSource()

    board.dataSource = dataSource
    #expect(board.dataSource != nil)

    dataSource = nil
    #expect(board.dataSource == nil)
  }

  // MARK: - Castling

  @Test
  func blackCastlingMoves() {
    var board: Board = [
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .a, rank: .eight): .init(color: .black, figure: .rook),
      .init(file: .h, rank: .eight): .init(color: .black, figure: .rook)
    ]
    let dataSource = MockBoardDataSource(toMove: .black)
    board.dataSource = dataSource

    let kingsideCastle = Move.castling(.kingside)
    let queensideCastle = Move.castling(.queenside)
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

    let actualMoves = board.moves(from: .init(file: .e, rank: .eight))
    #expect(actualMoves.count == 7)

    let actualMovesToG8 = actualMoves[.init(file: .g, rank: .eight)]
    #expect(actualMovesToG8 == [kingsideCastle])

    let actualMovesToC8 = actualMoves[.init(file: .c, rank: .eight)]
    #expect(actualMovesToC8 == [queensideCastle])

    let actualMovesToD8 = actualMoves[.init(file: .d, rank: .eight)]
    #expect(actualMovesToD8 == [kd8])

    let actualMovesToF8 = actualMoves[.init(file: .f, rank: .eight)]
    #expect(actualMovesToF8 == [kf8])

    let actualMovesToD7 = actualMoves[.init(file: .d, rank: .seven)]
    #expect(actualMovesToD7 == [kd7])

    let actualMovesToE7 = actualMoves[.init(file: .e, rank: .seven)]
    #expect(actualMovesToE7 == [ke7])

    let actualMovesToF7 = actualMoves[.init(file: .f, rank: .seven)]
    #expect(actualMovesToF7 == [kf7])
  }

  @Test
  func whiteCastlingMoves() {
    let board: Board = [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook)
    ]

    let kingsideCastle = Move.castling(.kingside)
    let queensideCastle = Move.castling(.queenside)
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

    let actualMoves = board.moves(from: .init(file: .e, rank: .one))
    #expect(actualMoves.count == 7)

    let actualMovesToG1 = actualMoves[.init(file: .g, rank: .one)]
    #expect(actualMovesToG1 == [kingsideCastle])

    let actualMovesToC1 = actualMoves[.init(file: .c, rank: .one)]
    #expect(actualMovesToC1 == [queensideCastle])

    let actualMovesToD1 = actualMoves[.init(file: .d, rank: .one)]
    #expect(actualMovesToD1 == [kd1])

    let actualMovesToF1 = actualMoves[.init(file: .f, rank: .one)]
    #expect(actualMovesToF1 == [kf1])

    let actualMovesToD2 = actualMoves[.init(file: .d, rank: .two)]
    #expect(actualMovesToD2 == [kd2])

    let actualMovesToE2 = actualMoves[.init(file: .e, rank: .two)]
    #expect(actualMovesToE2 == [ke2])

    let actualMovesToF2 = actualMoves[.init(file: .f, rank: .two)]
    #expect(actualMovesToF2 == [kf2])
  }

  // MARK: - Initial Position

  @Test
  func initialBoardSetup() throws {
    let board = Board.board
    #expect(board.count == 32)

    let backRank: [Square.File: Piece.Figure] = [
      .a: .rook, .b: .knight, .c: .bishop, .d: .queen,
      .e: .king, .f: .bishop, .g: .knight, .h: .rook
    ]

    for file in Square.File.allCases {
      #expect(try board[.init(file: file, rank: .one)] == .init(
        color: .white,
        figure: #require(backRank[file])
      ))

      #expect(board[.init(file: file, rank: .two)] == .init(
        color: .white,
        figure: .pawn
      ))

      for rank in [Square.Rank.three, .four, .five, .six] {
        #expect(board[.init(file: file, rank: rank)] == nil)
      }

      #expect(board[.init(file: file, rank: .seven)] == .init(
        color: .black,
        figure: .pawn
      ))

      #expect(try board[.init(file: file, rank: .eight)] == .init(
        color: .black,
        figure: #require(backRank[file])
      ))
    }
  }

  @Test
  func initialKnightMovesFromB1() {
    let na3 = Move.translation(.init(
      figure: .knight,
      targetSquare: .init(file: .a, rank: .three),
      disambiguationFile: .b,
      disambiguationRank: .one
    ))

    let nc3 = Move.translation(.init(
      figure: .knight,
      targetSquare: .init(file: .c, rank: .three),
      disambiguationFile: .b,
      disambiguationRank: .one
    ))

    let actualMoves = Board.board.moves(from: .init(file: .b, rank: .one))
    #expect(actualMoves.count == 2)

    let actualMovesToA3 = actualMoves[.init(file: .a, rank: .three)]
    #expect(actualMovesToA3 == [na3])

    let actualMovesToC3 = actualMoves[.init(file: .c, rank: .three)]
    #expect(actualMovesToC3 == [nc3])
  }

  @Test
  func initialKnightMovesFromG1() {
    let nf3 = Move.translation(.init(
      figure: .knight,
      targetSquare: .init(file: .f, rank: .three),
      disambiguationFile: .g,
      disambiguationRank: .one
    ))

    let nh3 = Move.translation(.init(
      figure: .knight,
      targetSquare: .init(file: .h, rank: .three),
      disambiguationFile: .g,
      disambiguationRank: .one
    ))

    let actualMoves = Board.board.moves(from: .init(file: .g, rank: .one))
    #expect(actualMoves.count == 2)

    let actualMovesToF3 = actualMoves[.init(file: .f, rank: .three)]
    #expect(actualMovesToF3 == [nf3])

    let actualMovesToH3 = actualMoves[.init(file: .h, rank: .three)]
    #expect(actualMovesToH3 == [nh3])
  }

  @Test
  func initialPawnMoves() {
    for file in Square.File.allCases {
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

      let actualMoves = Board.board.moves(from: .init(file: file, rank: .two))
      #expect(actualMoves.count == 2)

      let actualMovesToRankThree = actualMoves[.init(file: file, rank: .three)]
      #expect(actualMovesToRankThree == [expectedMoveToRankThree])

      let actualMovesToRankFour = actualMoves[.init(file: file, rank: .four)]
      #expect(actualMovesToRankFour == [expectedMoveToRankFour])
    }
  }

  // MARK: - Promotion

  @Test
  func blackPromotionMoves() {
    var board: Board = [
      .init(file: .e, rank: .two): .init(color: .black, figure: .pawn)
    ]
    let dataSource = MockBoardDataSource(toMove: .black)
    board.dataSource = dataSource

    let expectedMovesToE1 = [Piece.Figure.queen, .rook, .bishop, .knight].map { promotion in
      Move.translation(.init(
        figure: .pawn,
        targetSquare: .init(file: .e, rank: .one),
        promotion: promotion,
        disambiguationFile: .e,
        disambiguationRank: .two
      ))
    }

    let actualMoves = board.moves(from: .init(file: .e, rank: .two))
    let actualMovesToE1 = actualMoves[.init(file: .e, rank: .one)]

    #expect(Set(actualMovesToE1 ?? []) == Set(expectedMovesToE1))
  }

  @Test
  func whitePromotionMoves() {
    let board: Board = [
      .init(file: .e, rank: .seven): .init(color: .white, figure: .pawn)
    ]

    let expectedMovesToE8 = [Piece.Figure.queen, .rook, .bishop, .knight].map { promotion in
      Move.translation(.init(
        figure: .pawn,
        targetSquare: .init(file: .e, rank: .eight),
        promotion: promotion,
        disambiguationFile: .e,
        disambiguationRank: .seven
      ))
    }

    let actualMoves = board.moves(from: .init(file: .e, rank: .seven))
    let actualMovesToE8 = actualMoves[.init(file: .e, rank: .eight)]

    #expect(Set(actualMovesToE8 ?? []) == Set(expectedMovesToE8))
  }
}
