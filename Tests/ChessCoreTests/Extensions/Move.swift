import ChessCore

extension Move.Translation {
  init(
    figure: Piece.Figure,
    targetSquare: Square,
    isCapture: Bool = false,
    promotion: Piece.Figure? = nil,
    disambiguationFile: Square.File? = nil,
    disambiguationRank: Square.Rank? = nil
  ) {
    self.init(
      figure: figure,
      isCapture: isCapture,
      promotion: promotion,
      disambiguationFile: disambiguationFile,
      disambiguationRank: disambiguationRank,
      targetSquare: targetSquare
    )
  }
}
