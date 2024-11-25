import Foundation

// MARK: -
public extension Board {
  static var board: Board {
    let allPieces = Piece.Color.allCases.flatMap { color in
      Piece.Figure.allCases.map { figure in
        Piece(color: color, figure: figure)
      }
    }

    return Board(pieces: allPieces.reduce(into: .init()) { pieces, piece in
      let files: [Square.File]
      switch piece.figure {
      case .pawn:
        files = Square.File.allCases

      case .rook:
        files = [.a, .h]

      case .knight:
        files = [.b, .g]

      case .bishop:
        files = [.c, .f]

      case .queen:
        files = [.d]

      case .king:
        files = [.e]
      }

      pieces = files.reduce(into: pieces) { pieces, file in
        let rank: Square.Rank
        if case piece.figure = .pawn {
          rank = piece.color == .black ? .seven : .two
        } else {
          rank = piece.color == .black ? .eight : .one
        }
        pieces[Square(file: file, rank: rank)] = piece
      }
    })
  }
}

extension Board: CustomStringConvertible {
  public var description: String {
    let allFiles = Square.File.allCases
    return Square.Rank.allCases.reversed().map { rank in
      " \(rank) ".appending(allFiles.map { file in
        pieces[Square(file: file, rank: rank)]?.description ?? " "
      }.joined(separator: " "))
    }
    .joined(separator: "\n")
    .appending("\n   ")
    .appending(allFiles.map(\.description).joined(separator: " "))
  }
}

private extension Board {
  func isCheck(color: Piece.Color) -> Bool {
    pieces.filter { _, piece in
      piece.color == color.opposite
    }.flatMap { square, _ in
      moves(.capture(originSquare: square))
    }.contains { targetSquare in
      pieces[targetSquare] == .init(color: color, figure: .king)
    }
  }

  func isCheckmate(color: Piece.Color) -> Bool {
    !pieces.filter { _, piece in
      piece.color == color
    }.flatMap { originSquare, _ in
      (moves(.move(originSquare: originSquare)) + moves(.capture(originSquare: originSquare))).map { targetSquare in
        Mutation(originSquare: originSquare, targetSquare: targetSquare, promotion: nil)
      }
    }.contains { mutation in
      mutatedBoard(mutations: [mutation]) != nil
    }
  }

  func mutated(play: Notation.Gameplay.Play, moveColor color: Piece.Color) -> Board? {
    let mutations: [Mutation]

    switch play {
    case let .castle(castle):
      guard !isCheck(color: color) else {
        return nil
      }

      let rank: Square.Rank = color == .black ? .eight : .one
      guard !(castle == .long ? [.b, .c, .d] : [.f, .g]).map({ file in
        Square(file: file, rank: rank)
      }).contains(where: pieces.keys.contains) else {
        return nil
      }

      let kingOriginSquare = Square(file: .e, rank: rank)
      let rookOriginSquare = Square(file: castle == .long ? .a : .h, rank: rank)
      for (figure, square) in [Piece.Figure.king: kingOriginSquare, Piece.Figure.rook: rookOriginSquare] {
        guard !squaresTouched.contains(square), pieces[square] == .init(color: color, figure: figure) else {
          return nil
        }
      }

      let rookTargetSquare = Square(file: castle == .long ? .d : .f, rank: rank)
      mutations = [
        (originSquare: kingOriginSquare, targetSquare: rookTargetSquare, promotion: nil),
        (originSquare: rookTargetSquare, targetSquare: .init(file: castle == .long ?.c : .g, rank: rank), promotion: nil),
        (originSquare: rookOriginSquare, targetSquare: rookTargetSquare, promotion: nil)
      ]

    case let .translation(disambiguationFile, disambiguationRank, figure, isCapture, promotion, targetSquare):
      let eligibleSquares = pieces.filter { square, piece in
        if let disambiguationFile, square.file != disambiguationFile {
          return false
        }

        if let disambiguationRank, square.rank != disambiguationRank {
          return false
        }

        guard piece == .init(color: color, figure: figure) else {
          return false
        }

        return moves(isCapture ? .capture(originSquare: square) : .move(originSquare: square)).contains(targetSquare)
      }

      guard eligibleSquares.count == 1 else {
        return nil
      }

      guard let originSquare = eligibleSquares.first?.0 else {
        return nil
      }

      let figure = pieces[originSquare]!.figure
      let promotionRank: Square.Rank = color == .black ? .one : .eight

      // Pawns must be promoted when they reach the end of the board.
      if figure == .pawn, targetSquare.rank == promotionRank, promotion == nil {
        return nil
      }

      if let promotion {
        // Only pawns can be promoted .
        if figure != .pawn {
          return nil
        }

        // only when they reach the end of the board
        if targetSquare.rank != promotionRank {
          return nil
        }

        // and they must be promoted to knight, bishop, rook or queen.
        if [Piece.Figure.king, Piece.Figure.pawn].contains(promotion) {
          return nil
        }
      }

      mutations = [(originSquare: originSquare, targetSquare: targetSquare, promotion: promotion)]
    }

    guard let mutatedBoard = mutatedBoard(mutations: mutations) else {
      return nil
    }

    return mutatedBoard
  }

