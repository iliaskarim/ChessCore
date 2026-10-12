private extension Square {
  var isLight: Bool {
    (file.rawValue + rank.rawValue).isMultiple(of: 2)
  }
}

/// Draw when neither side has enough material to checkmate.
public struct InsufficientMaterialDrawCondition: GameDrawCondition {
  public static let name = String.insufficientMaterial

  static func isDraw(
    board: Board,
    turns _: [Turn],
    positionIdentities _: [PositionIdentity]
  ) -> Bool {
    let material = board.pieces.filter { _, piece in
      piece.figure != .king
    }

    guard !material.isEmpty else {
      return true
    }

    if material.count == 1 {
      return [.bishop, .knight].contains(material.first!.value.figure)
    }

    return material.allSatisfy { _, piece in
      piece.figure == .bishop
    } && Set(material.map { square, _ in
      square.isLight
    }).count == 1
  }
}
