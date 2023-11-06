struct Direction {
  enum Horizontal: Int, CaseIterable {
    case east = 1
    case west = -1

    var direction: Direction { 
      Direction(horizontal: self, vertical: nil)
    }
  }

  enum Vertical: Int, CaseIterable {
    case north = 1
    case south = -1

    var direction: Direction { 
      Direction(horizontal: nil, vertical: self)
    }
  }

  static let allDirections = cardinalDirections + diagonalDirections
  static let cardinalDirections: [Direction] = Horizontal.allCases.map(\.direction) + Vertical.allCases.map(\.direction)
  static let diagonalDirections: [Direction] = Horizontal.allCases.flatMap { horizontalDirection in
    Vertical.allCases.map { verticalDirection in
      Direction(horizontal: horizontalDirection, vertical: verticalDirection)
    }
  }

  let horizontal: Horizontal?
  let vertical: Vertical?
}

extension Optional where Wrapped == Direction.Horizontal {
  var translation: Int { self?.rawValue ?? 0 }
}

extension Optional where Wrapped == Direction.Vertical {
  var translation: Int { self?.rawValue ?? 0 }
}

