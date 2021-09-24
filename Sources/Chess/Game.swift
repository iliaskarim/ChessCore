//
//  Game.swift
//  chess
//
//  Created by Ilias Karim on 7/15/21.
//  Copyright © 2021 Ilias Karim. All rights reserved.
//

import Foundation

extension Board.Square.Rank {
  static func - (lhs: Board.Square.Rank, rhs: Board.Square.Rank) -> Int {
    lhs.rawValue - rhs.rawValue
  }
}

public struct Game {
  public var victor: Piece.Color? {
    if case let .gameOver(outcome) = state {
      switch outcome {
      case let .checkMate(victor):
        return victor
      default: // to do:
        return nil
      }
    }
    return nil
  }

  struct InvalidMove: Error {
    let notation: String
  }

  private(set) var board = Board()

  private var nextToMove: Piece.Color {
    moves.count.isMultiple(of: 2) ? .white : .black
  }

  private var moves = [String]()

//  var isCheckmate = false // To do: compute variable

  public mutating func move(_ notation: String) throws {
    let notation = notation.filter { $0 != "+" && $0 != "#" }
    guard notation.count > 0 else { return }

    switch notation {
    case "1-0":
      break // to do
    case "0-1":
      break // to do
    case "1/2-1/2":
      break // to do
    case "O-O":
      break // to do
    case "O-O-O":
      break // to do
    default:
      break
    }

    let isCapture = notation.contains("x")
    let filteredNotation = notation.filter { !["x", "+", "#"].contains($0) }

    let figureNotation = filteredNotation[filteredNotation.startIndex..<filteredNotation.index(after: filteredNotation.startIndex)]
    let piece: Piece
    let destinationNotation: Substring
    if let figure = Piece.Figure(rawValue: String(figureNotation)) {
      destinationNotation = filteredNotation[filteredNotation.index(after: filteredNotation.startIndex)..<filteredNotation.endIndex]
      piece = Piece(color: nextToMove, figure: figure)
    } else {
      if isCapture {
        destinationNotation = filteredNotation[filteredNotation.index(after: filteredNotation.startIndex)..<filteredNotation.endIndex]
      } else {
        destinationNotation = filteredNotation[filteredNotation.startIndex..<filteredNotation.endIndex]
      }
      piece = Piece(color: nextToMove, figure: .pawn)
    }
    let destination = try Board.Square(notation: String(destinationNotation))

    var isEnPassantCapture: Bool
    if isCapture {
      switch nextToMove {
      case .white:
        if piece.figure == .pawn &&
          destination.file == enPassantCapture?.file &&
          destination.rank - 1 == enPassantCapture?.rank {
          isEnPassantCapture = true
        } else {
          guard board.squares[destination] != nil else {
            throw InvalidMove(notation: notation)
          }
          isEnPassantCapture = false
        }
      case .black:
        if piece.figure == .pawn &&
          destination.file == enPassantCapture?.file &&
          destination.rank + 1 == enPassantCapture?.rank {
          isEnPassantCapture = true
        } else {
          guard board.squares[destination] != nil else {
            throw InvalidMove(notation: notation)
          }
          isEnPassantCapture = false
        }
      }
    } else {
      isEnPassantCapture = false
    }

    // find piece origin
    // to do: assess if filtered count > 1 to disambiguate piece origin

    guard let origin = board.squares.filter({ _, squarePiece in
      squarePiece == piece
    }).first(where: { square, _ in
      if isCapture {
        return board.capturesFromSquare(square).contains(destination)
      } else {
        return board.movesFromSquare(square).contains(destination)
      }
    })?.key else {
      throw InvalidMove(notation: notation)
    }

    var mutableBoard = board

    // Move piece.
    mutableBoard.squares[origin] = nil
    mutableBoard.squares[destination] = piece
    // Account for en passant captures.
    if isEnPassantCapture {
      mutableBoard.squares[enPassantCapture!] = nil
    }

    // Do not allow moving into check.
    if mutableBoard.check(color: nextToMove) {
      throw InvalidMove(notation: notation)
    }

    board = mutableBoard

    if piece.figure == .pawn && abs(origin.rank - destination.rank) == 2 {
      enPassantCapture = destination
    } else {
      enPassantCapture = nil
    }

    if board.check(color: nextToMove.opposite) {
      moves += [notation + "+"]
    } else {
      moves += [notation]
    }

    // To do: check for getting out of checkmate via en passant capture
    // to do: factor looking for check into moves from square
    // to do: use "move" in place of "destination" ubiquitously
    let isCheckmate = !board.squares.contains { square, piece in
      piece.color == nextToMove && board.movesFromSquare(square).contains { move in
        var board = board
        let piece = board.squares[square]
        board.squares[square] = nil
        board.squares[move] = piece
        return !board.check(color: nextToMove)
      }
    }
    if isCheckmate {
      moves.removeLast()
      moves += [notation + "#"]
      state = .gameOver(outcome: .checkMate(victor: nextToMove.opposite))
    } else {
      if nextToMove == .black {
        state = .blackToMove
      } else {
        state = .whiteToMove
      }
    }
  }

  private var enPassantCapture: Board.Square?

  // to do: parse draws
  // to do: prase resignations

  private var state: State = .whiteToMove

  enum State: CustomStringConvertible {
    enum Outcome {
      case checkMate(victor: Piece.Color)
      case drawnGame
      case resignedGame(victor: Piece.Color?)
    }

    // to do: consolidate the following two states
    case whiteToMove
    case blackToMove
    case gameOver(outcome: Outcome)

    var description: String {
      switch self {
      case .whiteToMove:
        return "White to move"
      case .blackToMove:
        return "Black to move"
      case let .gameOver(outcome):
        return "Game over\n".appending({ () -> String in
          switch outcome {
          case let .checkMate(victor: color):
            return "  \(color.rawValue.capitalized) wins."
          default: return "TO DO"
          }
        }())
      }
    }
  }

  public init() {}
}

extension Game: CustomStringConvertible {
  public var description: String {
    (!moves.isEmpty ? stride(from: 0, to: moves.count, by: 2).map { i in
      "\(i/2+1). "
        .appending(moves[i])
        .appending(moves.count > i+1 ? " \(moves[i+1])" : "")
      }.joined(separator: "\n")
    .appending("\n\n") : "")
    .appending("  \(state.description)\n\n")
    .appending(board.description)
    }
}
