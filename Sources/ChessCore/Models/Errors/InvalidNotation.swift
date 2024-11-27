
enum InvalidNotation: Error {
  enum BadPunctuation {
    case isCheck
    case isCheckmate
    case isNotCheck
    case isNotCheckmate
  }

  case ambiguous
  case badPunctuation(_: BadPunctuation)
  case noPossiblePiece
  case unparseable(notation: String)
}
