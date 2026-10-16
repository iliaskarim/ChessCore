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

  @Suite("Import")
  struct Import {
    @Test
    func castlingMarksAreAcceptedInAnyOrder() throws {
      let board = try Board(
        fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w qkQK - 0 1"
      )
      #expect(board.fen == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }

    @Test
    func castlingRightsFromTheStringArePlayable() throws {
      let game = try Game(board: Board(fen: "4k3/8/8/8/8/8/8/R3K2R w K - 0 1"))
      let queensideCastle = Castling.queenside
      #expect(throws: MoveError.illegalMove) {
        try game.play(queensideCastle)
      }

      try game.play(Castling.kingside)
      #expect(game.board.fen == "4k3/8/8/8/8/8/8/R4RK1 b - - 1 1")
    }

    @Test
    func loadedPositionCanBePlayed() throws {
      let game = try Game(board: Board(
        fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
      ))
      try game.play(Translation(figure: .pawn, targetSquare: .c5))
      #expect(
        game.board.fen == "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2"
      )
    }

    @Test
    func omittedCastlingRightsAreNotInferred() throws {
      let fen = "r3k2r/8/8/8/8/8/8/R3K2R w - - 0 1"
      let game = try Game(board: Board(fen: fen))
      #expect(game.board.fen == fen)

      let kingsideCastle = Castling.kingside
      #expect(throws: MoveError.illegalMove) {
        try game.play(kingsideCastle)
      }
    }

    @Test(arguments: [
      "8/8/8/8/8/8/8/8 w KK - 0 1",
      "8/8/8/8/8/8/8/8 w X - 0 1",
      "8/8/8/8/8/8/8/8 w K- - 0 1",
      "8/8/8/8/8/8/8/8 w  - 0 1"
    ])
    func rejectsMalformedCastlingRights(_ fen: String) {
      #expect(throws: FENError.invalidCastlingRights) {
        try Board(fen: fen)
      }
    }

    @Test(arguments: ["e9", "i3", "E3", "e"])
    func rejectsAMalformedEnPassantSquare(_ square: String) {
      #expect(throws: FENError.invalidEnPassantSquare) {
        try Board(fen: "8/8/8/8/8/8/8/8 w - \(square) 0 1")
      }
    }

    @Test(arguments: ["0", "+1", "x"])
    func rejectsAMalformedFullmoveNumber(_ fullmove: String) {
      #expect(throws: FENError.invalidFullmoveNumber) {
        try Board(fen: "8/8/8/8/8/8/8/8 w - - 0 \(fullmove)")
      }
    }

    @Test(arguments: ["-1", "+1", "x"])
    func rejectsAMalformedHalfmoveClock(_ clock: String) {
      #expect(throws: FENError.invalidHalfmoveClock) {
        try Board(fen: "8/8/8/8/8/8/8/8 w - - \(clock) 1")
      }
    }

    @Test(arguments: [
      "8/8/8/8/8/8/8",
      "9/8/8/8/8/8/8/8",
      "7/8/8/8/8/8/8/8",
      "x7/8/8/8/8/8/8/8",
      "8/8/8//8/8/8/8",
      "ppppppppp/8/8/8/8/8/8/8",
      "8/8/8/8/8/8/8/8/8"
    ])
    func rejectsMalformedPlacement(_ placement: String) {
      #expect(throws: FENError.invalidPlacement) {
        try Board(fen: "\(placement) w - - 0 1")
      }
    }

    @Test(arguments: ["W", "white"])
    func rejectsAnUnknownSideToMove(_ side: String) {
      #expect(throws: FENError.invalidSideToMove) {
        try Board(fen: "8/8/8/8/8/8/8/8 \(side) - - 0 1")
      }
    }

    @Test(arguments: [
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0",
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 extra",
      " rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 "
    ])
    func rejectsTheWrongNumberOfFields(_ fen: String) {
      #expect(throws: FENError.invalidFieldCount) {
        try Board(fen: fen)
      }
    }

    @Test(arguments: [
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
      "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
      "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2",
      "rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2",
      "4k3/4N3/8/8/8/8/8/4K3 b - - 0 10",
      "4k2r/8/8/8/8/8/8/R3K3 w Qk - 0 1",
      "4k3/8/8/8/8/8/8/4K3 b - e3 0 12",
      "r3k3/8/8/8/8/8/8/4K2R w Kq - 7 9"
    ])
    func roundTrip(_ fen: String) throws {
      #expect(try Board(fen: fen).fen == fen)
    }
  }
}
