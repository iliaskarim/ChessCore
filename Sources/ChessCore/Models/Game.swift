import Foundation

// MARK: -
extension Board: CustomStringConvertible {
  public var description: String {
    Square.Rank.allCases.reversed().map { rank in
      " ".appending(
        rank.description.appending(" ").appending(
          Square.File.allCases.map { file in
            pieces[Square(file: file, rank: rank)]?.description ?? " "
          }.joined(separator: " ")
        )
      )
    }.joined(separator: "\n").appending("\n   ").appending(
      Square.File.allCases.map(\.description).joined(separator: " ")
    )
  }
}

// MARK: -
extension Notation: CustomStringConvertible {
  var description: String {
    switch self {
    case let .end(victor):
      guard let victor else {
        return "1/2-1/2"
      }
      return victor == .black ? "0-1" : "1-0"

    case let .gameplay(gameplay):
      return gameplay.description
    }
  }
}

extension Notation.Gameplay: CustomStringConvertible {
  var description: String {
    "\(play)\(punctuation?.description ?? "")"
  }
}

extension Notation.Gameplay.Play: CustomStringConvertible {
  var description: String {
    switch self {
    case let .castle(side):
      switch side {
      case .kingside:
        return "O-O"

      case .queenside:
        return "O-O-O"
      }

    case let .translation(disambiguationFile, disambiguationRank, figure, isCapture, promotion, targetSquare):
      let disambiguation = (disambiguationFile?.description ?? "").appending(disambiguationRank?.description ?? "")
      let promotion = promotion.map { promotion in
        "=\(promotion)"
      } ?? ""
      return "\(figure.description)\(disambiguation)\(isCapture ? "x" : "")\(targetSquare)\(promotion)"
    }
  }
}

extension Notation.Gameplay.Punctuation: CustomStringConvertible {
  var description: String {
    rawValue
  }
}

// MARK: -
extension Piece: CustomStringConvertible {
  public var description: String {
    let description = figure == .pawn ? "X" : figure.rawValue
    return color == .white ? description : description.lowercased()
  }
}

extension Piece.Color: CustomStringConvertible {
  var description: String {
    rawValue
  }
}

extension Piece.Figure: CustomStringConvertible {
  var description: String {
    rawValue
  }
}

// MARK: -
extension Square: CustomStringConvertible {
  public var description: String {
    file.description.appending(rank.description)
  }
}

extension Square.Rank: CustomStringConvertible {
  var description: String {
    String(rawValue)
  }
}

extension Square.File: CustomStringConvertible {
  var description: String {
    String(Character(UnicodeScalar(rawValue + 96)!))
  }
}

// MARK: - Game

/// A model representing a chess game.
///
/// Chess is a board game played between two players.
public struct Game {
  private struct InvalidMove: Error {
    let notation: String
  }

  var isGameOver: Bool {
    guard case .end = moves.last else {
      return board.isCheckmate(color: moveColor)
    }
    return true
  }

  private var board: Board

  private var moveColor: Piece.Color {
    moves.count.isMultiple(of: 2) ? .white : .black
  }

  private var moves = [Notation]()

  /// Move
  /// - Parameter notation: Notation
  public mutating func move(_ notationString: String) throws {
    let error = InvalidMove(notation: notationString)

    guard let notation = Notation(string: notationString) else {
      throw error
    }

    if case let .gameplay(gameplay) = notation {
      switch gameplay.play {
      case let .castle(side):
        guard let mutations = castle(color: moveColor, side: side), let mutatedBoard = board.mutatedBoard(mutations: mutations) else {
          throw error
        }

        board = mutatedBoard

      case let .translation(disambiguationFile, disambiguationRank, figure, isCapture, promotion, targetSquare):
        let eligibleSquares = board.pieces.filter { square, piece in
          let move: Board.Move = isCapture ? .capture(originSquare: square) : .move(originSquare: square)
          return piece.color == moveColor && piece.figure == figure && board.moves(move).contains(targetSquare) &&
            square.file == disambiguationFile ?? square.file && square.rank == disambiguationRank ?? square.rank
        }

        guard let originSquare = eligibleSquares.first?.0, eligibleSquares.count == 1 else {
          throw error
        }

        guard let mutatedBoard = board.mutatedBoard(originSquare: originSquare, targetSquare: targetSquare, promotion: promotion) else {
          throw error
        }

        board = mutatedBoard
      }

      // Compute game state.
      let isCheck = board.isCheck(color: moveColor.opposite)
      let isCheckmate = board.isCheckmate(color: moveColor.opposite)

      // Correct missing punctuation.
      guard let punctuation = gameplay.punctuation else {
        guard !isCheckmate else {
          let gameplay = Notation.Gameplay(play: gameplay.play, punctuation: .checkmate)
          let notation = Notation.gameplay(gameplay)
          moves += [notation]
          return
        }
        guard !isCheck else {
          let gameplay = Notation.Gameplay(play: gameplay.play, punctuation: .check)
          let notation = Notation.gameplay(gameplay)
          moves += [notation]
          return
        }
        moves += [notation]
        return
      }

      // Validate punctuation parsed from input notation.
      switch punctuation {
      case .check:
        guard isCheck, !isCheckmate else {
          throw error
        }
      case .checkmate:
        guard isCheckmate else {
          throw error
        }
      }
    }

    moves += [notation]
  }

  /// Designated initializer
  public init(board: Board = .board) {
    self.board = board
  }

  private func castle(color: Piece.Color, side: Board.Side) -> [Board.Mutation]? {
    let castlePath = castlePath(color: color, side: side)
    let kingsSquare = kingsSquare(color: color)

    let openSquares: [Square]
    if let openSquare = kingsSquare + Vector(files: -3), side == .queenside {
      openSquares = castlePath + [openSquare]
    } else {
      openSquares = castlePath
    }

    guard let rooksSquare = rooksSquare(color: color, side: side), !openSquares.contains(where: board.pieces.keys.contains),
          !board.squaresTouched.contains(kingsSquare), !board.squaresTouched.contains(rooksSquare) else {
      return nil
    }

    return [
      (originSquare: kingsSquare, targetSquare: castlePath[0]),
      (originSquare: castlePath[0], targetSquare: castlePath[1]),
      (originSquare: rooksSquare, targetSquare: castlePath[0]),
    ]
  }

  private func kingsSquare(color: Piece.Color) -> Square {
    board.pieces.filter { element in
      element.value.color == color && element.value.figure == .king
    }.keys.first!
  }

  private func castlePath(color: Piece.Color, side: Board.Side) -> [Square] {
    (side == .kingside ? [1, 2] : [-1, -2]).compactMap { files in
      kingsSquare(color: color) + Vector(files: files)
    }
  }

  private func rooksSquare(color: Piece.Color, side: Board.Side) -> Square? {
    let kingsSquare = kingsSquare(color: color)
    return board.pieces.filter { element in
      element.value.color == color && element.value.figure == .rook &&
      ((element.key.file.rawValue < kingsSquare.file.rawValue && side == .queenside) ||
       (element.key.file.rawValue > kingsSquare.file.rawValue && side == .kingside))
    }.first?.key
  }
}

extension Game: CustomStringConvertible {
  public var description: String {
    (moves.isEmpty ? "" : stride(from: 0, to: moves.count, by: 2).map { i in
      "\(i/2+1). "
        .appending(moves[i].description)
        .appending(moves.count > i+1 ? " \(moves[i+1])" : "")
      }.joined(separator: "\n")
    .appending("\n\n"))
    .appending(isGameOver ? "" : "\(moveColor.description.capitalized.appending(" to move."))\n\n")
    .appending(board.description)
  }
}
