
enum IllegalMove: Error {
  enum CannotCastle {
    case inCheck
    case obstructed
    case pieceMoved(figure: Piece.Figure)
    case pieceOutOfPosition(figure: Piece.Figure)
  }

  case cannotCastle(_: CannotCastle)
  case cannotMoveIntoCheck
  case cannotPromoteToFigure
  case figureCannotPromote
  case figureMustPromote
  case mustReachEndOfBoardToPromote
}
