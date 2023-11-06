import Foundation

// MARK: - Direction
extension Direction {
  fileprivate static let northEast = Direction(horizontal: .east, vertical: .north)
  fileprivate static let northWest = Direction(horizontal: .west, vertical: .north)
  fileprivate static let southEast = Direction(horizontal: .east, vertical: .south)
  fileprivate static let southWest = Direction(horizontal: .west, vertical: .south)
}

// MARK: - Piece
extension Piece {
  fileprivate var startingSquares: [Square] {
    switch figure {
    case .pawn:
      return Square.File.allCases.map { file in
        Square(file: file, rank: color == .white ? .two : .seven) 
      }

    case .rook:
      return color == .white ? [.a1, .h1] : [.a8, .h8]

    case .knight:
      return color == .white ? [.b1, .g1] : [.b8, .g8]

    case .bishop:
      return color == .white ? [.c1, .f1] : [.c8, .f8]

    case .queen:
      return color == .white ? [.d1] : [.d8]

    case .king:
      return color == .white ? [.e1] : [.e8]
    }
  }

  fileprivate func movesFromSquare(_ square: Square) -> [[Square]] {
    switch self.figure {
    case .bishop:
      return Direction.diagonalDirections.compactMap(square.allSquaresInDirection)

    case .knight:
      return [(-2, -1), (-2, 1), (2, -1), (2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2)]
        .compactMap { direction in
          Square(file: square.file + direction.0, rank: square.rank + direction.1)
        }.map { [$0] }

    case .king:
      return Direction.allDirections.compactMap(square.squareInDirection).map { [$0] }

    case .queen:
      return Direction.allDirections.compactMap(square.allSquaresInDirection)

    case .pawn:
      let direction = color == .white ? 1 : -1
      let startRank: Square.Rank = color == .white ? .two : .seven
      return [[
        Square(file: square.file, rank: square.rank + direction),
        (square.rank == startRank) ? Square(file: square.file, rank: square.rank + direction * 2) : nil
      ].compactMap { $0 }]

    case .rook:
      return Direction.cardinalDirections.compactMap(square.allSquaresInDirection)
    }
  }
}

extension Optional where Wrapped == Piece {
  fileprivate func capturesFromSquare(_ square: Square) -> [[Square]] {
    guard let self = self else { return [] }
    if case .pawn = self.figure {
      let directions: [Direction] = (self.color == .black) ? [.southEast, .southWest] : [.northEast, .northWest]
      return directions.compactMap(square.squareInDirection).map { [$0] }
    }
    return self.movesFromSquare(square)
  }
}

extension Piece.Figure {
  fileprivate init?(_ character: Character) {
    self.init(rawValue: String(character))
  }
}

// MARK: - Square
extension Square {
  fileprivate static let a1 = Self.init(file: .a, rank: .one)
  fileprivate static let b1 = Self.init(file: .b, rank: .one)
  fileprivate static let c1 = Self.init(file: .c, rank: .one)
  fileprivate static let d1 = Self.init(file: .d, rank: .one)
  fileprivate static let e1 = Self.init(file: .e, rank: .one)
  fileprivate static let f1 = Self.init(file: .f, rank: .one)
  fileprivate static let g1 = Self.init(file: .g, rank: .one)
  fileprivate static let h1 = Self.init(file: .h, rank: .one)

  fileprivate static let a8 = Self.init(file: .a, rank: .eight)
  fileprivate static let b8 = Self.init(file: .b, rank: .eight)
  fileprivate static let c8 = Self.init(file: .c, rank: .eight)
  fileprivate static let d8 = Self.init(file: .d, rank: .eight)
  fileprivate static let e8 = Self.init(file: .e, rank: .eight)
  fileprivate static let f8 = Self.init(file: .f, rank: .eight)
  fileprivate static let g8 = Self.init(file: .g, rank: .eight)
  fileprivate static let h8 = Self.init(file: .h, rank: .eight)

  fileprivate func allSquaresInDirection(_ direction: Direction) -> [Self] {
    guard let squareInDirection = squareInDirection(direction) else { return [] }
    return [squareInDirection] + squareInDirection.allSquaresInDirection(direction)
  }

  fileprivate func squareInDirection(_ direction: Direction) -> Self? {
    Self.init(file: file + direction.horizontal.translation, rank: rank + direction.vertical.translation)
  }

