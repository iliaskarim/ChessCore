private extension Piece {
  var files: [Square.File] {
    switch figure {
    case .king:
      [.e]

    case .queen:
      [.d]

    case .rook:
      [.a, .h]

    case .bishop:
      [.c, .f]

    case .knight:
      [.b, .g]

    case .pawn:
      Square.File.allCases
    }
  }

  var rank: Square.Rank {
    switch figure {
    case .pawn:
      color.pawnRank

    default:
      color.backRank
    }
  }

  func capturePaths(from square: Square) -> [[Square]] {
    switch figure {
    case .pawn:
      square.singleStepPaths(for: [-1, 1].map { files in
        .init(files: files, ranks: color.forwardUnitVector.ranks)
      })

    default:
      nonCapturePaths(from: square)
    }
  }

  func nonCapturePaths(from square: Square) -> [[Square]] {
    switch (figure, square.rank) {
    case (.king, _):
      square.singleStepPaths(for: .cardinalUnitVectors + .diagonalUnitVectors)

    case (.queen, _):
      square.linearPaths(for: .cardinalUnitVectors + .diagonalUnitVectors)

    case (.rook, _):
      square.linearPaths(for: .cardinalUnitVectors)

    case (.bishop, _):
      square.linearPaths(for: .diagonalUnitVectors)

    case (.knight, _):
      square.singleStepPaths(for: .knightVectors)

    case (.pawn, color.pawnRank):
      [[color.pawnSinglePushTargetRank, color.pawnDoublePushTargetRank].map { rank in
        .init(file: square.file, rank: rank)
      }]

    case (.pawn, _):
      square.singleStepPaths(for: [color.forwardUnitVector])
    }
  }

  func promotions(for targetSquare: Square) -> [Piece.Figure?] {
    (figure == .pawn && targetSquare.rank == color.opposite.backRank) ?
      [.queen, .rook, .bishop, .knight]
      : [nil]
  }
}

private extension Square {
  func linearPaths(for vectors: [Board.Vector]) -> [[Self]] {
    vectors.compactMap(linearPath)
  }

  func singleStepPaths(for vectors: [Board.Vector]) -> [[Self]] {
    vectors.compactMap { vector in
      (self + vector).map { square in
        [square]
      }
    }
  }

  private func linearPath(for vector: Board.Vector) -> [Self] {
    (self + vector).map { square in
      [square] + square.linearPath(for: vector)
    } ?? []
  }
}

/// An 8x8 chessboard where each square may hold a piece.
///
/// A board represents a position and provides move generation plus status
/// evaluation for checks, checkmates, and stalemates.
public struct Board {
  /// A board's status.
  ///
  /// A position is in check, is checkmate, or is stalemate.
  public enum Status {
    /// The side to move is in check.
    case check

    /// The side to move is checkmated.
    case checkmate

    /// The side to move has no legal moves and is not in check.
    case stalemate
  }

  /// One step of a move, applied to a board.
  public typealias Transform = (Board) -> Board

  struct Vector {
    let files: Int

    let ranks: Int
  }

  /// Standard chess starting position.
  ///
  /// White pieces start on ranks 1 and 2. Black pieces start on ranks 7 and 8.
  public static var board: Board {
    .init(pieces: .init(uniqueKeysWithValues: Piece.Color.allCases.flatMap { color in
      Piece.Figure.allCases.map { figure in
        Piece(color: color, figure: figure)
      }
    }
    .flatMap { piece in
      piece.files.map { file in
        (.init(file: file, rank: piece.rank), piece)
      }
    }))
  }

  /// Retrieves the piece located at a specific square on the board.
  ///
  /// - Parameters:
  ///   - square: The square on the board whose piece to retrieve.
  /// - Returns: The piece at the given square, or `nil` if the square is empty.
  public subscript(square: Square) -> Piece? {
    pieces[square]
  }

  /// Board status.
  public var status: Status? {
    switch (isInCheck, isNoMovePossible) {
    case (true, false):
      .check

    case (true, true):
      .checkmate

    case (false, true):
      .stalemate

    default:
      nil
    }
  }

  weak var dataSource: BoardDataSource?

  fileprivate let enPassantSquare: Square?

  fileprivate let pieces: [Square: Piece]

  private var isInCheck: Bool {
    pieces.contains { square, piece in
      piece.capturePaths(from: square).compactMap { path in
        captureSquare(for: piece, on: path)
      }
      .contains { targetSquare in
        pieces[targetSquare] == .init(color: toMove, figure: .king)
      }
    }
  }

  private var isNoMovePossible: Bool {
    !pieces.contains { square, piece in
      !legalMoves(for: piece, from: square).isEmpty
    }
  }

  private var toMove: Piece.Color {
    dataSource?.toMove ?? .white
  }

  /// Retrieves the moves that can be made from a specific square on the board.
  ///
  /// - Parameters:
  ///   - square: The square on the board from which to retrieve possible moves.
  /// - Returns: A dictionary whose keys are each destination square and whose
  ///   values are the moves that end on that square.
  public func moves(from square: Square) -> [Square: [AnyMove]] {
    self[square].map { piece in
      .init(grouping: legalMoves(for: piece, from: square)) { move in
        move.targetSquare(for: piece.color)
      }
    } ?? [:]
  }

