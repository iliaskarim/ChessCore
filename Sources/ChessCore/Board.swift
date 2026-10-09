private extension Move {
  var baseTranslation: Translation? {
    if let translation = self as? Translation {
      translation
    } else if let capture = self as? Capture {
      capture.translation
    } else if let promotion = self as? Promotion {
      promotion.move.baseTranslation
    } else {
      nil
    }
  }

  func targetSquare(for piece: Piece) -> Square {
    if let translation = baseTranslation {
      translation.targetSquare
    } else if let castle = self as? Castle {
      piece.color.castleKingTargetSquare(castle: castle)
    } else {
      preconditionFailure("Unknown move type")
    }
  }

  func transforms(for piece: Piece, from square: Square) -> [Board.Transform] {
    if let translation = baseTranslation {
      return [{ board in
        var pieces = board.pieces
        pieces[square] = nil
        pieces[translation.targetSquare] = .init(
          color: piece.color,
          figure: (self as? Promotion)?.figure ?? piece.figure
        )

        if let enPassantSquare = board.enPassantSquare,
           piece.figure == .pawn,
           translation.targetSquare == enPassantSquare + piece.color.forwardUnitVector {
          pieces[enPassantSquare] = nil
        }

        let targetSquare = translation.targetSquare
        let enPassantSquare: Square? = if piece.figure == .pawn,
                                          square.rank == piece.color.pawnRank,
                                          targetSquare.rank == piece.color.pawnDoublePushTargetRank {
          targetSquare
        } else {
          nil
        }

        return .init(pieces: pieces, enPassantSquare: enPassantSquare)
      }]
    } else if let castle = self as? Castle {
      let rook = Piece(color: piece.color, figure: .rook)
      let kingTargetSquare = piece.color.castleKingTargetSquare(castle: castle)
      let rookSquare = piece.color.castleRookSquare(castle: castle)
      let rookTargetSquare = Square(file: castle == .short ? .f : .d, rank: piece.color.backRank)

      // King must cross the transit square without moving through check.
      return [{ board in
        var pieces = board.pieces
        pieces[square] = nil
        pieces[rookTargetSquare] = piece
        return .init(pieces: pieces)
      }, { board in
        var pieces = board.pieces
        pieces[kingTargetSquare] = piece
        pieces[rookSquare] = nil
        pieces[rookTargetSquare] = rook
        return .init(pieces: pieces)
      }]
    } else {
      preconditionFailure("Unknown move type")
    }
  }
}

private func ~= (lhs: any Move, rhs: any Move) -> Bool {
  switch (lhs, rhs) {
  case let (lhsCastle as Castle, rhsCastle as Castle):
    lhsCastle == rhsCastle

  case let (lhsPromotion as Promotion, rhsPromotion as Promotion):
    lhsPromotion.figure == rhsPromotion.figure
      && lhsPromotion.move ~= rhsPromotion.move

  case let (lhsTranslation as Translation, rhsTranslation as Translation):
    lhsTranslation ~= rhsTranslation

  case let (lhsCapture as Capture, rhsCapture as Capture):
    lhsCapture.translation ~= rhsCapture.translation

  default:
    false
  }
}

private extension Translation {
  static func ~= (lhs: Self, rhs: Self) -> Bool {
    if let lhsFile = lhs.disambiguationFile, let rhsFile = rhs.disambiguationFile, lhsFile != rhsFile {
      return false
    }

    if let lhsRank = lhs.disambiguationRank, let rhsRank = rhs.disambiguationRank, lhsRank != rhsRank {
      return false
    }

    return lhs.figure == rhs.figure
      && lhs.targetSquare == rhs.targetSquare
  }
}

