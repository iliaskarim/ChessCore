protocol BoardDataSource: AnyObject {
  var toMove: Piece.Color { get }

  func hasPieceMoved(_ piece: Piece, from square: Square) -> Bool
}
