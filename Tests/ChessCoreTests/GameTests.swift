import Testing
@testable import ChessCore

private extension Piece {
  static let blackKing = Self(color: .black, figure: .king)
  static let blackPawn = Self(color: .black, figure: .pawn)
  static let blackRook = Self(color: .black, figure: .rook)
  static let whiteKing = Self(color: .white, figure: .king)
  static let whiteKnight = Self(color: .white, figure: .knight)
  static let whitePawn = Self(color: .white, figure: .pawn)
  static let whiteRook = Self(color: .white, figure: .rook)
}

private extension Square {
  static let a1 = Self(file: .a, rank: .one)
  static let c1 = Self(file: .c, rank: .one)
  static let d1 = Self(file: .d, rank: .one)
  static let d2 = Self(file: .d, rank: .two)
  static let d3 = Self(file: .d, rank: .three)
  static let d4 = Self(file: .d, rank: .four)
  static let d8 = Self(file: .d, rank: .eight)
  static let e1 = Self(file: .e, rank: .one)
  static let e2 = Self(file: .e, rank: .two)
  static let e4 = Self(file: .e, rank: .four)
  static let e5 = Self(file: .e, rank: .five)
  static let e7 = Self(file: .e, rank: .seven)
  static let e8 = Self(file: .e, rank: .eight)
  static let f1 = Self(file: .f, rank: .one)
  static let g1 = Self(file: .g, rank: .one)
  static let g7 = Self(file: .g, rank: .seven)
  static let g8 = Self(file: .g, rank: .eight)
  static let h1 = Self(file: .h, rank: .one)
  static let h8 = Self(file: .h, rank: .eight)
}

