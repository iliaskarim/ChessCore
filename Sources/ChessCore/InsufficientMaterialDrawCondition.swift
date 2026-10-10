/// Draw by insufficient mating material.
public struct InsufficientMaterialDrawCondition: DrawCondition {
  public static var name: String {
    "insufficient material"
  }

  public static func isDraw(in context: DrawContext) -> Bool {
    let nonKingPieces = context.board.compactMap { square, piece in
      piece.figure == .king ? nil : (square, piece)
    }

    guard !nonKingPieces.contains(where: { _, piece in
      piece.figure != .bishop && piece.figure != .knight
    }) else {
      return false
    }

    if nonKingPieces.isEmpty {
      return true
    }

    if nonKingPieces.count == 1 {
      return true
    }

    guard nonKingPieces.allSatisfy({ _, piece in piece.figure == .bishop }) else {
      return false
    }

    return Set(nonKingPieces.map { square, _ in
      square.colorComplex
    }).count == 1
  }
}

private extension Square {
  var colorComplex: Int {
    (file.rawValue + rank.rawValue) % 2
  }
}
