import Foundation

/// Errors related to move validation.
public enum MoveError: Error, Equatable {
  /// More than one legal move matches the requested move.
  case ambiguousMove(candidates: [AnyMove])

  /// No legal move matches the requested move.
  case illegalMove

  /// The move leaves the mover in check.
  case illegalMoveIntoCheck
}

extension MoveError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case let .ambiguousMove(candidates):
      let count = candidates.count
      let moveWord = count == 1 ? "move" : "moves"
      let candidatesDescription = candidates.map(\.description).sorted().joined(separator: ", ")
      return "This notation matches \(count) legal \(moveWord): \(candidatesDescription)."

    case .illegalMove:
      return "That move is not legal in this position."

    case .illegalMoveIntoCheck:
      return "That move leaves your king in check."
    }
  }
}