  private func moves(_ move: Move) -> [Square] {
    let isCapture: Bool
    if case .capture = move {
      isCapture = true
    } else {
      isCapture = false
    }
    let isUnmoved = !squaresTouched.contains(move.originSquare)
    let piece = pieces[move.originSquare]!
    return piece.moves(originSquare: move.originSquare, isCapture: isCapture, isUnmoved: isUnmoved).flatMap { path in
      let collision: (offset: Int, piece: Piece)? = path.enumerated().first { _, targetSquare in
        pieces[targetSquare] != nil
      }.map { offset, targetSquare in
        (offset, pieces[targetSquare]!)
      }

      guard isCapture else {
        return path.prefix(upTo: collision?.offset ?? path.endIndex)
      }

      guard let collision, collision.piece.color == piece.color.opposite else {
        guard let enPassant, piece.figure == .pawn, path.first == enPassant + piece.forwardUnitVector else {
          return []
        }
        return [path.first!]
      }

      return path[collision.offset..<collision.offset+1]
    }
  }

  private func mutatedBoard(mutations: [Mutation]) -> Self? {
    mutations.reduce(self) { board, mutation in
      guard let board else {
        return nil
      }

      let piece = board.pieces[mutation.originSquare]!
      var pieces = board.pieces
      pieces[mutation.originSquare] = nil
      if let enPassant = mutation.targetSquare - piece.forwardUnitVector, piece.figure == .pawn,
          mutation.originSquare.file != mutation.targetSquare.file, pieces[mutation.targetSquare] == nil {
        pieces[enPassant] = nil
      }
      pieces[mutation.targetSquare] = Piece(color: piece.color, figure: mutation.promotion ?? piece.figure)

      let enPassant: Square?
      if piece.figure == .pawn, abs(mutation.originSquare.rank.rawValue - mutation.targetSquare.rank.rawValue) == 2 {
        enPassant = mutation.targetSquare
      } else {
        enPassant = nil
      }
      let squaresTouched = squaresTouched + (squaresTouched.contains(mutation.targetSquare) ? [] : [mutation.targetSquare])
      let mutatedBoard = Board(pieces: pieces, enPassant: enPassant, squaresTouched: squaresTouched)

      // Do not allow moving into/thru check.
      guard !mutatedBoard.isCheck(color: piece.color) else {
        return nil
      }

      return mutatedBoard
    }
  }
}

// MARK: -
extension Notation: CustomStringConvertible {
  var description: String {
    switch self {
    case let .end(victor):
      guard let victor else {
        return .drawGame
      }
      return victor == .black ? .blackWins : .whiteWins

    case let .gameplay(gameplay):
      return "\(gameplay)"
    }
  }
}

extension Notation.Gameplay: CustomStringConvertible {
  var description: String {
    "\(play)\(punctuation?.description ?? "")"
  }
}

extension Notation.Gameplay.Play: CustomStringConvertible {
  var description: String {
    switch self {
    case let .castle(castle):
      switch castle {
      case .long:
        return .castleLong

      case .short:
        return .castleShort
      }

    case let .translation(disambiguationFile, disambiguationRank, figure, isCapture, promotion, targetSquare):
      let disambiguation = (disambiguationFile?.description ?? "").appending(disambiguationRank?.description ?? "")
      let promotion = promotion.map(\.description).map(String.promotion.appending) ?? ""
      return "\(figure)\(disambiguation)\(isCapture ? .capture : "")\(targetSquare)\(promotion)"
    }
  }
}

extension Notation.Gameplay.Punctuation: CustomStringConvertible {
  var description: String {
    rawValue
  }
}

// MARK: -
private extension Piece {
  var forwardUnitVector: Vector {
    Vector(ranks: color == .black ? -1 : 1)
  }

  func moves(originSquare: Square, isCapture: Bool, isUnmoved: Bool) -> [[Square]] {
    switch (figure, isCapture) {
    case (.bishop, _):
      return Vector.diagonalUnitVectors.compactMap(originSquare.allSquaresInDirection)

    case (.king, _):
      return Vector.unitVectors.compactMap { direction in
        (originSquare + direction).map { targetSquare in
          [targetSquare]
        }
      }

    case (.knight, _):
      return [Vector(files: -2, ranks: -1),
              Vector(files: -2, ranks: 1),
              Vector(files: -1, ranks: -2),
              Vector(files: -1, ranks: 2),
              Vector(files: 1, ranks: -2),
              Vector(files: 1, ranks: 2),
              Vector(files: 2, ranks: -1),
              Vector(files: 2, ranks: 1)].compactMap { vector in
        (originSquare + vector).map { targetSquare in
          [targetSquare]
        }
      }

    case (.pawn, false):
      guard let oneSquareForward = originSquare + forwardUnitVector else {
        return []
      }

      guard let twoSquaresForward = oneSquareForward + forwardUnitVector, isUnmoved else {
        return [[oneSquareForward]]
      }

      return [[oneSquareForward, twoSquaresForward]]

    case (.pawn, true):
      let ranks = forwardUnitVector.ranks
      return [Vector(files: -1, ranks: ranks), Vector(files: 1, ranks: ranks)].compactMap { vector in
        (originSquare + vector).map { targetSquare in
          [targetSquare]
        }
      }

    case (.queen, _):
      return Vector.unitVectors.compactMap(originSquare.allSquaresInDirection)

    case (.rook, _):
      return Vector.cardinalUnitVectors.compactMap(originSquare.allSquaresInDirection)
    }
  }
}