  fileprivate init?(notation: String) {
    guard notation.count == 2 else { return nil }
    guard let file = File(notation.first!) else { return nil }
    guard let rank = Rank(notation.last!) else { return nil }
    self.init(file: file, rank: rank)
  }
}

extension Square.File {
  fileprivate init?(_ character: Character) {
    self.init(rawValue: String(character))
  }
}

extension Square.Rank {
  fileprivate init?(_ character: Character) {
    guard let int = Int(String(character)) else { return nil }
    self.init(rawValue: int)
  }
}

// MARK: - Game

/// A model representing a chess game.
///
/// Chess is a board game played between two players.
public struct Game {
  /// Board
  public typealias Board = [Square: Piece]

  /// Invalid move
  public struct InvalidMove: Error {
    /// Notation
    public let notation: String
  }

  /// Outcome
  enum Outcome {
    case checkmate(victor: Piece.Color)
    case drawnGame(isStalemate: Bool)
    case resignedGame(victor: Piece.Color)
  }

  /// Victor
  public var victor: Piece.Color? {
    guard let outcome = outcome else { return nil }
    switch outcome {
    case let .checkmate(victor):
      return victor

    case let .resignedGame(victor):
      return victor

    default: return nil
    }
  }

  /// Move
  /// - Parameter notation: Notation
  public mutating func move(_ notation: String) throws {
    switch (notation, nextMoveColor) {
    case ("1-0", .black):
      moves += [notation]
      outcome = .resignedGame(victor: .white)
      return

    case ("0-1", .white):
      moves += [notation]
      outcome = .resignedGame(victor: .black)
      return

    case ("1/2-1/2", _):
      moves += [notation]
      outcome = .drawnGame(isStalemate: false)
      return

    case ("O-O", .black):
      guard !board.isCheck(color: .black), !kingsMoved.black, !rooksMoved.black.kingside, board[.f8] == nil,
            board[.g8] == nil, board[.h8] == Piece(color: .black, figure: .rook) else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board
      mutableBoard[.f8] = mutableBoard.removeValue(forKey: .e8)
      guard !mutableBoard.isCheck(color: .black) else {
        throw InvalidMove(notation: notation)
      }

      mutableBoard[.g8] = mutableBoard.removeValue(forKey: .f8)
      guard !mutableBoard.isCheck(color: .black) else {
        throw InvalidMove(notation: notation)
      }

      board = mutableBoard
      board[.f8] = board.removeValue(forKey: .h8)

    case ("O-O", .white):
      guard !board.isCheck(color: .white), !kingsMoved.white, !rooksMoved.white.kingside, board[.f1] == nil,
            board[.g1] == nil, board[.h1] == Piece(color: .white, figure: .rook) else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board
      mutableBoard[.f1] = mutableBoard.removeValue(forKey: .e1)
      guard !mutableBoard.isCheck(color: .white) else {
        throw InvalidMove(notation: notation)
      }

      mutableBoard[.g1] = mutableBoard.removeValue(forKey: .f1)
      guard !mutableBoard.isCheck(color: .white) else {
        throw InvalidMove(notation: notation)
      }

      board = mutableBoard
      board[.f1] = board.removeValue(forKey: .h1)

    case ("O-O-O", .black):
      guard !board.isCheck(color: .black), !kingsMoved.black, !rooksMoved.black.queenside, board[.c8] == nil,
            board[.d8] == nil, board[.a8] == Piece(color: .black, figure: .rook) else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board
      mutableBoard[.d8] = mutableBoard.removeValue(forKey: .e8)
      guard !mutableBoard.isCheck(color: .black) else {
        throw InvalidMove(notation: notation)
      }

      mutableBoard[.c8] = mutableBoard.removeValue(forKey: .d8)
      guard !mutableBoard.isCheck(color: .black) else {
        throw InvalidMove(notation: notation)
      }

      board = mutableBoard
      board[.d8] = board.removeValue(forKey: .a8)

    case ("O-O-O", .white):
      guard !board.isCheck(color: .white), !kingsMoved.white, !rooksMoved.white.queenside, board[.c1] == nil,
            board[.d1] == nil, board[.a1] == Piece(color: .white, figure: .rook) else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board
      mutableBoard[.d1] = mutableBoard.removeValue(forKey: .e1)
      guard !mutableBoard.isCheck(color: .white) else {
        throw InvalidMove(notation: notation)
      }

      mutableBoard[.c1] = mutableBoard.removeValue(forKey: .d1)
      guard !mutableBoard.isCheck(color: .white) else {
        throw InvalidMove(notation: notation)
      }

      board = mutableBoard
      board[.d1] = board.removeValue(forKey: .a1)

    default:
      let isCapture = notation.contains("x")
      let filteredNotation = notation.filter { !["x", "+", "#"].contains($0) }

      let nextIndex = filteredNotation.index(after: filteredNotation.startIndex)
      let piece: Piece
      var destinationNotation: Substring
      if let figure = Piece.Figure(filteredNotation.first!) {
        destinationNotation = filteredNotation[nextIndex..<filteredNotation.endIndex]
        piece = Piece(color: nextMoveColor, figure: figure)
      } else {
        if isCapture {
          destinationNotation = filteredNotation[nextIndex..<filteredNotation.endIndex]
        } else {
          destinationNotation = filteredNotation[filteredNotation.startIndex..<filteredNotation.endIndex]
        }
        piece = Piece(color: nextMoveColor, figure: .pawn)
      }

      let promotedPiece: Piece?
      if let pieceNotation = destinationNotation.last, pieceNotation.isUppercase {
        guard let figure = Piece.Figure(pieceNotation), figure != .king, figure != .pawn else {
          throw InvalidMove(notation: notation)
        }
        promotedPiece = Piece(color: nextMoveColor, figure: figure)
        destinationNotation = destinationNotation.dropLast(2)
      } else {
        promotedPiece = nil
      }

      // Parse disambiguation notation from input
      let disambiguationFile: Square.File?
      let disambiguationRank: Square.Rank?
      if destinationNotation.count == 4 {
        guard let rank = Square.Rank(destinationNotation.first!) else {
          throw InvalidMove(notation: notation)
        }
        disambiguationRank = rank
        destinationNotation = destinationNotation.dropFirst()

        guard let file = Square.File(destinationNotation.first!) else {
          throw InvalidMove(notation: notation)
        }
        disambiguationFile = file
        destinationNotation = destinationNotation.dropFirst()
      } else if destinationNotation.count == 3 && Square.File.allCases.map(\.rawValue).contains(String(destinationNotation.first!)) {
        disambiguationFile = Square.File(destinationNotation.first!)!
        disambiguationRank = nil
        destinationNotation = destinationNotation.dropFirst()
      } else if destinationNotation.count == 3 {
        guard let rank = Square.Rank(destinationNotation.first!) else {
          throw InvalidMove(notation: notation)
        }
        disambiguationFile = nil
        disambiguationRank = rank
        destinationNotation = destinationNotation.dropFirst()
      } else if piece.figure == .pawn {
        disambiguationFile = Square.File(filteredNotation.first!)
        disambiguationRank = nil
      } else {
        disambiguationFile = nil
        disambiguationRank = nil
      }

      guard let targetSquare = Square(notation: String(destinationNotation)) else {
        throw InvalidMove(notation: notation)
      }

      let isEnPassantCapture: Bool
      if isCapture {
        switch nextMoveColor {
        case .white:
          isEnPassantCapture = piece.figure == .pawn &&
            targetSquare.file == enPassantCapture?.file &&
            targetSquare.rank - 1 == enPassantCapture?.rank
        case .black:
          isEnPassantCapture = piece.figure == .pawn &&
            targetSquare.file == enPassantCapture?.file &&
            targetSquare.rank + 1 == enPassantCapture?.rank
        }
        guard isEnPassantCapture || board[targetSquare] != nil else {
          throw InvalidMove(notation: notation)
        }
      } else {
        isEnPassantCapture = false
      }

      // Find eligible piece(s).
      let pieces = board.filter { square, squarePiece in
        squarePiece == piece &&
        (isCapture ? board.capturesFromSquare(square) : board.movesFromSquare(square)).contains(targetSquare) &&
        (disambiguationFile == nil || square.file == disambiguationFile) &&
        (disambiguationRank == nil || square.rank == disambiguationRank)
      }

      guard let origin = pieces.first?.key, pieces.count == 1 else {
        throw InvalidMove(notation: notation)
      }

      var mutableBoard = board

      // Move piece.
      mutableBoard[targetSquare] = mutableBoard.removeValue(forKey: origin)

      // Enforce promotion.
      let isPromotion = (targetSquare.rank == .one || targetSquare.rank == .eight) && board[origin]?.figure == .pawn
      if let promotedPiece = promotedPiece {
        guard isPromotion else {
          throw InvalidMove(notation: notation)
        }
        mutableBoard[targetSquare] = promotedPiece
      } else if isPromotion {
        throw InvalidMove(notation: notation)
      }

      // Account for en passant captures.
      if isEnPassantCapture {
        mutableBoard[enPassantCapture!] = nil
      }

      // Do not allow moving into check.
      if mutableBoard.isCheck(color: nextMoveColor) {
        throw InvalidMove(notation: notation)
      }

      // Update board state.
      board = mutableBoard

      enPassantCapture = piece.figure == .pawn && abs(origin.rank - targetSquare.rank) == 2 ? targetSquare : nil

      switch origin {
      case .a1: rooksMoved.white.queenside = true
      case .a8: rooksMoved.white.kingside = true
      case .h1: rooksMoved.black.queenside = true
      case .h8: rooksMoved.white.queenside = true
      case .e1: kingsMoved.white = true
      case .e8: kingsMoved.black = true
      default: break
      }
    }

    if board.isCheck(color: nextMoveColor.opposite) {
      if board.isCheckmate(color: nextMoveColor.opposite) {
        outcome = .checkmate(victor: nextMoveColor)
        moves += [notation]
      } else {
        moves += [notation]
      }
    } else {
      moves += [notation]
    }
  }