private extension Piece {
  var startFiles: [Square.File] {
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

  func paths(from square: Square, isCapture: Bool) -> [[Square]] {
    switch (figure, isCapture, square.rank) {
    case (.king, _, _):
      square.singleStepPaths(for: .cardinalUnitVectors + .diagonalUnitVectors)

    case (.queen, _, _):
      square.linearPaths(for: .cardinalUnitVectors + .diagonalUnitVectors)

    case (.rook, _, _):
      square.linearPaths(for: .cardinalUnitVectors)

    case (.bishop, _, _):
      square.linearPaths(for: .diagonalUnitVectors)

    case (.knight, _, _):
      square.singleStepPaths(for: [
        .init(files: -2, ranks: -1),
        .init(files: -2, ranks: 1),
        .init(files: -1, ranks: -2),
        .init(files: -1, ranks: 2),
        .init(files: 1, ranks: -2),
        .init(files: 1, ranks: 2),
        .init(files: 2, ranks: -1),
        .init(files: 2, ranks: 1)
      ])

    case (.pawn, false, color.pawnRank):
      [[
        .init(file: square.file, rank: color.pawnSinglePushTargetRank),
        .init(file: square.file, rank: color.pawnDoublePushTargetRank)
      ]]

    case (.pawn, false, _):
      square.singleStepPaths(for: [color.forwardUnitVector])

    case (.pawn, true, _):
      square.singleStepPaths(for: [
        .init(files: -1, ranks: color.forwardUnitVector.ranks),
        .init(files: 1, ranks: color.forwardUnitVector.ranks)
      ])
    }
  }

  func promotions(targetSquare: Square) -> [Piece.Figure?] {
    switch (figure, targetSquare.rank) {
    case (.pawn, color.opposite.backRank):
      [.queen, .rook, .bishop, .knight]

    default:
      [nil]
    }
  }
}

private extension Piece.Color {
  func castleKingTargetSquare(castle: Castle) -> Square {
    .init(file: castle == .short ? .g : .c, rank: backRank)
  }

  func castlePath(castle: Castle) -> [Square] {
    (castle == .short ? [.f, .g] : [.b, .c, .d]).map { file in
      .init(file: file, rank: backRank)
    }
  }

  func castleRookSquare(castle: Castle) -> Square {
    .init(file: castle == .short ? .h : .a, rank: backRank)
  }
}

private extension Square {
  static func + (lhs: Self, rhs: Board.Vector) -> Self? {
    guard let file = File(rawValue: lhs.file.rawValue + rhs.files),
          let rank = Rank(rawValue: lhs.rank.rawValue + rhs.ranks) else {
      return nil
    }

    return .init(file: file, rank: rank)
  }

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

  struct Vector {
    let files: Int

    let ranks: Int
  }

  fileprivate typealias Transform = (Board) -> (Board)

  /// Standard chess starting position.
  ///
  /// White pieces start on ranks 1 and 2, and black pieces start on ranks 7
  /// and 8.
  public static var board: Board {
    .init(pieces: .init(uniqueKeysWithValues: Piece.Color.allCases.flatMap { color in
      Piece.Figure.allCases.map { figure in
        Piece(color: color, figure: figure)
      }
    }
    .flatMap { piece in
      piece.startFiles.map { file in
        (.init(
          file: file,
          rank: piece.figure == .pawn ? piece.color.pawnRank : piece.color.backRank
        ), piece)
      }
    }))
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
      translations(for: piece, from: square, isCapture: true).contains { translation in
        guard let targetSquare = translation.baseTranslation?.targetSquare else {
          return false
        }

        return pieces[targetSquare] == .init(color: toMove, figure: .king)
      }
    }
  }

  private var isNoMovePossible: Bool {
    !pieces.contains { square, piece in
      piece.color == toMove && !legalMoves(for: piece, from: square).isEmpty
    }
  }

  private var toMove: Piece.Color {
    dataSource?.toMove ?? .white
  }

  /// Retrieves the piece located at a specific square on the board.
  ///
  /// - Parameters:
  ///   - square: The square on the board whose piece to retrieve.
  /// - Returns: The piece at the given square, or `nil` if the square is empty.
  public subscript(square: Square) -> Piece? {
    pieces[square]
  }

  /// Retrieves the moves that can be made from a specific square on the board.
  ///
  /// - Parameters:
  ///   - square: The square on the board from which to retrieve possible moves.
  /// - Returns: A dictionary whose keys are each destination square and whose
  ///   values are the moves that end on that square.
  public func moves(from square: Square) -> [Square: [any Move]] {
    guard let piece = self[square] else {
      return [:]
    }

    return Dictionary(grouping: legalMoves(for: piece, from: square)) { move in
      move.targetSquare(for: piece)
    }
  }

