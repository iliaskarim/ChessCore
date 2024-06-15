import Foundation

// MARK: Piece
private extension Piece {
  var forwardUnitVector: Vector {
    .forwardUnitVector(color)
  }

  var startSquares: [Square] {
    figure.startFiles.map { file in
      .init(file: file, rank: figure.startRank(color: color))
    }
  }

  func moves(originSquare: Square, isCapture: Bool) -> [[Square]] {
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
              Vector(files: 2, ranks: 1)].reduce(into: .init()) { targetSquares, vector in
        targetSquares += (originSquare + vector).map { targetSquare in
          [[targetSquare]]
        } ?? []
      }

    case (.pawn, false):
      return (originSquare + forwardUnitVector).map { oneSquareForward in
        guard let twoSquaresForward = oneSquareForward + forwardUnitVector,
              originSquare.rank == figure.startRank(color: color) else {
          return [[oneSquareForward]]
        }
        return [[oneSquareForward, twoSquaresForward]]
      } ?? []

    case (.pawn, true):
      return [Vector(files: -1), Vector(files: 1)].compactMap { direction in
        (originSquare + direction + forwardUnitVector).map { targetSquare in
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

private extension Piece.Color {
  var opposite: Self {
    switch self {
    case .white:
      return .black

    case .black:
      return .white
    }
  }
}

private extension Piece.Figure {
  var startFiles: [Square.File] {
    switch self {
    case .pawn:
      return Square.File.allCases

    case .rook:
      return [.a, .h]

    case .knight:
      return [.b, .g]

    case .bishop:
      return [.c, .f]

    case .queen:
      return [.d]

    case .king:
      return [.e]
    }
  }

  func startRank(color: Piece.Color) -> Square.Rank {
    switch (self, color) {
    case (.pawn, .black):
      return .seven

    case (.pawn, .white):
      return .two

    case (_, .black):
      return .eight

    case (_, .white):
      return .one
    }
  }

  init?(_ character: Character) {
    self.init(rawValue: String(character))
  }
}

// MARK: Square
private extension Square {
  static let a1: Self = .init(file: .a, rank: .one)

  static let b1: Self = .init(file: .b, rank: .one)

  static let c1: Self = .init(file: .c, rank: .one)

  static let d1: Self = .init(file: .d, rank: .one)

  static let e1: Self = .init(file: .e, rank: .one)

  static let f1: Self = .init(file: .f, rank: .one)

  static let g1: Self = .init(file: .g, rank: .one)

  static let h1: Self = .init(file: .h, rank: .one)

  static let a8: Self = .init(file: .a, rank: .eight)

  static let b8: Self = .init(file: .b, rank: .eight)

  static let c8: Self = .init(file: .c, rank: .eight)

  static let d8: Self = .init(file: .d, rank: .eight)

  static let e8: Self = .init(file: .e, rank: .eight)

  static let f8: Self = .init(file: .f, rank: .eight)

  static let g8: Self = .init(file: .g, rank: .eight)

  static let h8: Self = .init(file: .h, rank: .eight)

  func allSquaresInDirection(_ direction: Vector) -> [Self] {
    (self + direction).map { squareInDirection -> [Square] in
      [squareInDirection] + squareInDirection.allSquaresInDirection(direction)
    } ?? []
  }

  init?(notation: String) {
    guard let file = notation.first.map({ fileNotation in
      File(fileNotation)
    }), let rank = notation.last.map({ rankNotation in
      Rank(rankNotation)
    }), notation.count == 2 else {
      return nil
    }
    self.init(file: file, rank: rank)
  }

  init?(file: File?, rank: Rank?) {
    guard let file, let rank else {
      return nil
    }
    self = .init(file: file, rank: rank)
  }
}

private extension Optional where Wrapped == Square {
  static func + (lhs: Square?, rhs: Vector) -> Square? {
    lhs.map { lhs in
      .init(file: lhs.file + rhs.files, rank: lhs.rank + rhs.ranks)
    } ?? nil
  }

  static func - (lhs: Square?, rhs: Vector) -> Square? {
    lhs.map { lhs in
      .init(file: lhs.file - rhs.files, rank: lhs.rank - rhs.ranks)
    } ?? nil
  }
}

private extension Square.File {
  static func + (lhs: Square.File, rhs: Int) -> Square.File? {
    .init(integerValue: lhs.integerValue + rhs)
  }

  static func - (lhs: Square.File, rhs: Int) -> Square.File? {
    Self.init(integerValue: lhs.integerValue - rhs)
  }

  var integerValue: Int {
    Self.allCases.firstIndex(of: self)! + 1
  }

  init?(integerValue: Int) {
    guard Self.allCases.indices.contains(integerValue - 1) else {
      return nil
    }
    self = Self.allCases[integerValue - 1]
  }

  init?(_ character: Character) {
    self.init(rawValue: String(character))
  }
}

private extension Square.Rank {
  static func + (lhs: Square.Rank, rhs: Int) -> Square.Rank? {
    .init(rawValue: lhs.rawValue + rhs)
  }

  static func - (lhs: Square.Rank, rhs: Int) -> Square.Rank? {
    .init(rawValue: lhs.rawValue - rhs)
  }

  static func - (lhs: Square.Rank, rhs: Square.Rank) -> Int {
    lhs.rawValue - rhs.rawValue
  }

  init?(_ character: Character) {
    guard let int = Int(String(character)) else {
      return nil
    }
    self.init(rawValue: int)
  }
}

extension Square: CustomStringConvertible {
  public var description: String {
    file.rawValue.appending(String(rank.rawValue))
  }
}

// MARK: Vector
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

  static func forwardUnitVector(_ color: Piece.Color) -> Vector {
    Vector(ranks: color == .black ? -1 : 1)
  }
}


// MARK: - Game

/// A model representing a chess game.
///
/// Chess is a board game played between two players.
public struct Game {
  /// Board
  public typealias Board = [Square: Piece]

  fileprivate enum Outcome {
    case checkmate(victor: Piece.Color)
    case drawnGame(isStalemate: Bool)
    case resignedGame(victor: Piece.Color)
  }

  private struct InvalidMove: Error {
    let notation: String
  }

  private var board: Board

  private var enPassant: Square?

  private var kingsMoved = (black: false, white: false)

  private var rooksMoved = (black: (kingside: false, queenside: false), white: (kingside: false, queenside: false))

  private var moveColor: Piece.Color {
    moves.count.isMultiple(of: 2) ? .white : .black
  }

  private var moves = [String]()

  private var outcome: Outcome?

  private var victor: Piece.Color? {
    switch outcome {
    case let .checkmate(victor):
      return victor

    case let .resignedGame(victor):
      return victor

    default:
      return nil
    }
  }

  /// Move
  /// - Parameter notation: Notation
  public mutating func move(_ notation: String) throws {
    switch (notation, moveColor) {
    case ("1-0", _):
      if moveColor == .black {
        moves += [notation]
      }
      outcome = .resignedGame(victor: .white)
      return

    case ("0-1", _):
      if moveColor == .white {
        moves += [notation]
      }
      outcome = .resignedGame(victor: .black)
      return

    case ("1/2-1/2", _):
      moves += [notation]
      outcome = .drawnGame(isStalemate: false)
      return

    case ("O-O", .black):
      guard !board.isCheck(color: .black, enPassant: enPassant), !kingsMoved.black,
            !rooksMoved.black.kingside, board[.f8] == nil, board[.g8] == nil,
            board[.h8] == Piece(color: .black, figure: .rook) else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board
      mutableBoard[.f8] = mutableBoard.removeValue(forKey: .e8)
      guard !mutableBoard.isCheck(color: .black, enPassant: enPassant) else {
        throw InvalidMove(notation: notation)
      }

      mutableBoard[.g8] = mutableBoard.removeValue(forKey: .f8)
      guard !mutableBoard.isCheck(color: .black, enPassant: enPassant) else {
        throw InvalidMove(notation: notation)
      }

      board = mutableBoard
      board[.f8] = board.removeValue(forKey: .h8)

    case ("O-O", .white):
      guard !board.isCheck(color: .white, enPassant: enPassant), !kingsMoved.white,
              !rooksMoved.white.kingside, board[.f1] == nil, board[.g1] == nil,
              board[.h1] == Piece(color: .white, figure: .rook) else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board
      mutableBoard[.f1] = mutableBoard.removeValue(forKey: .e1)
      guard !mutableBoard.isCheck(color: .white, enPassant: enPassant) else {
        throw InvalidMove(notation: notation)
      }

      mutableBoard[.g1] = mutableBoard.removeValue(forKey: .f1)
      guard !mutableBoard.isCheck(color: .white, enPassant: enPassant) else {
        throw InvalidMove(notation: notation)
      }

      board = mutableBoard
      board[.f1] = board.removeValue(forKey: .h1)

    case ("O-O-O", .black):
      guard !board.isCheck(color: .black, enPassant: enPassant), !kingsMoved.black,
              !rooksMoved.black.queenside, board[.d8] == nil, board[.c8] == nil, board[.b8] == nil, 
              board[.a8] == Piece(color: .black, figure: .rook) else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board
      mutableBoard[.d8] = mutableBoard.removeValue(forKey: .e8)
      guard !mutableBoard.isCheck(color: .black, enPassant: enPassant) else {
        throw InvalidMove(notation: notation)
      }

      mutableBoard[.c8] = mutableBoard.removeValue(forKey: .d8)
      guard !mutableBoard.isCheck(color: .black, enPassant: enPassant) else {
        throw InvalidMove(notation: notation)
      }

      board = mutableBoard
      board[.d8] = board.removeValue(forKey: .a8)

    case ("O-O-O", .white):
      guard !board.isCheck(color: .white, enPassant: enPassant), !kingsMoved.white, !rooksMoved.white.queenside, 
              board[.d1] == nil, board[.c1] == nil, board[.b1] == nil,
              board[.a1] == Piece(color: .white, figure: .rook) else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board
      mutableBoard[.d1] = mutableBoard.removeValue(forKey: .e1)
      guard !mutableBoard.isCheck(color: .white, enPassant: enPassant) else {
        throw InvalidMove(notation: notation)
      }

      mutableBoard[.c1] = mutableBoard.removeValue(forKey: .d1)
      guard !mutableBoard.isCheck(color: .white, enPassant: enPassant) else {
        throw InvalidMove(notation: notation)
      }

      board = mutableBoard
      board[.d1] = board.removeValue(forKey: .a1)

    default:
      let isCapture = notation.contains("x")
      let filteredNotation = notation.filter { character in
        !["x", "+", "#"].contains(character)
      }
      let nextIndex = filteredNotation.index(after: filteredNotation.startIndex)
      let piece: Piece

      if let figureNotation = notation.first, let figure = Piece.Figure(figureNotation) {
        piece = Piece(color: moveColor, figure: figure)
      } else {
        piece = Piece(color: moveColor, figure: .pawn)
      }

      var targetSquareNotation: Substring

      if piece.figure == .pawn, !isCapture {
        targetSquareNotation = filteredNotation[filteredNotation.startIndex..<filteredNotation.endIndex]
      } else {
        targetSquareNotation = filteredNotation[nextIndex..<filteredNotation.endIndex]
      }

      let promotedPiece: Piece?
      if let pieceNotation = targetSquareNotation.last, pieceNotation.isUppercase {
        guard let figure = Piece.Figure(pieceNotation), figure != .king, figure != .pawn else {
          throw InvalidMove(notation: notation)
        }
        promotedPiece = Piece(color: moveColor, figure: figure)
        targetSquareNotation = targetSquareNotation.dropLast(2)
      } else {
        promotedPiece = nil
      }

      // Parse disambiguation notation from input.
      let disambiguationFile: Square.File?
      let disambiguationRank: Square.Rank?
      if targetSquareNotation.count == 4 {
        guard let rank = Square.Rank(targetSquareNotation.first!) else {
          throw InvalidMove(notation: notation)
        }
        disambiguationRank = rank
        targetSquareNotation = targetSquareNotation.dropFirst()

        guard let file = Square.File(targetSquareNotation.first!) else {
          throw InvalidMove(notation: notation)
        }
        disambiguationFile = file
        targetSquareNotation = targetSquareNotation.dropFirst()
      } else if targetSquareNotation.count == 3,
                Square.File.allCases.map(\.rawValue).contains(String(targetSquareNotation.first!)) {
        disambiguationFile = Square.File(targetSquareNotation.first!)!
        disambiguationRank = nil
        targetSquareNotation = targetSquareNotation.dropFirst()
      } else if targetSquareNotation.count == 3 {
        guard let rank = Square.Rank(targetSquareNotation.first!) else {
          throw InvalidMove(notation: notation)
        }
        disambiguationFile = nil
        disambiguationRank = rank
        targetSquareNotation = targetSquareNotation.dropFirst()
      } else if piece.figure == .pawn {
        disambiguationFile = Square.File(filteredNotation.first!)
        disambiguationRank = nil
      } else {
        disambiguationFile = nil
        disambiguationRank = nil
      }

      guard let targetSquare = Square(notation: String(targetSquareNotation)) else {
        throw InvalidMove(notation: notation)
      }

      // Find eligible piece(s).
      let pieces = board.filter { square, squarePiece in
        guard squarePiece == piece else {
          return false
        }

        let moves = board.moves(isCapture ? .capture(originSquare: square, enPassant: enPassant) : .move(originSquare: square))
        guard moves.contains(targetSquare) else {
          return false
        }

        let isFile = disambiguationFile.map { disambiguationFile in
          square.file == disambiguationFile
        } ?? true

        let isRank = disambiguationRank.map { disambiguationRank in
          square.rank == disambiguationRank
        } ?? true

        return isFile && isRank
      }

      guard let originSquare = pieces.first?.key, pieces.count == 1 else {
        throw InvalidMove(notation: notation)
      }

      // Mutate board.
      var mutatedBoard = board.mutatedBoard(originSquare: originSquare, targetSquare: targetSquare)

      // Enforce promotion.
      let isPromotion = (targetSquare.rank == .one || targetSquare.rank == .eight) && board[originSquare]?.figure == .pawn
      if let promotedPiece {
        guard isPromotion else {
          throw InvalidMove(notation: notation)
        }
        mutatedBoard[targetSquare] = promotedPiece
      } else if isPromotion {
        throw InvalidMove(notation: notation)
      }

      // Do not allow moving into check.
      if mutatedBoard.isCheck(color: moveColor, enPassant: enPassant) {
        throw InvalidMove(notation: notation)
      }

      // Update board state.
      board = mutatedBoard

      enPassant = piece.figure == .pawn && abs(originSquare.rank - targetSquare.rank) == 2 ? targetSquare : nil

      switch originSquare {
      case .a1: 
        rooksMoved.white.queenside = true

      case .a8:
        rooksMoved.black.queenside = true

      case .h1:
        rooksMoved.white.kingside = true

      case .h8:
        rooksMoved.black.kingside = true

      case .e1:
        kingsMoved.white = true

      case .e8:
        kingsMoved.black = true

      default: 
        break
      }
    }

    let nextMoveColor = moveColor.opposite
    guard !board.isCheckmate(color: nextMoveColor, enPassant: enPassant) else {
      outcome = .checkmate(victor: moveColor)
      moves += [notation + "#"]
      return
    }
    guard !board.isCheck(color: nextMoveColor, enPassant: enPassant) else {
      moves += [notation + "+"]
      return
    }
    moves += [notation]
  }

  /// Designated initializer
  public init(board: Board = .board) {
    self.board = board
  }
}

extension Game.Board {
  public static var board: Game.Board {
    Piece.Color.allCases.flatMap { color in
      Piece.Figure.allCases.map { figure in
          .init(color: color, figure: figure)
      }
    }.reduce(into: .init()) { result, piece in
      piece.startSquares.forEach { startSquare in
        result[startSquare] = piece
      }
    }
  }
}

private extension Game.Board {
  enum Move {
    case move(originSquare: Square)
    case capture(originSquare: Square, enPassant: Square?)

    var isCapture: Bool {
      guard case .capture = self else {
        return false
      }
      return true
    }

    var originSquare: Square {
      switch self {
      case let .move(originSquare):
        return originSquare

      case let .capture(originSquare, _):
        return originSquare
      }
    }
  }

  func isCheck(color: Piece.Color, enPassant: Square?) -> Bool {
    contains { square, piece in
      piece.color == color.opposite &&
      moves(.capture(originSquare: square, enPassant: enPassant)).compactMap { targetSquare in
        self[targetSquare]
      }.contains(Piece(color: color, figure: .king))
    }
  }

  func isCheckmate(color: Piece.Color, enPassant: Square?) -> Bool {
    !contains { square, piece in
      piece.color == color &&
      (moves(.move(originSquare: square)) + moves(.capture(originSquare: square, enPassant: enPassant))).contains { targetSquare in
        !mutatedBoard(originSquare: square, targetSquare: targetSquare).isCheck(color: color, enPassant: enPassant)
      }
    }
  }

  func moves(_ move: Move) -> [Square] {
    self[move.originSquare].map { piece in
      piece.moves(originSquare: move.originSquare, isCapture: move.isCapture).flatMap { path in
        let offset = path.enumerated().first { _, targetSquare in
          self[targetSquare] != nil
        }?.offset

        guard case let .capture(_, enPassant) = move else {
          return path.prefix(upTo: offset ?? path.endIndex)
        }

        guard let offset, self[path[offset]]?.color == piece.color.opposite else {
          guard piece.figure == .pawn, let targetSquare = path.first,
                targetSquare == enPassant + piece.forwardUnitVector else {
            return []
          }
          return [targetSquare]
        }

        return path[offset..<offset+1]
      }
    } ?? []
  }

  func mutatedBoard(originSquare origin: Square, targetSquare target: Square) -> Self {
    var board = self
    if let piece = board[origin], let enPassant = target - piece.forwardUnitVector, piece.figure == .pawn,
        origin.file != target.file, board[target] == nil {
      board[enPassant] = nil
    }
    board[target] = board.removeValue(forKey: origin)
    return board
  }
}

extension Game: CustomStringConvertible {
  public var description: String {
    (!moves.isEmpty ? stride(from: 0, to: moves.count, by: 2).map { i in
      "\(i/2+1). "
        .appending(moves[i])
        .appending(moves.count > i+1 ? " \(moves[i+1])" : "")
      }.joined(separator: "\n")
    .appending("\n\n") : "")
    .appending("  \(outcome?.description ?? moveColor.rawValue.capitalized.appending(" to move."))\n\n")
    .appending(
      Square.Rank.allCases.reversed().map { rank in
        " ".appending(
          String(rank.rawValue).appending(" ").appending(
            Square.File.allCases.map { file in
              if let piece = board[Square(file: file, rank: rank)] {
                return piece.color == .white ? piece.figure.rawValue : piece.figure.rawValue.lowercased()
              } else {
                return " "
              }
            }.joined(separator: " ")
          )
        )
      }.joined(separator: "\n").appending("\n   ").appending(
        Square.File.allCases.map { file in
          file.rawValue
        }.joined(separator: " ")
      )
    )
  }
}

extension Game.Outcome: CustomStringConvertible {
  var description: String {
    switch self {
    case let .checkmate(victor):
      return "\(victor.rawValue.capitalized) wins."

    case .drawnGame:
      return "Game drawn."

    case let .resignedGame(victor):
      return "\(victor.rawValue.capitalized) wins."
    }
  }
}
