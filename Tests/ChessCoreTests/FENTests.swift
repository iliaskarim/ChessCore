import Testing
@testable import ChessCore

private extension Piece {
  static let blackKing = Self(color: .black, figure: .king)
  static let blackPawn = Self(color: .black, figure: .pawn)
  static let blackRook = Self(color: .black, figure: .rook)
  static let whiteKing = Self(color: .white, figure: .king)
  static let whiteKnight = Self(color: .white, figure: .knight)
  static let whiteRook = Self(color: .white, figure: .rook)
}

private extension Square {
  static let a1 = Self(file: .a, rank: .one)
  static let c5 = Self(file: .c, rank: .five)
  static let d5 = Self(file: .d, rank: .five)
  static let e1 = Self(file: .e, rank: .one)
  static let e3 = Self(file: .e, rank: .three)
  static let e4 = Self(file: .e, rank: .four)
  static let e7 = Self(file: .e, rank: .seven)
  static let e8 = Self(file: .e, rank: .eight)
  static let f3 = Self(file: .f, rank: .three)
  static let f6 = Self(file: .f, rank: .six)
  static let h8 = Self(file: .h, rank: .eight)
}

enum FENTests {
  @Suite("Export")
  struct Export {
    @Test
    func captureResetsHalfmoveClock() throws {
      let game = Game(board: .init(
        pieces: [
          .e1: .whiteKing,
          .e8: .blackKing,
          .d5: .whiteKnight,
          .e7: .blackPawn
        ],
        halfmoveClock: 4,
        fullmoveNumber: 10
      ))

      try game.play(Translation(
        figure: .knight,
        targetSquare: .e7,
        isCapture: true
      ))

      #expect(game.board.fen == "4k3/4N3/8/8/8/8/8/4K3 b - - 0 10")
    }

    @Test
    func castlingRightsFollowTheRooksStillHome() {
      let board = Board(pieces: [
        .e1: .whiteKing,
        .a1: .whiteRook,
        .e8: .blackKing,
        .h8: .blackRook
      ])

      #expect(board.fen == "4k2r/8/8/8/8/8/8/R3K3 w Qk - 0 1")
    }

    @Test
    func pawnMovesRecordEnPassantAndTheFullmoveNumber() throws {
      let game = Game()
      try game.play(Translation(figure: .pawn, targetSquare: .e4))
      #expect(
        game.board.fen == "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
      )

      try game.play(Translation(figure: .pawn, targetSquare: .c5))
      #expect(
        game.board.fen == "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2"
      )
    }

    @Test
    func quietMovesAdvanceTheHalfmoveClock() throws {
      let game = Game()
      try game.play(Translation(figure: .knight, targetSquare: .f3))
      #expect(
        game.board.fen == "rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 1"
      )

      try game.play(Translation(figure: .knight, targetSquare: .f6))
      #expect(
        game.board.fen == "rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2"
      )
    }

    @Test
    func startingPosition() {
      #expect(Board.board.fen == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }

    @Test
    func storedEnPassantSquareIsRecordedWhenNoCaptureExists() {
      let board = Board(
        pieces: [
          .e1: .whiteKing,
          .e8: .blackKing
        ],
        enPassantSquare: .e3,
        toMove: .black,
        fullmoveNumber: 12
      )

      #expect(board.fen == "4k3/8/8/8/8/8/8/4K3 b - e3 0 12")
    }
  }
}
