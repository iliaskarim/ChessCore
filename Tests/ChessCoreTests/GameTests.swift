import Testing
@testable import ChessCore

struct GameTests {
  // MARK: - Castling

  @Test
  func castlingIsIllegalAfterKingIsMoved() throws {
    let game = Game(board: [
      .init(file: .e, rank: .two): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let ke1 = Move.translation(.init(figure: .king, targetSquare: .init(file: .e, rank: .one)))
    try game.play(ke1)

    let kd8 = Move.translation(.init(figure: .king, targetSquare: .init(file: .d, rank: .eight)))
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
  func castlingIsIllegalWhenKingIsInCheck() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .e, rank: .seven): .init(color: .black, figure: .rook)
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

  @Test
  func castlingLegalityIsSideSpecificWhenBFileIsBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .b, rank: .one): .init(color: .white, figure: .knight),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let queensideCastle = Move.castling(.queenside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castling(.kingside)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func castlingLegalityIsSideSpecificWhenCFileIsAttacked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .c, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let queensideCastle = Move.castling(.queenside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castling(.kingside)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func castlingLegalityIsSideSpecificWhenCFileIsBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .c, rank: .one): .init(color: .white, figure: .bishop),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let queensideCastle = Move.castling(.queenside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castling(.kingside)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func castlingLegalityIsSideSpecificWhenDFileIsAttacked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .d, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let queensideCastle = Move.castling(.queenside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castling(.kingside)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func castlingLegalityIsSideSpecificWhenDFileIsBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .d, rank: .one): .init(color: .white, figure: .queen),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let queensideCastle = Move.castling(.queenside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castling(.kingside)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func castlingLegalityIsSideSpecificWhenFFileIsAttacked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .f, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let kingsideCastle = Move.castling(.kingside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castling(.queenside)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func castlingLegalityIsSideSpecificWhenFFileIsBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .f, rank: .one): .init(color: .white, figure: .bishop),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let kingsideCastle = Move.castling(.kingside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castling(.queenside)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func castlingLegalityIsSideSpecificWhenGFileIsAttacked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .g, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let kingsideCastle = Move.castling(.kingside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castling(.queenside)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func castlingLegalityIsSideSpecificWhenGFileIsBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .g, rank: .one): .init(color: .white, figure: .knight),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let kingsideCastle = Move.castling(.kingside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castling(.queenside)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func castlingRightsAreRookSpecificAfterKingsideRookIsMoved() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .two): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let rh1 = Move.translation(.init(figure: .rook, targetSquare: .init(file: .h, rank: .one)))
    try game.play(rh1)

    let kd8 = Move.translation(.init(figure: .king, targetSquare: .init(file: .d, rank: .eight)))
    try game.play(kd8)

    let kingsideCastle = Move.castling(.kingside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castling(.queenside)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func castlingRightsAreRookSpecificAfterQueensideRookIsMoved() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .two): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let ra1 = Move.translation(.init(figure: .rook, targetSquare: .init(file: .a, rank: .one)))
    try game.play(ra1)

    let kd8 = Move.translation(.init(figure: .king, targetSquare: .init(file: .d, rank: .eight)))
    try game.play(kd8)

    let queensideCastle = Move.castling(.queenside)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castling(.kingside)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func queensideCastlingIsLegalWhenBFileIsAttacked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .b, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let queensideCastle = Move.castling(.queenside)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  // MARK: - En Passant

  @Test
  func canCaptureEnPassantAfterDoubleStepPawnMove() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .d, rank: .two): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .e, rank: .four): .init(color: .black, figure: .pawn)
    ])

    let d4 = Move.translation(.init(figure: .pawn, targetSquare: .init(file: .d, rank: .four)))
    try game.play(d4)

    let exd3 = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .d, rank: .three),
      isCapture: true
    ))
    try game.play(exd3)

    #expect(game.board[.init(file: .d, rank: .three)] == .init(color: .black, figure: .pawn))
    #expect(game.board[.init(file: .d, rank: .four)] == nil)
  }

  @Test
  func cannotCaptureEnPassantAfterAnotherMove() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .d, rank: .two): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .e, rank: .five): .init(color: .black, figure: .pawn)
    ])

    let d4 = Move.translation(.init(figure: .pawn, targetSquare: .init(file: .d, rank: .four)))
    try game.play(d4)

    let e4 = Move.translation(.init(figure: .pawn, targetSquare: .init(file: .e, rank: .four)))
    try game.play(e4)

    let kd1 = Move.translation(.init(figure: .king, targetSquare: .init(file: .d, rank: .one)))
    try game.play(kd1)

    let exd3 = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .d, rank: .three),
      isCapture: true
    ))

    #expect(throws: MoveError.illegalMove) {
      try game.play(exd3)
    }
  }

  @Test
  func cannotCaptureEnPassantAfterSingleStepPawnMove() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .d, rank: .three): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .e, rank: .four): .init(color: .black, figure: .pawn)
    ])

    let d4 = Move.translation(.init(figure: .pawn, targetSquare: .init(file: .d, rank: .four)))
    try game.play(d4)

    let exd3 = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .d, rank: .three),
      isCapture: true
    ))

    #expect(throws: MoveError.illegalMove) {
      try game.play(exd3)
    }
  }

  // MARK: - Game End

  @Test
  func fiftyMoveRule() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .b, rank: .one): .init(color: .white, figure: .knight),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .g, rank: .eight): .init(color: .black, figure: .knight)
    ])

    let na3 = Move.translation(.init(figure: .knight, targetSquare: .init(file: .a, rank: .three)))
    let nh6 = Move.translation(.init(figure: .knight, targetSquare: .init(file: .h, rank: .six)))
    let nb1 = Move.translation(.init(figure: .knight, targetSquare: .init(file: .b, rank: .one)))
    let ng8 = Move.translation(.init(figure: .knight, targetSquare: .init(file: .g, rank: .eight)))

    let moves = [na3, nh6, nb1, ng8]
    for ply in 0 ..< 100 {
      try game.play(moves[ply % moves.count])
    }

    #expect(game.status == .draw(.byFiftyMoveRule))
  }

  @Test
  func scholarsMate() throws {
    let game = Game()

    // 1.
    let e4 = Move.translation(.init(figure: .pawn, targetSquare: .init(file: .e, rank: .four)))
    try game.play(e4)

    let e5 = Move.translation(.init(figure: .pawn, targetSquare: .init(file: .e, rank: .five)))
    try game.play(e5)

    // 2.
    let qh5 = Move.translation(.init(figure: .queen, targetSquare: .init(file: .h, rank: .five)))
    try game.play(qh5)

    let nc6 = Move.translation(.init(figure: .knight, targetSquare: .init(file: .c, rank: .six)))
    try game.play(nc6)

    // 3.
    let bc4 = Move.translation(.init(figure: .bishop, targetSquare: .init(file: .c, rank: .four)))
    try game.play(bc4)

    let nf6 = Move.translation(.init(figure: .knight, targetSquare: .init(file: .f, rank: .six)))
    try game.play(nf6)

    // 4.
    let qxf7 = Move.translation(.init(
      figure: .queen,
      targetSquare: .init(file: .f, rank: .seven),
      isCapture: true
    ))
    try game.play(qxf7)

    #expect(game.status == .winner(.white, isByResignation: false))
  }

  @Test
  func stalemate() throws {
    let game = Game(board: [
      .init(file: .e, rank: .five): .init(color: .white, figure: .king),
      .init(file: .e, rank: .seven): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let ke6 = Move.translation(.init(figure: .king, targetSquare: .init(file: .e, rank: .six)))
    try game.play(ke6)

    #expect(game.status == .draw(.byStalemate))
  }

  // MARK: - Promotion

  @Test
  func promotionOnCapture() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .g, rank: .seven): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .h, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let gxh8N = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .h, rank: .eight),
      isCapture: true,
      promotion: .knight
    ))
    try game.play(gxh8N)

    #expect(game.board[.init(file: .h, rank: .eight)] == .init(color: .white, figure: .knight))
    #expect(game.board[.init(file: .g, rank: .seven)] == nil)
  }

  @Test
  func promotionWithoutCapture() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .g, rank: .seven): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let g8R = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .g, rank: .eight),
      promotion: .rook
    ))
    try game.play(g8R)

    #expect(game.board[.init(file: .g, rank: .eight)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .g, rank: .seven)] == nil)
  }
}