  func applying(move: some Move & Hashable) throws -> Self {
    let matchingMoves = flatMap { square, piece in
      moves(for: piece, from: square, isCapture: move.isCapture)
        .filter { candidate in
          candidate.figure == move.figure
            && candidate.isCapture == move.isCapture
            && candidate.promotion == move.promotion
            && candidate.targetSquare(for: piece.color) == move.targetSquare(for: piece.color)
            && (candidate.disambiguationFile == nil || move.disambiguationFile == nil
              || candidate.disambiguationFile == move.disambiguationFile)
            && (candidate.disambiguationRank == nil || move.disambiguationRank == nil
              || candidate.disambiguationRank == move.disambiguationRank)
        }
        .map { candidate in
          (candidate, piece, square)
        }
    }

    guard matchingMoves.count < 2 else {
      throw MoveError.ambiguousMove(candidates: matchingMoves.map(\.0))
    }

    guard let (candidate, piece, square) = matchingMoves.first else {
      throw MoveError.illegalMove
    }

    return try applying(candidate.transforms(for: piece, from: square))
  }

  init(pieces: [Square: Piece], enPassantSquare: Square? = nil) {
    self.pieces = pieces
    self.enPassantSquare = enPassantSquare
  }

  private func applying(_ transforms: [Transform]) throws -> Self {
    try transforms.reduce(self) { board, transform in
      var transformedBoard = transform(board)
      transformedBoard.dataSource = dataSource
      guard !transformedBoard.isInCheck else {
        throw MoveError.illegalMoveIntoCheck
      }

      return transformedBoard
    }
  }

  private func captureSquare(for piece: Piece, on path: [Square]) -> Square? {
    path.first { square in
      pieces[square]?.color == piece.color.opposite
    }
  }

  private func hasPieceMoved(_ piece: Piece, from square: Square) -> Bool {
    dataSource?.hasPieceMoved(piece, from: square) ?? false
  }

  private func legalMoves(for piece: Piece, from square: Square) -> [AnyMove] {
    (
      moves(for: piece, from: square, isCapture: false) +
        moves(for: piece, from: square, isCapture: true)
    )
    .filter { move in
      (try? applying(move.transforms(for: piece, from: square))) != nil
    }
  }

  private func moves(for piece: Piece, from square: Square, isCapture: Bool) -> [AnyMove] {
    guard piece.color == toMove else {
      return []
    }

    let targetSquares = if isCapture {
      piece.capturePaths(from: square).flatMap { path in
        if let enPassantSquare,
           let first = path.first,
           piece.figure == .pawn,
           first == enPassantSquare + piece.color.forwardUnitVector {
          [first]
        } else {
          captureSquare(for: piece, on: path).map { square in
            [square]
          } ?? []
        }
      }
    } else {
      piece.nonCapturePaths(from: square).flatMap { path in
        path.prefix { square in
          pieces[square] == nil
        }
      }
    }

    let moves = targetSquares.flatMap { targetSquare in
      piece.promotions(for: targetSquare).map { promotion in
        AnyMove(Translation(
          figure: piece.figure,
          targetSquare: targetSquare,
          isCapture: isCapture,
          promotion: promotion,
          disambiguationFile: square.file,
          disambiguationRank: square.rank
        ))
      }
    }

    guard piece == .init(color: toMove, figure: .king),
          square == .init(file: .e, rank: toMove.backRank),
          !hasPieceMoved(piece, from: square),
          !isCapture,
          !isInCheck else {
      return moves
    }

    let castlingMoves = Castling.allCases.filter { castling in
      let rookSquare = castling.rookSquare(for: toMove)
      let rook = Piece(color: toMove, figure: .rook)
      return pieces[rookSquare] == rook
        && !castling.requiredEmptySquares(for: toMove).contains(where: pieces.keys.contains)
        && !hasPieceMoved(rook, from: rookSquare)
    }
    .map(AnyMove.init)
    return moves + castlingMoves
  }
}

extension Square? {
  static func + (lhs: Self, rhs: Board.Vector) -> Self {
    guard let lhs,
          let file = Wrapped.File(rawValue: lhs.file.rawValue + rhs.files),
          let rank = Wrapped.Rank(rawValue: lhs.rank.rawValue + rhs.ranks) else {
      return nil
    }

    return .init(file: file, rank: rank)
  }
}

extension Board: Collection {
  public typealias Index = [Square: Piece].Index

  public subscript(position: Index) -> (key: Square, value: Piece) {
    pieces[position]
  }

  public var endIndex: Index {
    pieces.endIndex
  }

  public var startIndex: Index {
    pieces.startIndex
  }

  public func index(after i: Index) -> Index {
    pieces.index(after: i)
  }
}

extension Board: CustomDebugStringConvertible {
  public var debugDescription: String {
    Square.Rank.allCases.reversed().map { rank in
      "\(rank) ".appending(Square.File.allCases.map { file in
        pieces[.init(file: file, rank: rank)]?.debugDescription ?? " "
      }
      .joined(separator: " "))
    }
    .joined(separator: "\n")
    .appending("\n  \(Square.File.allCases.map(\.description).joined(separator: " "))")
  }
}

extension Board: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Square, Piece)...) {
    self.init(pieces: .init(uniqueKeysWithValues: elements))
  }
}

extension Board.Status: CustomStringConvertible {
  public var description: String {
    switch self {
    case .check:
      .check

    case .checkmate:
      .checkmate

    case .stalemate:
      .stalemate
    }
  }
}

private extension [Board.Vector] {
  static let cardinalUnitVectors: Self = [-1, 0, 1].flatMap { files in
    [-1, 0, 1].filter { ranks in
      abs(files) != abs(ranks)
    }
    .map { ranks in
      .init(files: files, ranks: ranks)
    }
  }

  static let diagonalUnitVectors: Self = [-1, 1].flatMap { files in
    [-1, 1].map { ranks in
      .init(files: files, ranks: ranks)
    }
  }

  static let knightVectors: Self = [-2, -1, 1, 2].flatMap { files in
    [-2, -1, 1, 2].filter { ranks in
      abs(files) != abs(ranks)
    }
    .map { ranks in
      .init(files: files, ranks: ranks)
    }
  }
}