  private var board: Board
  private var enPassantCapture: Square?
  private var kingsMoved = (black: false, white: false)
  private var rooksMoved = (black: (kingside: false, queenside: false), white: (kingside: false, queenside: false))
  private var nextMoveColor: Piece.Color { moves.count.isMultiple(of: 2) ? .white : .black }
  private var moves = [String]()
  private var outcome: Outcome?

  /// Designated initializer
  public init(board: Board = .defaultGameBoard) {
    self.board = board
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
    .appending("  \(outcome?.description ?? nextMoveColor.rawValue.capitalized.appending(" to move"))\n\n")
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

extension Game.Board {
  public static var defaultGameBoard: Game.Board {
    let allPieces: [Piece] = Piece.Color.allCases.flatMap { color in
      Piece.Figure.allCases.map { figure in
        Piece(color: color, figure: figure)
      }
    }
    return allPieces.reduce(into: Game.Board()) { result, piece in
      piece.startingSquares.forEach { square in
        result[square] = piece
      }
    }
  }

  fileprivate func capturesFromSquare(_ square: Square) -> [Square] {
    let piece = self[square]
    return piece.capturesFromSquare(square).compactMap { squares in
      for position in squares {
        let target = self[position]
        guard target?.color != piece?.color else {
          return nil
        }
        if target?.color == piece?.color.opposite {
          return position
        }
      }
      return nil
    }
  }

  fileprivate func isCheck(color: Piece.Color) -> Bool {
    filter { $0.value.color == color.opposite }.contains { square in
      capturesFromSquare(square.key).contains { square in
        self[square] == Piece(color: color, figure: .king)
      }
    }
  }

  fileprivate func isCheckmate(color: Piece.Color) -> Bool {
    !contains { square, piece in
      piece.color == color && movesFromSquare(square).contains { targetSquare in
        var board = self
        board[targetSquare] = board.removeValue(forKey: square)
        return !board.isCheck(color: color)
      }
    }
  }

  fileprivate func movesFromSquare(_ square: Square) -> [Square] {
    self[square]?.movesFromSquare(square).flatMap {
      let upToIndex = $0.firstIndex {
        self[$0]?.color == self[square]!.color
      } ?? $0.endIndex

      let throughIndex = $0.firstIndex {
        self[$0]?.color == self[square]!.color.opposite
      }

      if let throughIndex = throughIndex, throughIndex < upToIndex {
        return $0.prefix(through: throughIndex)
      }

      return $0.prefix(upTo: upToIndex)
    } ?? []
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
