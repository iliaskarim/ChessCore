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

private extension Move {
  var isPawnMove: Bool {
    switch self {
    case let .translation(translation):
      translation.figure == .pawn

    case .castle:
      false
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
  public enum Status: Equatable {
    /// A draw result.
    ///
    /// Games are drawn by agreement, the fifty-move rule, or stalemate.
    public enum Draw {
      /// The players agreed to a draw.
      case byAgreement

      /// Fifty consecutive moves were played without a pawn move or capture.
      case byFiftyMoveRule

      /// The side to move has no legal moves and is not in check.
      case byStalemate
    }

    /// A player has won the game, with the winning color and whether the win
    /// was by resignation or checkmate.
    case winner(Piece.Color, isByResignation: Bool)

    /// The game ended in a draw.
    case draw(Draw)

    /// The game is in progress, with the side to move.
    case toMove(Piece.Color)
  }

  /// Game board.
  @Published public private(set) var board: Board

  /// Game status.
  public var status: Status {
    switch (turns.last, board.status) {
    case let (.end(victor), _):
      victor.map { color in
        .winner(color, isByResignation: true)
      } ?? .draw(.byAgreement)

    case (_, .checkmate):
      .winner(toMove.opposite, isByResignation: false)

    case (_, .stalemate):
      .draw(.byStalemate)

    default:
      if turns.count < 100 || turns.suffix(100).contains(where: { turn in
        switch turn {
        case let .move(move, _):
          move.isPawnMove || move.isCapture

        default:
          false
        }
      }) {
        .toMove(toMove)
      } else {
        .draw(.byFiftyMoveRule)
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
  ///   input, or `MoveError.illegalMove` if no legal matching move exists.
  public func play(_ move: Move) throws {
    guard case .toMove = status else {
      throw GameStateError.gameOver
    }

    board = try board.applying(move: move)
    turns += [.move(move, punctuation: nil)]

    // Calculate the punctuation after adding the move to turns played.
    if let punctuation = board.punctuation, let lastIndex = turns.indices.last {
      turns[lastIndex] = .move(move, punctuation: punctuation)
    }
  }

  func hasPieceMoved(_ piece: Piece, from square: Square) -> Bool {
    board[square] != piece || turns.contains { turn in
      switch turn {
      case let .move(.translation(translation), _):
        translation.targetSquare == square

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

    case let .draw(draw):
      "\(draw)"

    case let .toMove(color):
      "\(color) \(String.toMove)."
    }
  }
}

extension Game.Status.Draw: CustomStringConvertible {
  public var description: String {
    switch self {
    case .byAgreement:
      "\(String.drawBy) \(String.agreement)."

    case .byFiftyMoveRule:
      "\(String.drawBy) \(String.fiftyMoveRule)."

    case .byStalemate:
      "\(String.drawBy) \(String.stalemate.lowercased())."
    }
  }
}
