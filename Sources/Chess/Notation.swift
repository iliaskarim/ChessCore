//
//  Notation.swift
//  chess
//
//  Created by Ilias Karim on 8/19/21.
//  Copyright © 2021 Ilias Karim. All rights reserved.
//

typealias Notation = String

extension Notation {
  enum Outcome {
    case draw
    case resignation(color: Piece.Color)
  }

  struct Move {
    let origin: Board.Square
    let destination: Board.Square
  }

  enum Kind {
    case capture(move: Move, captured: Board.Square)
    case castle(kingMove: Move, rookMove: Move)
    case move(move: Move)
    case outcome(outcome: Outcome)
  }

  func parse(board: Board, color: Piece.Color) -> Kind? {
    switch self {
    case "1/2-1/2":
      return Kind.outcome(outcome: .draw)
    case "1-0":
      return Kind.outcome(outcome: .resignation(color: .white))
    case "0-1":
      return Kind.outcome(outcome: .resignation(color: .black))
    case "0-0": // To do: kingside castle
      return nil
    case "0-0-0": // To do: queenside castle
      return nil
    default: return nil
    }
  }
}
