import Testing
@testable import ChessCore

struct GameTests {
  // MARK: - Castling

  @Test
  func testCastlingAfterKingMoved() throws {
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

    let kingsideCastle = Move.castle(.short)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castle(.long)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }
  }

  @Test
  func testCastlingAfterKingsideRookMoved() throws {
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

    let kingsideCastle = Move.castle(.short)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castle(.long)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func testCastlingAfterQueensideRookMoved() throws {
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

    let queensideCastle = Move.castle(.long)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castle(.short)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func testCastlingIntoCheckOnCFile() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .c, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let queensideCastle = Move.castle(.long)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castle(.short)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func testCastlingThroughCheckOnDFile() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .d, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let queensideCastle = Move.castle(.long)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castle(.short)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func testCastlingWhenBFileBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .b, rank: .one): .init(color: .white, figure: .knight),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let queensideCastle = Move.castle(.long)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castle(.short)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func testCastlingWhenCFileBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .c, rank: .one): .init(color: .white, figure: .bishop),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let queensideCastle = Move.castle(.long)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castle(.short)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func testCastlingWhenDFileBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .d, rank: .one): .init(color: .white, figure: .queen),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let queensideCastle = Move.castle(.long)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castle(.short)
    try game.play(kingsideCastle)

    #expect(game.board[.init(file: .g, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .f, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .h, rank: .one)] == nil)
  }

  @Test
  func testCastlingIntoCheckOnGFile() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .g, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let kingsideCastle = Move.castle(.short)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castle(.long)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func testCastlingThroughCheckOnFFile() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .f, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let kingsideCastle = Move.castle(.short)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castle(.long)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func testCastlingWhenFFileBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .f, rank: .one): .init(color: .white, figure: .bishop),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let kingsideCastle = Move.castle(.short)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castle(.long)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func testCastlingWhenGFileBlocked() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .g, rank: .one): .init(color: .white, figure: .knight),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let kingsideCastle = Move.castle(.short)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }

    let queensideCastle = Move.castle(.long)
    try game.play(queensideCastle)

    #expect(game.board[.init(file: .c, rank: .one)] == .init(color: .white, figure: .king))
    #expect(game.board[.init(file: .d, rank: .one)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .e, rank: .one)] == nil)
    #expect(game.board[.init(file: .a, rank: .one)] == nil)
  }

  @Test
  func testCastlingWhenInCheck() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .a, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .h, rank: .one): .init(color: .white, figure: .rook),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .e, rank: .seven): .init(color: .black, figure: .rook)
    ])

    let queensideCastle = Move.castle(.long)
    #expect(throws: MoveError.illegalMove) {
      try game.play(queensideCastle)
    }

    let kingsideCastle = Move.castle(.short)
    #expect(throws: MoveError.illegalMove) {
      try game.play(kingsideCastle)
    }
  }

  // MARK: - En Passant

  @Test
  func testCannotEnPassantCaptureAfterAnotherMove() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .d, rank: .two): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .e, rank: .five): .init(color: .black, figure: .pawn)
    ])

    // 1.
    let d4 = Move.translation(.init(figure: .pawn, targetSquare: .init(file: .d, rank: .four)))
    try game.play(d4)

    let e4 = Move.translation(.init(figure: .pawn, targetSquare: .init(file: .e, rank: .four)))
    try game.play(e4)

    // 2.
    let kd1 = Move.translation(.init(figure: .king, targetSquare: .init(file: .d, rank: .one)))
    try game.play(kd1)

    let exd3 = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .d, rank: .three),
      isCapture: true)
    )

    #expect(throws: MoveError.illegalMove) {
      try game.play(exd3)
    }
  }

  @Test
  func testCannotEnPassantCaptureAfterSingleStep() throws {
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
      isCapture: true)
    )

    #expect(throws: MoveError.illegalMove) {
      try game.play(exd3)
    }
  }

  @Test
  func testEnPassantCapture() throws {
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
      isCapture: true)
    )
    try game.play(exd3)

    #expect(game.board[.init(file: .d, rank: .three)] == .init(color: .black, figure: .pawn))
    #expect(game.board[.init(file: .d, rank: .four)] == nil)
  }

  // MARK: - Game End

  @Test
  func testFiftyMoveRule() throws {
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
      let playedPly = ply + 1
      if playedPly < 100, case let .toMove(actualToMove) = game.status {
        let expectedToMove: Piece.Color = playedPly.isMultiple(of: 2) ? .white : .black
        #expect(actualToMove == expectedToMove)
      } else if playedPly < 100 {
        #expect(Bool(false), "Game ended early at ply \(playedPly): \(game.status)")
      }
    }

    #expect(game.status == .draw(.byFiftyMoveRule))
  }

  @Test
  func testScholarsMate() throws {
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
  func testStalemate() throws {
    let game = Game(board: [
      .init(file: .e, rank: .five): .init(color: .white, figure: .king),
      .init(file: .e, rank: .seven): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let ke6 = Move.translation(.init(figure: .king, targetSquare: .init(file: .e, rank: .six)))
    try game.play(ke6)

    #expect(game.status == .draw(.byStalemate))

    let kd7 = Move.translation(.init(figure: .king, targetSquare: .init(file: .d, rank: .seven)))
    #expect(throws: GameStateError.gameOver) {
      try game.play(kd7)
    }

    let kxe7 = Move.translation(.init(
      figure: .king,
      targetSquare: .init(file: .e, rank: .seven),
      isCapture: true
    ))
    #expect(throws: GameStateError.gameOver) {
      try game.play(kxe7)
    }

    let kf7 = Move.translation(.init(figure: .king, targetSquare: .init(file: .f, rank: .seven)))
    #expect(throws: GameStateError.gameOver) {
      try game.play(kf7)
    }

    let kd8 = Move.translation(.init(figure: .king, targetSquare: .init(file: .d, rank: .eight)))
    #expect(throws: GameStateError.gameOver) {
      try game.play(kd8)
    }

    let kf8 = Move.translation(.init(figure: .king, targetSquare: .init(file: .f, rank: .eight)))
    #expect(throws: GameStateError.gameOver) {
      try game.play(kf8)
    }
  }

  // MARK: - Promotion

  @Test
  func testPromotionOnCapture() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .g, rank: .seven): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king),
      .init(file: .h, rank: .eight): .init(color: .black, figure: .rook)
    ])

    let gxh8KnightPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .h, rank: .eight),
      isCapture: true,
      promotion: .knight
    ))
    try game.play(gxh8KnightPromotion)

    #expect(game.board[.init(file: .h, rank: .eight)] == .init(color: .white, figure: .knight))
    #expect(game.board[.init(file: .g, rank: .seven)] == nil)
  }

  @Test
  func testPromotionWithoutCapture() throws {
    let game = Game(board: [
      .init(file: .e, rank: .one): .init(color: .white, figure: .king),
      .init(file: .g, rank: .seven): .init(color: .white, figure: .pawn),
      .init(file: .e, rank: .eight): .init(color: .black, figure: .king)
    ])

    let g8RookPromotion = Move.translation(.init(
      figure: .pawn,
      targetSquare: .init(file: .g, rank: .eight),
      promotion: .rook
    ))

    try game.play(g8RookPromotion)

    #expect(game.board[.init(file: .g, rank: .eight)] == .init(color: .white, figure: .rook))
    #expect(game.board[.init(file: .g, rank: .seven)] == nil)
  }

  // MARK: - Game.Status

  @Test
  func testStatusWinnerDescription() {
    let status = Game.Status.winner(.white, isByResignation: false)

    #expect(status.description == "White wins.")
  }

  @Test
  func testStatusToMoveDescription() {
    let status = Game.Status.toMove(.black)

    #expect(status.description == "Black to move.")
  }

  @Test
  func testStatusDrawDescription() {
    let status = Game.Status.draw(.byFiftyMoveRule)

    #expect(status.description == "Draw by fifty-move rule.")
  }

  // MARK: - Game.Status.Draw

  @Test
  func testDrawByAgreementDescription() {
    #expect(Game.Status.Draw.byAgreement.description == "Draw by agreement.")
  }

  @Test
  func testDrawByFiftyMoveRuleDescription() {
    #expect(Game.Status.Draw.byFiftyMoveRule.description == "Draw by fifty-move rule.")
  }

  @Test
  func testDrawByStalemateDescription() {
    #expect(Game.Status.Draw.byStalemate.description == "Draw by stalemate.")
  }
}
