import Combine
import Foundation

private extension Board.Status {
  var punctuation: Turn.Punctuation? {
    switch self {
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
/// A game owns the current board position and applies moves while tracking game
/// status such as whose turn it is and whether the game has ended.
public class Game: BoardDataSource, ObservableObject {
  /// A game's status.
  ///
  /// A game is either in progress, won, or drawn.
  public enum Status: Equatable {
    /// A player has won the game, with the winning color and whether the win
    /// was by resignation or checkmate.
    case winner(Piece.Color, isByResignation: Bool)

    /// The game ended in a draw.
    case draw(any DrawCondition.Type)

    /// The game is in progress, with the side to move.
    case toMove(Piece.Color)

    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case let (.winner(lhsColor, lhsIsByResignation), .winner(rhsColor, rhsIsByResignation)):
        lhsColor == rhsColor && lhsIsByResignation == rhsIsByResignation

      case let (.draw(lhsCondition), .draw(rhsCondition)):
        ObjectIdentifier(lhsCondition) == ObjectIdentifier(rhsCondition)

      case let (.toMove(lhsColor), .toMove(rhsColor)):
        lhsColor == rhsColor

      default:
        false
      }
    }
  }

  /// Draw conditions evaluated in order.
  static var drawConditions: [any GameDrawCondition.Type] {
    [
      AgreementDrawCondition.self,
      StalemateDrawCondition.self,
      InsufficientMaterialDrawCondition.self,
      FiftyMoveDrawCondition.self
    ]
  }

  /// Game board.
  @Published public private(set) var board: Board

  /// Game status.
  public var status: Status {
    switch turns.last {
    case let .end(.some(victor))?:
      .winner(victor, isByResignation: true)

    default:
      if board.status == .checkmate {
        .winner(toMove.opposite, isByResignation: false)
      } else if let condition = Self.drawConditions.first(where: { condition in
        condition.isDraw(board: board, turns: turns)
      }) {
        .draw(condition)
      } else {
        .toMove(toMove)
      }
    }
  }

  var toMove: Piece.Color {
    turns.count.isMultiple(of: 2) ? .white : .black
  }

  private var turns = [Turn]()

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
  ///   input, `MoveError.illegalMoveIntoCheck` if the move leaves the mover in
  ///   check, or `MoveError.illegalMove` if no legal matching move exists.
  public func play(_ move: some Move & Hashable) throws {
    guard case .toMove = status else {
      throw GameStateError.gameOver
    }

    board = try board.applying(move: move)
    let move = AnyMove(move)
    turns += [.move(move, punctuation: nil)]

    // Calculate the punctuation after adding the move to turns played.
    turns[turns.indices.last!] = .move(move, punctuation: board.status?.punctuation)
  }

  func hasPieceMoved(_ piece: Piece, from square: Square) -> Bool {
    board[square] != piece || turns.enumerated().contains { index, turn in
      guard case let .move(move, _) = turn else {
        return false
      }

      let color: Piece.Color = index.isMultiple(of: 2) ? .white : .black
      return move.targetSquare(for: color) == square
    }
  }

  /// Creates a game from a board.
  ///
  /// - Parameters:
  ///   - board: The game board.
  public init(board: Board = .board) {
    self.board = board
    self.board.dataSource = self
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

extension Game.Status: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .winner(color, _):
      "\(color) \(String.wins)."

    case let .draw(condition):
      "\(String.drawBy) \(condition.name)."

    case let .toMove(color):
      "\(color) \(String.toMove)."
    }
  }
}
