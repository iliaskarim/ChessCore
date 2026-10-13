import Testing
@testable import ChessCore

private extension Piece {
  static let blackBishop = Self(color: .black, figure: .bishop)
  static let blackKing = Self(color: .black, figure: .king)
  static let blackKnight = Self(color: .black, figure: .knight)
  static let whiteBishop = Self(color: .white, figure: .bishop)
  static let whiteKing = Self(color: .white, figure: .king)
  static let whiteKnight = Self(color: .white, figure: .knight)
  static let whitePawn = Self(color: .white, figure: .pawn)
}

private extension Square {
  static let a3 = Self(file: .a, rank: .three)
  static let b1 = Self(file: .b, rank: .one)
  static let c1 = Self(file: .c, rank: .one)
  static let c4 = Self(file: .c, rank: .four)
  static let c6 = Self(file: .c, rank: .six)
  static let e1 = Self(file: .e, rank: .one)
  static let e4 = Self(file: .e, rank: .four)
  static let e5 = Self(file: .e, rank: .five)
  static let e6 = Self(file: .e, rank: .six)
  static let e7 = Self(file: .e, rank: .seven)
  static let e8 = Self(file: .e, rank: .eight)
  static let f4 = Self(file: .f, rank: .four)
  static let f5 = Self(file: .f, rank: .five)
  static let f6 = Self(file: .f, rank: .six)
  static let f7 = Self(file: .f, rank: .seven)
  static let g1 = Self(file: .g, rank: .one)
  static let g8 = Self(file: .g, rank: .eight)
  static let h5 = Self(file: .h, rank: .five)
  static let h6 = Self(file: .h, rank: .six)
}

@Suite("Game End")
struct GameEndTests {
  @Suite("Insufficient Material")
  struct InsufficientMaterial {
    @Test
    func bareKings() {
      let game = Game(board: [
        .e1: .whiteKing,
        .e8: .blackKing
      ])

      #expect(game.status == .draw(InsufficientMaterialDrawCondition.self))
      #expect(game.status.description == "Draw by insufficient material.")
    }

    @Test
    func kingAndBishopAgainstKing() {
      let game = Game(board: [
        .e1: .whiteKing,
        .c1: .whiteBishop,
        .e8: .blackKing
      ])

      #expect(game.status == .draw(InsufficientMaterialDrawCondition.self))
    }

    @Test
    func kingAndKnightAgainstKing() {
      let game = Game(board: [
        .e1: .whiteKing,
        .b1: .whiteKnight,
        .e8: .blackKing
      ])

      #expect(game.status == .draw(InsufficientMaterialDrawCondition.self))
    }

    @Test
    func oppositeColorBishops() {
      let game = Game(board: [
        .e1: .whiteKing,
        .c1: .whiteBishop,
        .e8: .blackKing,
        .f5: .blackBishop
      ])

      #expect(game.status == .toMove(.white))
    }

    @Test
    func sameColorBishops() {
      let game = Game(board: [
        .e1: .whiteKing,
        .c1: .whiteBishop,
        .e8: .blackKing,
        .f4: .blackBishop
      ])

      #expect(game.status == .draw(InsufficientMaterialDrawCondition.self))
    }

    @Test
    func twoKnightsAgainstKing() {
      let game = Game(board: [
        .e1: .whiteKing,
        .b1: .whiteKnight,
        .g1: .whiteKnight,
        .e8: .blackKing
      ])

      #expect(game.status == .toMove(.white))
    }
  }

  @Test
  func drawByAgreement() throws {
    let game = Game()

    try game.endGame(victor: nil)

    #expect(game.status == .draw(AgreementDrawCondition.self))
    #expect(game.status.description == "Draw by agreement.")
  }

  @Test
  func fiftyMoveRule() {
    let na3 = Translation(figure: .knight, targetSquare: .a3)
    let nh6 = Translation(figure: .knight, targetSquare: .h6)
    let nb1 = Translation(figure: .knight, targetSquare: .b1)
    let ng8 = Translation(figure: .knight, targetSquare: .g8)

    let moves = [na3, nh6, nb1, ng8].map(AnyMove.init)
    let turns: [Turn] = (0 ..< 100).map { ply in
      .move(moves[ply % moves.count], punctuation: nil)
    }

    #expect(FiftyMoveDrawCondition.isDraw(
      board: .board,
      turns: turns,
      boards: []
    ))
  }

  @Test
  func scholarsMate() throws {
    let game = Game()

    // 1.
    let e4 = Translation(figure: .pawn, targetSquare: .e4)
    try game.play(e4)

    let e5 = Translation(figure: .pawn, targetSquare: .e5)
    try game.play(e5)

    // 2.
    let qh5 = Translation(figure: .queen, targetSquare: .h5)
    try game.play(qh5)

    let nc6 = Translation(figure: .knight, targetSquare: .c6)
    try game.play(nc6)

    // 3.
    let bc4 = Translation(figure: .bishop, targetSquare: .c4)
    try game.play(bc4)

    let nf6 = Translation(figure: .knight, targetSquare: .f6)
    try game.play(nf6)

    // 4.
    let qxf7 = Translation(
      figure: .queen,
      targetSquare: .f7,
      isCapture: true
    )
    try game.play(qxf7)

    #expect(game.status == .winner(.white, isByResignation: false))
  }

  @Test
  func stalemate() throws {
    let game = Game(board: [
      .e5: .whiteKing,
      .e7: .whitePawn,
      .e8: .blackKing
    ])

    let ke6 = Translation(figure: .king, targetSquare: .e6)
    try game.play(ke6)

    #expect(game.status == .draw(StalemateDrawCondition.self))
    #expect(game.status.description == "Draw by stalemate.")
  }

  @Test
  func threefoldRepetition() throws {
    let game = Game(board: [
      .e1: .whiteKing,
      .b1: .whiteKnight,
      .e8: .blackKing,
      .g8: .blackKnight
    ])

    let na3 = Translation(figure: .knight, targetSquare: .a3)
    let nh6 = Translation(figure: .knight, targetSquare: .h6)
    let nb1 = Translation(figure: .knight, targetSquare: .b1)
    let ng8 = Translation(figure: .knight, targetSquare: .g8)

    for move in [na3, nh6, nb1, ng8, na3, nh6, nb1, ng8] {
      try game.play(move)
    }

    #expect(game.status == .draw(ThreefoldRepetitionDrawCondition.self))
    #expect(game.status.description == "Draw by threefold repetition.")
  }
}
