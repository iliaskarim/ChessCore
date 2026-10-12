import Testing
@testable import ChessCore

private extension Board {
  func pieces(on ranks: Square.Rank...) -> [(key: Square, value: Piece)] {
    filter { square, _ in
      ranks.contains(square.rank)
    }
  }
}

private extension Move {
  static func translation(
    figure: Piece.Figure,
    square: Square,
    targetSquare: Square,
    promotion: Piece.Figure? = nil
  ) -> Self {
    .translation(.init(
      figure: figure,
      targetSquare: targetSquare,
      promotion: promotion,
      disambiguationFile: square.file,
      disambiguationRank: square.rank
    ))
  }
}

private extension Piece {
  static let blackBishop = Self(color: .black, figure: .bishop)
  static let blackKing = Self(color: .black, figure: .king)
  static let blackKnight = Self(color: .black, figure: .knight)
  static let blackRook = Self(color: .black, figure: .rook)
  static let whiteBishop = Self(color: .white, figure: .bishop)
  static let whiteKing = Self(color: .white, figure: .king)
  static let whiteKnight = Self(color: .white, figure: .knight)
  static let whiteRook = Self(color: .white, figure: .rook)
}

private extension Square {
  static let a1 = Self(file: .a, rank: .one)
  static let a3 = Self(file: .a, rank: .three)
  static let a8 = Self(file: .a, rank: .eight)
  static let b1 = Self(file: .b, rank: .one)
  static let c1 = Self(file: .c, rank: .one)
  static let c3 = Self(file: .c, rank: .three)
  static let c8 = Self(file: .c, rank: .eight)
  static let d1 = Self(file: .d, rank: .one)
  static let d2 = Self(file: .d, rank: .two)
  static let d7 = Self(file: .d, rank: .seven)
  static let d8 = Self(file: .d, rank: .eight)
  static let e1 = Self(file: .e, rank: .one)
  static let e2 = Self(file: .e, rank: .two)
  static let e7 = Self(file: .e, rank: .seven)
  static let e8 = Self(file: .e, rank: .eight)
  static let f1 = Self(file: .f, rank: .one)
  static let f2 = Self(file: .f, rank: .two)
  static let f3 = Self(file: .f, rank: .three)
  static let f7 = Self(file: .f, rank: .seven)
  static let f8 = Self(file: .f, rank: .eight)
  static let g1 = Self(file: .g, rank: .one)
  static let g8 = Self(file: .g, rank: .eight)
  static let h1 = Self(file: .h, rank: .one)
  static let h3 = Self(file: .h, rank: .three)
  static let h8 = Self(file: .h, rank: .eight)
}

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

  @Suite("Castling")
  struct Castling {
    @Test
    func blackMoves() {
      var board: Board = [
        .e8: .blackKing,
        .a8: .blackRook,
        .h8: .blackRook
      ]
      let dataSource = MockBoardDataSource(toMove: .black)
      board.dataSource = dataSource

      let kingsideCastle = Move.castling(.kingside)
      let queensideCastle = Move.castling(.queenside)
      let kd8 = Move.translation(figure: .king, square: .e8, targetSquare: .d8)
      let kf8 = Move.translation(figure: .king, square: .e8, targetSquare: .f8)
      let kd7 = Move.translation(figure: .king, square: .e8, targetSquare: .d7)
      let ke7 = Move.translation(figure: .king, square: .e8, targetSquare: .e7)
      let kf7 = Move.translation(figure: .king, square: .e8, targetSquare: .f7)

      let actualMoves = board.moves(from: .e8)
      #expect(actualMoves.count == 7)
      #expect(actualMoves[.g8] == [kingsideCastle])
      #expect(actualMoves[.c8] == [queensideCastle])
      #expect(actualMoves[.d8] == [kd8])
      #expect(actualMoves[.f8] == [kf8])
      #expect(actualMoves[.d7] == [kd7])
      #expect(actualMoves[.e7] == [ke7])
      #expect(actualMoves[.f7] == [kf7])
    }

    @Test
    func whiteMoves() {
      let board: Board = [
        .e1: .whiteKing,
        .a1: .whiteRook,
        .h1: .whiteRook
      ]

      let kingsideCastle = Move.castling(.kingside)
      let queensideCastle = Move.castling(.queenside)
      let kd1 = Move.translation(figure: .king, square: .e1, targetSquare: .d1)
      let kf1 = Move.translation(figure: .king, square: .e1, targetSquare: .f1)
      let kd2 = Move.translation(figure: .king, square: .e1, targetSquare: .d2)
      let ke2 = Move.translation(figure: .king, square: .e1, targetSquare: .e2)
      let kf2 = Move.translation(figure: .king, square: .e1, targetSquare: .f2)

      let actualMoves = board.moves(from: .e1)
      #expect(actualMoves.count == 7)
      #expect(actualMoves[.g1] == [kingsideCastle])
      #expect(actualMoves[.c1] == [queensideCastle])
      #expect(actualMoves[.d1] == [kd1])
      #expect(actualMoves[.f1] == [kf1])
      #expect(actualMoves[.d2] == [kd2])
      #expect(actualMoves[.e2] == [ke2])
      #expect(actualMoves[.f2] == [kf2])
    }
  }

  @Suite("Initial Position")
  struct InitialPosition {
    @Test
    func boardSetup() {
      let board = Board.board
      #expect(board.count == 32)

      let backRank: [Square.File: Piece.Figure] = [
        .a: .rook, .b: .knight, .c: .bishop, .d: .queen,
        .e: .king, .f: .bishop, .g: .knight, .h: .rook
      ]

      #expect(!board.pieces(on: .one, .two).map(\.value.color).contains(.black))
      #expect(!board.pieces(on: .seven, .eight).map(\.value.color).contains(.white))
      #expect(board.pieces(on: .one, .eight).allSatisfy { square, piece in
        piece.figure == backRank[square.file]
      })
      #expect(board.pieces(on: .two, .seven).map(\.value.figure).allSatisfy { figure in
        figure == .pawn
      })
      #expect(board.pieces(on: .three, .four, .five, .six).isEmpty)
    }

    @Test
    func knightMovesFromB1() {
      let na3 = Move.translation(figure: .knight, square: .b1, targetSquare: .a3)
      let nc3 = Move.translation(figure: .knight, square: .b1, targetSquare: .c3)

      let actualMoves = Board.board.moves(from: .b1)
      #expect(actualMoves.count == 2)
      #expect(actualMoves[.a3] == [na3])
      #expect(actualMoves[.c3] == [nc3])
    }

    @Test
    func knightMovesFromG1() {
      let nf3 = Move.translation(figure: .knight, square: .g1, targetSquare: .f3)
      let nh3 = Move.translation(figure: .knight, square: .g1, targetSquare: .h3)

      let actualMoves = Board.board.moves(from: .g1)
      #expect(actualMoves.count == 2)
      #expect(actualMoves[.f3] == [nf3])
      #expect(actualMoves[.h3] == [nh3])
    }

    @Test(arguments: Square.File.allCases)
    func pawnMoves(from file: Square.File) {
      let square = Square(file: file, rank: .two)
      let rankThree = Square(file: file, rank: .three)
      let rankFour = Square(file: file, rank: .four)
      let moveToRankThree = Move.translation(figure: .pawn, square: square, targetSquare: rankThree)
      let moveToRankFour = Move.translation(figure: .pawn, square: square, targetSquare: rankFour)

      let actualMoves = Board.board.moves(from: square)
      #expect(actualMoves.count == 2)
      #expect(actualMoves[rankThree] == [moveToRankThree])
      #expect(actualMoves[rankFour] == [moveToRankFour])
    }
  }

  @Suite("Promotion")
  struct Promotion {
    @Test(arguments: Piece.Color.allCases, Square.File.allCases)
    func moves(for color: Piece.Color, on file: Square.File) {
      let square = Square(file: file, rank: color == .white ? .seven : .two)
      let targetSquare = Square(file: file, rank: color == .white ? .eight : .one)
      var board: Board = [
        square: Piece(color: color, figure: .pawn)
      ]
      let dataSource = MockBoardDataSource(toMove: color)
      board.dataSource = dataSource

      #expect(Set(board.moves(from: square)[targetSquare] ?? []) == Set(
        [Piece.Figure.queen, .rook, .bishop, .knight].map { promotion in
          .translation(figure: .pawn, square: square, targetSquare: targetSquare, promotion: promotion)
        }
      ))
    }
  }
}