enum GameTests {
  @Suite("Castling")
  struct Castling {
    @Test(arguments: [Square.File.a, .b, .h], Move.Castling.allCases)
    func bothSidesAreLegalWhenFileIsAttacked(on file: Square.File, side: Move.Castling) throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .a1: .whiteRook,
        .h1: .whiteRook,
        .e8: .blackKing,
        Square(file: file, rank: .eight): .blackRook
      ])

      try game.play(.castling(side))
      expectCastled(side, in: game)
    }

    @Test
    func isIllegalAfterKingIsMoved() throws {
      let game = Game(board: [
        .e2: .whiteKing,
        .a1: .whiteRook,
        .h1: .whiteRook,
        .e8: .blackKing
      ])

      let ke1 = Move.translation(.init(figure: .king, targetSquare: .e1))
      try game.play(ke1)

      let kd8 = Move.translation(.init(figure: .king, targetSquare: .d8))
      try game.play(kd8)

      let kingsideCastle = Move.castling(.kingside)
      #expect(throws: MoveError.illegalMove) {
        try game.play(kingsideCastle)
      }

      let queensideCastle = Move.castling(.queenside)
      #expect(throws: MoveError.illegalMove) {
        try game.play(queensideCastle)
      }
    }

    @Test
    func isIllegalWhenKingIsInCheck() throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .a1: .whiteRook,
        .h1: .whiteRook,
        .e8: .blackKing,
        .e7: .blackRook
      ])

      let kingsideCastle = Move.castling(.kingside)
      #expect(throws: MoveError.illegalMove) {
        try game.play(kingsideCastle)
      }

      let queensideCastle = Move.castling(.queenside)
      #expect(throws: MoveError.illegalMove) {
        try game.play(queensideCastle)
      }
    }

    @Test(arguments: [Square.File.c, .d, .f, .g])
    func legalityIsSideSpecificWhenFileIsAttacked(on file: Square.File) throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .a1: .whiteRook,
        .h1: .whiteRook,
        .e8: .blackKing,
        Square(file: file, rank: .eight): .blackRook
      ])

      let affectedSide = affectedSide(for: file)
      #expect(throws: MoveError.illegalMoveIntoCheck) {
        try game.play(.castling(affectedSide))
      }

      let openSide: Move.Castling = affectedSide == .kingside ? .queenside : .kingside
      try game.play(.castling(openSide))
      expectCastled(openSide, in: game)
    }

    @Test(arguments: [Square.File.b, .c, .d, .f, .g])
    func legalityIsSideSpecificWhenFileIsBlocked(on file: Square.File) throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .a1: .whiteRook,
        .h1: .whiteRook,
        .e8: .blackKing,
        Square(file: file, rank: .one): .whiteKnight
      ])

      let affectedSide = affectedSide(for: file)
      #expect(throws: MoveError.illegalMove) {
        try game.play(.castling(affectedSide))
      }

      let openSide: Move.Castling = affectedSide == .kingside ? .queenside : .kingside
      try game.play(.castling(openSide))
      expectCastled(openSide, in: game)
    }

    @Test(arguments: Move.Castling.allCases)
    func rightsAreRookSpecificAfterRookIsMoved(from side: Move.Castling) throws {
      let rookFile: Square.File = side == .kingside ? .h : .a
      let game = Game(board: [
        .e1: .whiteKing,
        .e8: .blackKing,
        Square(file: rookFile, rank: .two): .whiteRook,
        Square(file: side == .kingside ? .a : .h, rank: .one): .whiteRook
      ])

      let rookHome = Move.translation(.init(
        figure: .rook,
        targetSquare: Square(file: rookFile, rank: .one)
      ))
      try game.play(rookHome)

      let kd8 = Move.translation(.init(figure: .king, targetSquare: .d8))
      try game.play(kd8)

      #expect(throws: MoveError.illegalMove) {
        try game.play(.castling(side))
      }

      let openSide: Move.Castling = side == .kingside ? .queenside : .kingside
      try game.play(.castling(openSide))
      expectCastled(openSide, in: game)
    }

    private func affectedSide(for file: Square.File) -> Move.Castling {
      file.rawValue < Square.File.e.rawValue ? .queenside : .kingside
    }

    private func expectCastled(_ side: Move.Castling, in game: Game) {
      switch side {
      case .kingside:
        #expect(game.board[.g1] == .whiteKing)
        #expect(game.board[.f1] == .whiteRook)
        #expect(game.board[.e1] == nil)
        #expect(game.board[.h1] == nil)
      case .queenside:
        #expect(game.board[.c1] == .whiteKing)
        #expect(game.board[.d1] == .whiteRook)
        #expect(game.board[.e1] == nil)
        #expect(game.board[.a1] == nil)
      }
    }
  }

  @Suite("En Passant")
  struct EnPassant {
    @Test
    func canCaptureAfterDoubleStepPawnMove() throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .d2: .whitePawn,
        .e8: .blackKing,
        .e4: .blackPawn
      ])

      let d4 = Move.translation(.init(figure: .pawn, targetSquare: .d4))
      try game.play(d4)

      let exd3 = Move.translation(.init(
        figure: .pawn,
        targetSquare: .d3,
        isCapture: true
      ))
      try game.play(exd3)

      #expect(game.board[.d3] == .blackPawn)
      #expect(game.board[.d4] == nil)
    }

    @Test
    func cannotCaptureAfterAnotherMove() throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .d2: .whitePawn,
        .e8: .blackKing,
        .e5: .blackPawn
      ])

      let d4 = Move.translation(.init(figure: .pawn, targetSquare: .d4))
      try game.play(d4)

      let e4 = Move.translation(.init(figure: .pawn, targetSquare: .e4))
      try game.play(e4)

      let kd1 = Move.translation(.init(figure: .king, targetSquare: .d1))
      try game.play(kd1)

      let exd3 = Move.translation(.init(
        figure: .pawn,
        targetSquare: .d3,
        isCapture: true
      ))

      #expect(throws: MoveError.illegalMove) {
        try game.play(exd3)
      }
    }

    @Test
    func cannotCaptureAfterSingleStepPawnMove() throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .d3: .whitePawn,
        .e8: .blackKing,
        .e4: .blackPawn
      ])

      let d4 = Move.translation(.init(figure: .pawn, targetSquare: .d4))
      try game.play(d4)

      let exd3 = Move.translation(.init(
        figure: .pawn,
        targetSquare: .d3,
        isCapture: true
      ))

      #expect(throws: MoveError.illegalMove) {
        try game.play(exd3)
      }
    }
  }

  @Suite("Promotion")
  struct Promotion {
    @Test
    func onCapture() throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .g7: .whitePawn,
        .e8: .blackKing,
        .h8: .blackRook
      ])

      let gxh8N = Move.translation(.init(
        figure: .pawn,
        targetSquare: .h8,
        isCapture: true,
        promotion: .knight
      ))
      try game.play(gxh8N)

      #expect(game.board[.h8] == .whiteKnight)
      #expect(game.board[.g7] == nil)
    }

    @Test
    func withoutCapture() throws {
      let game = Game(board: [
        .e1: .whiteKing,
        .g7: .whitePawn,
        .e8: .blackKing
      ])

      let g8R = Move.translation(.init(
        figure: .pawn,
        targetSquare: .g8,
        promotion: .rook
      ))
      try game.play(g8R)

      #expect(game.board[.g8] == .whiteRook)
      #expect(game.board[.g7] == nil)
    }
  }
}
