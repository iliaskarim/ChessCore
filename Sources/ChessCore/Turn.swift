enum Turn {
  enum Punctuation: String {
    case check = "+"

    case checkmate = "#"
  }

  case end(victor: Piece.Color?)

  case move(_ move: Move, punctuation: Punctuation?)
}

extension Turn: CustomStringConvertible {
  var description: String {
    switch self {
    case let .end(victor):
      switch victor {
      case .black:
        .blackVictoryNotation

      case .white:
        .whiteVictoryNotation

      case .none:
        .drawNotation
      }

    case let .move(move, punctuation):
      "\(move)\(punctuation?.description ?? "")"
    }
  }
}

extension Turn.Punctuation: CustomStringConvertible {
  var description: String {
    rawValue
  }
}
