
// MARK: -
private extension Piece {
  var forwardUnitVector: Vector {
    Vector(ranks: color == .black ? -1 : 1)
  }

  var startRank: Square.Rank {
    guard case figure = .pawn else {
      return color == .black ? .eight : .one
    }
    
    return color == .black ? .seven : .two
  }

  var startSquares: [Square] {
    switch figure {
    case .pawn:
      return Square.File.allCases.map { file in
        .init(file: file, rank: startRank)
      }

    case .rook:
      return [.init(file: .a, rank: startRank), .init(file: .h, rank: startRank)]

    case .knight:
      return [.init(file: .b, rank: startRank), .init(file: .g, rank: startRank)]

    case .bishop:
      return [.init(file: .c, rank: startRank), .init(file: .f, rank: startRank)]

    case .queen:
      return [.init(file: .d, rank: startRank)]

    case .king:
      return [.init(file: .e, rank: startRank)]
    }
  }

  func moves(originSquare: Square, isCapture: Bool) -> [[Square]] {
    switch (figure, isCapture) {
    case (.bishop, _):
      return Vector.diagonalUnitVectors.compactMap(originSquare.allSquaresInDirection)

    case (.king, _):
      return Vector.unitVectors.compactMap { direction in
        (originSquare + direction).map { targetSquare in
          [targetSquare]
        }
      }

    case (.knight, _):
      return [Vector(files: -2, ranks: -1),
              Vector(files: -2, ranks: 1),
              Vector(files: -1, ranks: -2),
              Vector(files: -1, ranks: 2),
              Vector(files: 1, ranks: -2),
              Vector(files: 1, ranks: 2),
              Vector(files: 2, ranks: -1),
              Vector(files: 2, ranks: 1)].compactMap { vector in
        (originSquare + vector).map { targetSquare in
          [targetSquare]
        }
      }

    case (.pawn, false):
      guard let oneSquareForward = originSquare + forwardUnitVector else {
        return []
      }

      guard let twoSquaresForward = oneSquareForward + forwardUnitVector, originSquare.rank == startRank else {
        return [[oneSquareForward]]
      }

      return [[oneSquareForward, twoSquaresForward]]

    case (.pawn, true):
      return [Vector(files: -1, ranks: forwardUnitVector.ranks), Vector(files: 1, ranks: forwardUnitVector.ranks)].compactMap { vector in
        (originSquare + vector).map { targetSquare in
          [targetSquare]
        }
      }

    case (.queen, _):
      return Vector.unitVectors.compactMap(originSquare.allSquaresInDirection)

    case (.rook, _):
      return Vector.cardinalUnitVectors.compactMap(originSquare.allSquaresInDirection)
    }
  }
}

// MARK: -
private extension Square {
  static func - (lhs: Square, rhs: Vector) -> Square? {
    lhs + Vector(files: -1 * rhs.files, ranks: -1 * rhs.ranks)
  }

  func allSquaresInDirection(_ direction: Vector) -> [Self] {
    guard let squareInDirection = self + direction else {
      return []
    }

    return [squareInDirection] + squareInDirection.allSquaresInDirection(direction)
  }
}

// MARK: -
extension Vector {
  static let cardinalUnitVectors: [Vector] = [
    .init(files: 0, ranks: -1),
    .init(files: -1, ranks: 0),
    .init(files: 0, ranks: 1),
    .init(files: 1, ranks: 0)
  ]

  static let diagonalUnitVectors: [Vector] = [
    .init(files: -1, ranks: -1),
    .init(files: -1, ranks: 1),
    .init(files: 1, ranks: -1),
    .init(files: 1, ranks: 1)
  ]

  static let unitVectors = cardinalUnitVectors + diagonalUnitVectors
}

// MARK: - Board

/// A model representing a chess board.
///
/// Chess boards consist of black and white figures arranged on an eight-by-eight grid.
public struct Board {
  typealias Mutation = (originSquare: Square, targetSquare: Square)

  enum Move {
    case move(originSquare: Square)
    case capture(originSquare: Square)

