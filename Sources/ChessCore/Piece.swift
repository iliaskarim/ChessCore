//
//  Piece.swift
//  chess
//
//  Created by Ilias Karim on 7/15/21.
//  Copyright © 2021 Ilias Karim. All rights reserved.
//

fileprivate extension Square {
  typealias Direction = (vertical: VerticalDirection?, horizontal: HorizontalDirection?)

  enum HorizontalDirection: Int, CaseIterable {
    case east = 1
    case west = -1

    var direction: Direction {
      (vertical: nil, horizontal: self)
    }
  }

  enum VerticalDirection: Int, CaseIterable {
    case north = 1
    case south = -1

    var direction: Direction {
      (vertical: self, horizontal: nil)
    }
  }

  static var allDirections = cardinalDirections + diagonalDirections
  static var cardinalDirections: [Direction] = HorizontalDirection.allCases.map(\.direction) + VerticalDirection.allCases.map(\.direction)
  static var diagonalDirections: [Direction] = HorizontalDirection.allCases.flatMap { horizontalDirection in
    VerticalDirection.allCases.map { verticalDirection in
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
}

private extension Optional where Wrapped == Square.HorizontalDirection {
  var integerValue: Int {
    self?.rawValue ?? 0
  }
}

private extension Optional where Wrapped == Square.VerticalDirection {
  var integerValue: Int {
    self?.rawValue ?? 0
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

  /// Color
  public let color: Color

  /// Figure
  public let figure: Figure

  func capturesFromSquare(_ square: Square) -> [[Square]] {
    if case .pawn = figure {
      let directions: [Square.Direction] = color == .white ? [(.north, .west), (.north, .east)] : [(.south, .east), (.south, .west)]
      return directions.compactMap(square.squareInDirection).map { [$0] }
    }
    return movesFromSquare(square)
  }

  func movesFromSquare(_ square: Square) -> [[Square]] {
    switch self.figure {
    case .king:
      return Square.allDirections.compactMap(square.squareInDirection).map { [$0] }

    case .queen:
      return Square.allDirections.map(square.allSquaresInDirection)

    case .rook:
      return Square.cardinalDirections.map(square.allSquaresInDirection)

    case .bishop:
      return Square.diagonalDirections.map(square.allSquaresInDirection)

    case .knight:
      return [
        (-2, -1), (-2, 1), (2, -1), (2, 1),
        (-1, -2), (-1, 2), (1, -2), (1, 2)
      ].compactMap { direction in
        Square(file: square.file + direction.0, rank: square.rank - direction.1)
      }.map { [$0] }

    case .pawn:
      switch color {
      case .white:
        return [[
          Square(file: square.file, rank: (square.rank + 1)!)] +
          (square.rank == .two ? [Square(file: square.file, rank: .four)] : [])]

      case .black:
        return [[
          Square(file: square.file, rank: (square.rank - 1)!)] +
          (square.rank == .seven ? [Square(file: square.file, rank: .five)] : [])]
      }
    }
  }
}
