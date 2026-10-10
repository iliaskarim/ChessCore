import Combine
import Foundation

private extension Board {
  var punctuation: Turn.Punctuation? {
    switch status {
    case .check:
      .check

    case .checkmate:
      .checkmate

    default:
      nil
    }
  }
}

/// A chess game.
///
/// A game owns the current board position and applies moves while tracking
/// game status such as whose turn it is and whether the game has ended.
public class Game: BoardDataSource, ObservableObject {
  /// A game's status.
  ///
  /// A game is either in progress, won, or drawn.
  public enum Status {
    /// A player has won the game.
    case winner(Piece.Color, by: any WinCondition.Type)

    /// The game ended in a draw.
    case draw(any DrawCondition.Type)

    /// The game is in progress, with the side to move.
    case toMove(Piece.Color)
  }

  /// Game board.
  @Published public private(set) var board: Board

  /// Game status.
  public var status: Status {
    status(
      winContext: .init(board: board, turns: turns, toMove: toMove),
      drawContext: .init(
        board: board,
        turns: turns,
        positionIdentities: positionIdentities
      )
    )
  }

  /// Win conditions evaluated for the game.
  public static var winConditions: [any WinCondition.Type] {
    [
      ResignationWinCondition.self,
      CheckmateWinCondition.self
    ]
  }

  /// Draw conditions evaluated for the game.
  public static var drawConditions: [any DrawCondition.Type] {
    [
      AgreementDrawCondition.self,
      StalemateDrawCondition.self,
      FiftyMoveDrawCondition.self,
      ThreefoldRepetitionDrawCondition.self,
      InsufficientMaterialDrawCondition.self
    ]
  }

  private func status(winContext: WinContext, drawContext: DrawContext) -> Status {
    for condition in Self.winConditions {
      if let winner = condition.winner(in: winContext) {
        return .winner(winner, by: condition)
      }
    }

    if let condition = Self.drawConditions.first(where: { condition in
      condition.isDraw(in: drawContext)
    }) {
      return .draw(condition)
    }

    return .toMove(toMove)
  }

  var toMove: Piece.Color {
    turns.count.isMultiple(of: 2) ? .white : .black
  }

  private var turns = [Turn]()

  private var positionIdentities = [PositionIdentity]()

  /// Ends the game.
  ///
  /// - Parameters:
  ///   - victor: The winning color, if any. Pass `nil` for a draw.
  /// - Throws: `GameStateError.gameOver` if the game is already over.
  public func endGame(victor: Piece.Color?) throws {
    guard case .toMove = status else {
      throw GameStateError.gameOver
    }

    turns += [.end(victor: victor)]
  }

  /// Makes a move.
  ///
  /// - Parameters:
  ///   - move: The move.
  /// - Throws: `GameStateError.gameOver` if the game is already over,
  ///   `MoveError.ambiguousMove(candidates:)` if multiple moves match the
  ///   input, or `MoveError.illegalMove` if no legal matching move exists.
  public func play(_ move: any Move) throws {
    guard case .toMove = status else {
      throw GameStateError.gameOver
    }

    board = try board.applying(move: move)
    turns += [.move(move, punctuation: nil)]

    // Calculate the punctuation after adding the move to turns played.
    if let punctuation = board.punctuation, let lastIndex = turns.indices.last {
      turns[lastIndex] = .move(move, punctuation: punctuation)
    }

    positionIdentities.append(positionIdentity())
  }

  func hasPieceMoved(_ piece: Piece, from square: Square) -> Bool {
    board[square] != piece || turns.contains { turn in
      switch turn {
      case let .move(move, _):
        move.moveTargetSquare == square

      default:
        false
      }
    }
  }

  /// Creates a game from a board state.
  ///
  /// - Parameters:
  ///   - board: The game board.
  public init(board: Board = .board) {
    self.board = board
    self.board.dataSource = self
    positionIdentities = [positionIdentity()]
  }
}

private extension Game {
  func positionIdentity() -> PositionIdentity {
    .init(
      pieces: .init(uniqueKeysWithValues: board.map { square, piece in
        (square, piece)
      }),
      toMove: toMove,
      enPassantSquare: board.enPassantSquare,
      castlingRights: castlingRights()
    )
  }

  func castlingRights() -> Set<CastlingRight> {
    .init(Piece.Color.allCases.flatMap { color in
      Castle.allCases.compactMap { castle in
        let kingSquare = Square(file: .e, rank: color.backRank)
        let rookSquare = color.castleRookSquare(castle: castle)
        let king = Piece(color: color, figure: .king)
        let rook = Piece(color: color, figure: .rook)

        guard board[kingSquare] == king,
              board[rookSquare] == rook,
              !hasPieceMoved(king, from: kingSquare),
              !hasPieceMoved(rook, from: rookSquare) else {
          return nil
        }

        return .init(color: color, castle: castle)
      }
    })
  }
}

private extension Piece.Color {
  func castleRookSquare(castle: Castle) -> Square {
    .init(file: castle == .short ? .h : .a, rank: backRank)
  }
}

extension Game: CustomDebugStringConvertible {
  public var debugDescription: String {
    stride(from: 0, to: turns.count, by: 2).map { i in
      "\(i / 2 + 1). \(turns[i])".appending(turns.count > i + 1 ? " \(turns[i + 1])" : "")
    }
    .joined(separator: "\n")
    .appending(turns.isEmpty ? "" : "\n\n")
    .appending("\(status)\n\n\(board)")
  }
}

extension Game.Status: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.winner(lhsColor, lhsCondition), .winner(rhsColor, rhsCondition)):
      lhsColor == rhsColor && ObjectIdentifier(lhsCondition) == ObjectIdentifier(rhsCondition)

    case let (.draw(lhsCondition), .draw(rhsCondition)):
      ObjectIdentifier(lhsCondition) == ObjectIdentifier(rhsCondition)

    case let (.toMove(lhsColor), .toMove(rhsColor)):
      lhsColor == rhsColor

    default:
      false
    }
  }
}

extension Game.Status: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .winner(color, _):
      "\(color) \(String.wins)."

    case let .draw(draw):
      "\(String.drawBy) \(draw.name)."

    case let .toMove(color):
      "\(color) \(String.toMove)."
    }
  }
}
