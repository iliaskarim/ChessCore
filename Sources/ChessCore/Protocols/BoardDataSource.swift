
protocol BoardDataSource: AnyObject {
  var enPassant: Square? { get set }

  var moveColor: Piece.Color { get }

  func hasPieceNotMoved(piece: Piece, square: Square) -> Bool
}
