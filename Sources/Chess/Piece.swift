//
//  Piece.swift
//  chess
//
//  Created by Ilias Karim on 7/15/21.
//  Copyright © 2021 Ilias Karim. All rights reserved.
//

extension Board.Square {
  enum Direction: CaseIterable {
    case north
    case west
    case south
    case east
    case northWest
    case southWest
    case southEast
    case northEast

    var file: Int {
      switch self {
      case .west, .northWest, .southWest:
        return -1
      case .east, .northEast, .southEast:
        return 1
      default:
        return 0
      }
    }

    var rank: Int {
      switch self {
      case .north, .northWest, .northEast:
        return 1
      case .south, .southWest, .southEast:
        return -1
      default:
        return 0
      }
    }
  }

  func allSquaresInDirection(_ direction: Direction) -> [Self] {
    guard let squareInDirection = squareInDirection(direction) else { return [] }
    return [squareInDirection] + squareInDirection.allSquaresInDirection(direction)
  }

  func squareInDirection(_ direction: Direction) -> Self? {
    Self.init(file: file + direction.file, rank: rank + direction.rank)
  }
}

/// Piece
public struct Piece: Equatable {
  /// Color
  public enum Color: String {
    case white
    case black

    var opposite: Color {
      switch self {
      case .white: return .black
      case .black: return .white
      }
    }
  }

  /// Figure
  public enum Figure: String {
    case pawn = "X"
    case knight = "N"
    case bishop = "B"
    case rook = "R"
    case queen = "Q"
    case king = "K"
  }

  func capturesFromSquare(_ square: Board.Square) -> [[Board.Square]] {
    if case .pawn = figure {
      switch color {
      case .white:
        let directions: [Board.Square.Direction] = [.northWest, .northEast]
        return directions.compactMap { square.squareInDirection($0) }.map { [$0] }
      case .black:
        let directions: [Board.Square.Direction] = [.southEast, .southWest]
        return directions.compactMap { square.squareInDirection($0) }.map { [$0] }
      }
    }
    return movesFromSquare(square)
  }

  func movesFromSquare(_ square: Board.Square) -> [[Board.Square]] {
    switch self.figure {
    case .king:
      return Board.Square.Direction.allCases.compactMap { direction in
        square.squareInDirection(direction)
      }.map { [$0] }

    case .queen:
      return Piece(color: color, figure: .rook).movesFromSquare(square) +
        Piece(color: color, figure: .bishop).movesFromSquare(square)

    case .rook:
      let directions: [Board.Square.Direction] = [
        .north, .west, .south, .east
      ]
      return directions.map { direction in
        square.allSquaresInDirection(direction)
      }

    case .bishop:
      let directions: [Board.Square.Direction] = [
        .northWest, .northEast, .southWest, .southEast
      ]
      return directions.map { direction in
        square.allSquaresInDirection(direction)
      }

    case .knight:
      let directions: [(Int, Int)] = [
        (-2, -1), (-2, 1), (2, -1), (2, 1),
        (-1, -2), (-1, 2), (1, -2), (1, 2)
      ]
      return directions.map { direction in
        Board.Square(file: square.file + direction.0, rank: square.rank - direction.1)
      }.compactMap { $0 }.map { [$0] }

    case .pawn:
      switch color {
      case .white:
        return [[
          Board.Square(file: square.file, rank: (square.rank + 1)!)] +
          (square.rank == .two ? [Board.Square(file: square.file, rank: .four)] : [])]

      case .black:
        return [[
          Board.Square(file: square.file, rank: (square.rank - 1)!)] +
          (square.rank == .seven ? [Board.Square(file: square.file, rank: .five)] : [])]
      }
    }
  }

  /// Color
  public let color: Color

  /// Figure
  public let figure: Figure
}