    var isCapture: Bool {
      guard case .capture = self else {
        return false
      }

      return true
    }

    var originSquare: Square {
      switch self {
      case let .move(originSquare):
        return originSquare

      case let .capture(originSquare):
        return originSquare
      }
    }
  }

  public static var board: Board {
    Board(pieces:  Piece.Color.allCases.flatMap { color in
      Piece.Figure.allCases.map { figure in
        .init(color: color, figure: figure)
      }
    }.reduce(into: .init()) { result, piece in
      piece.startSquares.forEach { startSquare in
        result[startSquare] = piece
      }
    })
  }

  enum Side {
    case kingside
    case queenside
  }

//  private
  let pieces: [Square: Piece]

  let squaresTouched: [Square]

  private let enPassant: Square?

  func isCheck(color: Piece.Color) -> Bool {
    pieces.filter { _, piece in
      piece.color == color.opposite
    }.flatMap { originSquare, _ in
      moves(.capture(originSquare: originSquare))
    }.compactMap { targetSquare in
      pieces[targetSquare]
    }.contains { piece in
      piece.color == color && piece.figure == .king
    }
  }

  func isCheckmate(color: Piece.Color) -> Bool {
    !pieces.filter { _, piece in
      piece.color == color
    }.contains { originSquare, _ in
      let moves = moves(.move(originSquare: originSquare)) + moves(.capture(originSquare: originSquare))
      return moves.contains { targetSquare in
        mutatedBoard(originSquare: originSquare, targetSquare: targetSquare) != nil
      }
    }
  }

  func moves(_ move: Move) -> [Square] {
    guard let piece = pieces[move.originSquare] else {
      return []
    }

    return piece.moves(originSquare: move.originSquare, isCapture: move.isCapture).flatMap { path in
      let collision: (offset: Int, piece: Piece)? = path.enumerated().first { _, targetSquare in
        pieces[targetSquare] != nil
      }.map { offset, targetSquare in
        (offset, pieces[targetSquare]!)
      }

      guard case .capture = move else {
        return path.prefix(upTo: collision?.offset ?? path.endIndex)
      }

      guard let collision, collision.piece.color == piece.color.opposite else {
        guard let enPassant, piece.figure == .pawn, path.first == enPassant + piece.forwardUnitVector else {
          return []
        }
        return [path.first!]
      }

      return path[collision.offset..<collision.offset+1]
    }
  }

  func mutatedBoard(mutations: [Mutation]) -> Self? {
    mutations.reduce(self) { board, mutation in
      board?.mutatedBoard(originSquare: mutation.originSquare, targetSquare: mutation.targetSquare)
    }
  }

  func mutatedBoard(originSquare origin: Square, targetSquare target: Square, promotion: Piece.Figure? = nil) -> Self? {
    guard let piece = pieces[origin] else {
      return self
    }

    var pieces = self.pieces
    if let enPassant = target - piece.forwardUnitVector, piece.figure == .pawn, origin.file != target.file, pieces[target] == nil {
      pieces[enPassant] = nil
    }
    pieces[origin] = nil

    if let promotion {
      // Prohibit invalid promoions.
      guard piece.figure == .pawn, target.rank == Square.Rank.allCases.first || target.rank == Square.Rank.allCases.last,
            promotion != .king, promotion != .pawn else {
        return nil
      }
      pieces[target] = Piece(color: piece.color, figure: promotion)
    } else {
      pieces[target] = piece
    }

    let enPassant = piece.figure == .pawn && abs(origin.rank.rawValue - target.rank.rawValue) == 2 ? target : nil
    let squaresTouched = squaresTouched + (squaresTouched.contains(target) ? [] : [target])
    let board = Board(pieces: pieces, enPassant: enPassant, squaresTouched: squaresTouched)
    
    // Do not allow moving into check.
    guard !board.isCheck(color: piece.color) else {
      return nil
    }

    return board
  }

  init(pieces: [Square : Piece], enPassant: Square? = nil, squaresTouched: [Square] = []) {
    self.pieces = pieces
    self.enPassant = enPassant
    self.squaresTouched = squaresTouched
  }
}
