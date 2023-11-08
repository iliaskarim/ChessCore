enum Direction: CaseIterable {
  static let cardinalDirections: [Self] = [.east, .north, .south, .west]
  static let latitudinalDirections: [Self] = [.north, .south]
  static let longitudinalDirections: [Self] = [.east, .west]

  case east
  case north
  case northEast
  case northWest
  case south
  case southEast
  case southWest
  case west

  var latitudinalOffset: Int {
    switch self {
    case .east, .west:
      return 0
    case .north, .northEast, .northWest:
      return 1
    case .south, .southEast, .southWest:
      return -1
    }
  }

  var longitudinalOffset: Int {
    switch self {
    case .east, .northEast, .southEast:
      return 1
    case .north, .south:
      return 0
    case .west, .northWest, .southWest:
      return -1
    }
  }
}