extension Piece: CustomStringConvertible {
  public var description: String {
    let description = figure == .pawn ? "P" : figure.rawValue
    return color == .black ? description.lowercased() : description
  }
}

extension Piece.Color: CustomStringConvertible {
  var description: String {
    rawValue
  }
}

extension Piece.Figure: CustomStringConvertible {
  var description: String {
    rawValue
  }
}

// MARK: -
private extension Square {
  func allSquaresInDirection(_ direction: Vector) -> [Self] {
    guard let squareInDirection = self + direction else {
      return []
    }

    return [squareInDirection] + squareInDirection.allSquaresInDirection(direction)
  }
}

extension Square: CustomStringConvertible {
  public var description: String {
    file.description.appending(rank.description)
  }
}

private extension Square.File {
  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue < rhs.rawValue
  }

  static func > (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue > rhs.rawValue
  }
}

extension Square.File: CustomStringConvertible {
  var description: String {
    String(Character(UnicodeScalar(rawValue + 96)!))
  }
}

extension Square.Rank: CustomStringConvertible {
  var description: String {
    String(rawValue)
  }
}

// MARK: -
extension Vector {
  static let cardinalUnitVectors: [Vector] = [
    .init(files: 0, ranks: -1),
    .init(files: -1, ranks: 0),
    .init(files: 0, ranks: 1),
    .init(files: 1, ranks: 0)
  ]

  static let diagonalUnitVectors: [Vector] = [
    .init(files: -1, ranks: -1),
    .init(files: -1, ranks: 1),
    .init(files: 1, ranks: -1),
    .init(files: 1, ranks: 1)
  ]

  static let unitVectors = cardinalUnitVectors + diagonalUnitVectors
}

// MARK: - Game

/// A model representing a chess game.
///
/// Chess is a board game played between two players.
public struct Game {
  private struct InvalidMove: Error {
    let notation: String
  }

  private struct InvalidNotation: Error {
    let notation: String

    init(_ notation: String) {
      self.notation = notation
    }
  }

  var isGameOver: Bool {
    guard case .end = moves.last else {
      return board.isCheckmate(color: moveColor)
    }
    return true
  }

  private var board: Board

  private var moveColor: Piece.Color {
    moves.count.isMultiple(of: 2) ? .white : .black
  }

  private var moves = [Notation]()

  /// Move
  /// - Parameter notation: Notation
  public mutating func move(_ notationString: String) throws {
    guard let notation = Notation(string: notationString) else {
      throw InvalidNotation(notationString)
    }

    if case let .gameplay(gameplay) = notation {
      guard let mutatedBoard = board.mutated(play: gameplay.play, moveColor: moveColor) else {
        throw InvalidMove(notation: notationString)
      }

      board = mutatedBoard

      // Compute game state.
      let isCheck = board.isCheck(color: moveColor.opposite)
      let isCheckmate = board.isCheckmate(color: moveColor.opposite)

      // Correct missing punctuation.
      guard let punctuation = gameplay.punctuation else {
        guard !isCheckmate else {
          let gameplay = Notation.Gameplay(play: gameplay.play, punctuation: .checkmate)
          let notation = Notation.gameplay(gameplay)
          moves += [notation]
          return
        }

        guard !isCheck else {
          let gameplay = Notation.Gameplay(play: gameplay.play, punctuation: .check)
          let notation = Notation.gameplay(gameplay)
          moves += [notation]
          return
        }

        moves += [notation]
        return
      }

      // Validate punctuation parsed from input notation.
      if case .check = punctuation, !isCheck || isCheckmate {
        throw InvalidNotation(notationString)
      } else if case .checkmate = punctuation, !isCheckmate {
        throw InvalidNotation(notationString)
      }
    }

    moves += [notation]
  }

  /// Designated initializer
  public init(board: Board = .board) {
    self.board = board
  }
}

extension Game: CustomStringConvertible {
  public var description: String {
    (moves.isEmpty ? "" : stride(from: 0, to: moves.count, by: 2).map { i in
      "\(i/2+1). "
        .appending(moves[i].description)
        .appending(moves.count > i+1 ? " \(moves[i+1])" : "")
      }.joined(separator: "\n")
    .appending("\n\n"))
    .appending(isGameOver ? "" : "\(moveColor.description.capitalized.appending(" to move."))\n\n")
    .appending(board.description)
  }
}
