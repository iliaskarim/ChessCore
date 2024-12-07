
enum InvalidNotation: Error {
  enum BadPunctuation {
    case isCheck
    case isCheckmate
    case isNotCheck
    case isNotCheckmate
  }

  case ambiguous
  case badMove
  case badPunctuation(_: BadPunctuation)
  case unparseable(notation: String)
}
