//
//  Game.swift
//  chess
//
//  Created by Ilias Karim on 7/15/21.
//  Copyright © 2021 Ilias Karim. All rights reserved.
//

import Foundation

// MARK: - Directions
private typealias Direction = (vertical: Vertical?, horizontal: Horizontal?)

private enum Horizontal: Int, CaseIterable {
  case east = 1
  case west = -1

  var direction: Direction {
    (vertical: nil, horizontal: self)
  }
}

private extension Optional where Wrapped == Horizontal {
  var integerValue: Int {
    self?.rawValue ?? 0
  }
}

private enum Vertical: Int, CaseIterable {
  case north = 1
  case south = -1

  var direction: Direction {
    (vertical: self, horizontal: nil)
  }
}

private extension Optional where Wrapped == Vertical {
  var integerValue: Int {
    self?.rawValue ?? 0
  }
}

// MARK: - Piece
fileprivate extension Piece {
  var startingSquares: [Square] {
    switch figure {
    case .pawn:
      return Square.File.allCases.map({ (file: $0, rank: color == .white ? .two : .seven) }).map(Square.init)

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

  func movesFromSquare(_ square: Square) -> [[Square]] {
    switch self.figure {
    case .bishop:
      return Square.diagonalDirections.map(square.allSquaresInDirection)

    case .knight:
      return [(-2, -1), (-2, 1), (2, -1), (2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2)]
        .compactMap { direction in
          Square(file: square.file + direction.0, rank: square.rank + direction.1)
        }.map { [$0] }

    case .king:
      return Square.allDirections.compactMap(square.squareInDirection).map { [$0] }

    case .queen:
      return Square.allDirections.map(square.allSquaresInDirection)

    case .pawn:
      let direction = color == .white ? 1 : -1
      let startRank: Square.Rank = color == .white ? .two : .seven
      return [
        Square(file: square.file, rank: square.rank + direction),
        (square.rank == startRank) ? Square(file: square.file, rank: square.rank + direction * 2) : nil
      ].compactMap { $0 }.map { [$0] }

    case .rook:
      return Square.cardinalDirections.map(square.allSquaresInDirection)
    }
  }
}

extension Optional where Wrapped == Piece {
  func capturesFromSquare(_ square: Square) -> [[Square]] {
    switch self?.figure {
    case .some(.pawn):
      let directions: [Direction]
      switch self!.color {
      case .black:
        directions = [(.south, .east), (.south, .west)]
      case .white:
        directions = [(.north, .west), (.north, .east)]
      }
      return directions.compactMap(square.squareInDirection).map { [$0] }

    default:
      return self?.movesFromSquare(square) ?? []
    }
  }
}

// MARK: - Square
fileprivate extension Square {
  enum InvalidNotationError: Error {
    case incorrectLength(length: Int)
    case invalidFileName(name: String)
    case invalidRankIndex(index: String)
  }

  static var allDirections = cardinalDirections + diagonalDirections
  static var cardinalDirections: [Direction] = Horizontal.allCases.map(\.direction) + Vertical.allCases.map(\.direction)
  static var diagonalDirections: [Direction] = Horizontal.allCases.flatMap { horizontalDirection in
    Vertical.allCases.map { verticalDirection in
      (verticalDirection, horizontalDirection)
    }
  }

  func allSquaresInDirection(_ direction: Direction) -> [Self] {
    guard let squareInDirection = squareInDirection(direction) else { return [] }
    return [squareInDirection] + squareInDirection.allSquaresInDirection(direction)
  }

  func squareInDirection(_ direction: Direction) -> Self? {
    Self.init(file: file + direction.horizontal.integerValue, rank: rank + direction.vertical.integerValue)
  }

  init(notation: String) throws {
    guard notation.count == 2 else {
      throw InvalidNotationError.incorrectLength(length: notation.count)
    }

    let fileName = String(notation.first!)
    guard let file = File(rawValue: fileName) else {
      throw InvalidNotationError.invalidFileName(name: fileName)
    }

    let rankIndexString = notation[notation.index(notation.startIndex, offsetBy: 1)..<notation.endIndex]
    guard let rankIndex = Int(rankIndexString), let rank = Rank(rawValue: rankIndex) else {
      throw InvalidNotationError.invalidRankIndex(index: String(rankIndexString))
    }

    self.init(file: file, rank: rank)
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
  struct InvalidMove: Error {
    /// Notation
    let notation: String

    /// Underlying error
    let underlyingError: Error?

    init(notation: String, underlyingError: Error? = nil) {
      self.notation = notation
      self.underlyingError = underlyingError
    }
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
    let notation = notation.filter { $0 != "+" && $0 != "#" } // TO DO: validate + / #
    guard notation.count > 0 else { return }

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

      moves += [notation]
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

      moves += [notation]
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

      moves += [notation]
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

      moves += [notation]
      board = mutableBoard
      board[.d1] = board.removeValue(forKey: .a1)

    default:
      let isCapture = notation.contains("x") // to do: validate POSITION of the x
      let isCheck = notation.contains("+") // to do: validate
      let isCheckmate = notation.contains("#") // to do: validate
      let filteredNotation = notation.filter { !["x", "+", "#"].contains($0) }

      let figureNotation = filteredNotation.first!
      let nextIndex = filteredNotation.index(after: filteredNotation.startIndex)
      let piece: Piece
      var destinationNotation: Substring
      if let figure = Piece.Figure(rawValue: String(figureNotation)) {
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
        guard let figure = Piece.Figure(rawValue: String(pieceNotation)), figure != .king, figure != .pawn else {
          throw InvalidMove(notation: notation)
        }
        promotedPiece = Piece(color: nextMoveColor, figure: figure)
        destinationNotation = destinationNotation.dropLast()
      } else {
        promotedPiece = nil
      }

      // Parse disambiguation notation from input
      let disambiguationFile: Square.File?
      let disambiguationRank: Square.Rank?
      if destinationNotation.count == 4 {
        guard let rankInt = Int(String(destinationNotation.first!)), let rank = Square.Rank(rawValue: rankInt) else {
          throw InvalidMove(notation: notation)
        }
        disambiguationRank = rank

        destinationNotation = destinationNotation.dropFirst()

        guard let file = Square.File(rawValue: String(destinationNotation.first!)) else {
          throw InvalidMove(notation: notation)
        }
        disambiguationFile = file

        destinationNotation = destinationNotation.dropFirst()
      } else if destinationNotation.count == 3 && Square.File.allCases.map(\.rawValue).contains(String(destinationNotation.first!)) {

        disambiguationFile = Square.File(rawValue: String(destinationNotation.first!))!
        disambiguationRank = nil

        destinationNotation = destinationNotation.dropFirst()
      } else if destinationNotation.count == 3 {
        guard let rankInt = Int(String(destinationNotation.first!)), let rank = Square.Rank(rawValue: rankInt) else {
          throw InvalidMove(notation: notation)
        }

        disambiguationFile = nil
        disambiguationRank = rank
      } else {
        disambiguationFile = nil
        disambiguationRank = nil
      }

      let targetSquare: Square
      do {
        targetSquare = try Square(notation: String(destinationNotation))
      } catch {
        throw InvalidMove(notation: notation, underlyingError: error)
      }

      let isEnPassantCapture: Bool
      if isCapture {
        switch nextMoveColor {
        case .white:
          if piece.figure == .pawn &&
            targetSquare.file == enPassantCapture?.file &&
            targetSquare.rank - 1 == enPassantCapture?.rank {
            isEnPassantCapture = true
          } else {
            guard board[targetSquare] != nil else {
              throw InvalidMove(notation: notation)
            }
            isEnPassantCapture = false
          }
        case .black:
          if piece.figure == .pawn &&
            targetSquare.file == enPassantCapture?.file &&
            targetSquare.rank + 1 == enPassantCapture?.rank {
            isEnPassantCapture = true
          } else {
            guard board[targetSquare] != nil else {
              throw InvalidMove(notation: notation)
            }
            isEnPassantCapture = false
          }
        }
      } else {
        isEnPassantCapture = false
      }

      // Find eligible piece(s).
      let pieces = board.filter { square, squarePiece in
        squarePiece == piece &&
        (isCapture ? board.capturesFromSquare(square) : board.movesFromSquare(square)).contains(targetSquare) &&
        (square.file == disambiguationFile || disambiguationFile == nil) &&
        (square.rank == disambiguationRank || disambiguationRank == nil)
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
        moves += [notation + "#"]
      } else {
        moves += [notation + "+"]
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

public extension Game.Board {
  static var defaultGameBoard: Game.Board {
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
}

private extension Game.Board {
  func capturesFromSquare(_ square: Square) -> [Square] {
    self[square].capturesFromSquare(square).compactMap { path in
      path.first { captureSquare in
        self[square]?.color == self[captureSquare]?.color.opposite
      }
    }
  }

  func isCheck(color: Piece.Color) -> Bool {
    filter { $0.value.color == color.opposite }.contains { square in
      capturesFromSquare(square.key).contains { square in
        self[square] == Piece(color: color, figure: .king)
      }
    }
  }

  func isCheckmate(color: Piece.Color) -> Bool {
    !contains { square, piece in
      piece.color == color && movesFromSquare(square).contains { targetSquare in
        var board = self
        board[targetSquare] = board.removeValue(forKey: square)
        return !board.isCheck(color: color)
      }
    }
  }

  func movesFromSquare(_ square: Square) -> [Square] {
    self[square]?.movesFromSquare(square).filter { !$0.isEmpty && self[$0[0]] == nil }.flatMap { sequence in
      sequence.prefix(through: (sequence.firstIndex { targetSquare in
        self[targetSquare] != nil
      } ?? sequence.index(before: sequence.endIndex)))
    } ?? []//.filter { self[$0]?.color != self[square]!.color } ?? []
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
