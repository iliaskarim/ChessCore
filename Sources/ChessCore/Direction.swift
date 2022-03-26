//
//  Direction.swift
//  chess
//
//  Created by Ilias Karim on 3/26/22.
//  Copyright © 2022 Ilias Karim. All rights reserved.
//

struct Direction {
  enum HorizontalAxis: Int, CaseIterable {
    case east = 1
    case west = -1

    var direction: Direction { Direction(horizontalAxis: self, verticalAxis: nil) }
  }

  enum VerticalAxis: Int, CaseIterable {
    case north = 1
    case south = -1

    var direction: Direction { Direction(horizontalAxis: nil, verticalAxis: self) }
  }

  static let allDirections = cardinalDirections + diagonalDirections
  static let cardinalDirections: [Direction] = HorizontalAxis.allCases.map(\.direction) + VerticalAxis.allCases.map(\.direction)
  static let diagonalDirections: [Direction] = HorizontalAxis.allCases.flatMap { horizontalDirection in
    VerticalAxis.allCases.map { verticalDirection in
      Direction(horizontalAxis: horizontalDirection, verticalAxis: verticalDirection)
    }
  }

  let horizontalAxis: HorizontalAxis?
  let verticalAxis: VerticalAxis?
}

extension Optional where Wrapped == Direction.HorizontalAxis {
  var translation: Int { self?.rawValue ?? 0 }
}

extension Optional where Wrapped == Direction.VerticalAxis {
  var translation: Int { self?.rawValue ?? 0 }
}

