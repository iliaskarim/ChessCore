
// MARK: - Board

/// A model representing a chess board.
///
/// Chess boards consist of black and white figures arranged on an eight-by-eight grid.
public struct Board {
  typealias Mutation = (originSquare: Square, targetSquare: Square, promotion: Piece.Figure?)

  let pieces: [Square: Piece]

  let squaresTouched: [Square]

  let enPassant: Square?

  init(pieces: [Square : Piece], enPassant: Square? = nil, squaresTouched: [Square] = []) {
    self.pieces = pieces
    self.enPassant = enPassant
    self.squaresTouched = squaresTouched
  }
}