  func applying(move: any Move) throws -> Self {
    let matchingMoves = flatMap { square, piece in
      legalMoves(for: piece, from: square)
        .filter { candidate in
          candidate ~= move
        }
        .map { candidate in
          (candidate, piece, square)
        }
    }

    guard matchingMoves.count < 2 else {
      throw MoveError.ambiguousMove(candidates: matchingMoves.map(\.0))
    }

    guard let (_, piece, square) = matchingMoves.first else {
      throw MoveError.illegalMove
    }

    guard let transformedBoard = applying(move: move, for: piece, from: square) else {
      throw MoveError.illegalMove
    }

    return transformedBoard
  }

  func applying(move: any Move, for piece: Piece, from square: Square) -> Self? {
    move.transforms(for: piece, from: square).reduce(Optional(self)) { board, transform in
      guard let board else {
        return nil
      }

      var transformedBoard = transform(board)
      transformedBoard.dataSource = dataSource
      return transformedBoard.isInCheck ? nil : transformedBoard
    }
  }

  init(pieces: [Square: Piece], enPassantSquare: Square? = nil) {
    self.pieces = pieces
    self.enPassantSquare = enPassantSquare
  }

  private func hasPieceMoved(_ piece: Piece, from square: Square) -> Bool {
    dataSource?.hasPieceMoved(piece, from: square) ?? false
  }

  private func legalMoves(for piece: Piece, from square: Square) -> [any Move] {
    [false, true].flatMap { isCapture in
      moves(for: piece, from: square, isCapture: isCapture)
    }
    .filter { move in
      applying(move: move, for: piece, from: square) != nil
    }
  }

  private func moves(for piece: Piece, from square: Square, isCapture: Bool) -> [any Move] {
    guard piece.color == toMove else {
      return []
    }

    let moves = translations(for: piece, from: square, isCapture: isCapture)

    guard piece == .init(color: toMove, figure: .king),
          square == .init(file: .e, rank: toMove.backRank),
          !hasPieceMoved(piece, from: square),
          !isCapture,
          !isInCheck else {
      return moves
    }

    return Castle.allCases.filter { castle in
      let rookSquare = toMove.castleRookSquare(castle: castle)
      let rook = Piece(color: toMove, figure: .rook)

      return pieces[rookSquare] == rook
        && !toMove.castlePath(castle: castle).contains(where: pieces.keys.contains)
        && !hasPieceMoved(rook, from: rookSquare)
    }
    .reduce(into: moves) { moves, castle in
      moves.append(castle)
    }
  }

  private func translations(for piece: Piece, from square: Square, isCapture: Bool) -> [any Move] {
    piece.paths(from: square, isCapture: isCapture).flatMap { path in
      let obstruction = path.enumerated().first { _, square in
        pieces.keys.contains(square)
      }

      guard isCapture else {
        return path.prefix(upTo: obstruction?.0 ?? path.endIndex)
      }

      guard let enPassantSquare,
            let first = path.first,
            piece.figure == .pawn,
            first == enPassantSquare + piece.color.forwardUnitVector else {
        guard let obstruction, pieces[obstruction.1]!.color != piece.color else {
          return []
        }

        return path[obstruction.0 ..< obstruction.0 + 1]
      }

      return [first]
    }
    .flatMap { targetSquare in
      piece.promotions(targetSquare: targetSquare).map { promotion in
        let translation = Translation(
          figure: piece.figure,
          disambiguationFile: square.file,
          disambiguationRank: square.rank,
          targetSquare: targetSquare
        )

        if isCapture {
          let capture = Capture(translation)
          return promotion.map { Promotion.capture(capture, to: $0) } ?? capture
        } else {
          return promotion.map { Promotion.translation(translation, to: $0) } ?? translation
        }
      }
    }
  }
}

extension Board: Collection {
  public typealias Index = [Square: Piece].Index

  public var endIndex: Index {
    pieces.endIndex
  }

  public var startIndex: Index {
    pieces.startIndex
  }

  public subscript(position: Index) -> (key: Square, value: Piece) {
    pieces[position]
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
  static let cardinalUnitVectors: Self = [
    .init(files: -1, ranks: 0),
    .init(files: 0, ranks: -1),
    .init(files: 0, ranks: 1),
    .init(files: 1, ranks: 0)
  ]

  static let diagonalUnitVectors: Self = [
    .init(files: -1, ranks: -1),
    .init(files: -1, ranks: 1),
    .init(files: 1, ranks: -1),
    .init(files: 1, ranks: 1)
  ]
}
