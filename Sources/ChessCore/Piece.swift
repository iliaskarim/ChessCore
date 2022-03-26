//
//  Piece.swift
//  chess
//
//  Created by Ilias Karim on 7/15/21.
//  Copyright © 2021 Ilias Karim. All rights reserved.
//

/// A model representing a chess piece.
public struct Piece: Equatable {
  /// Color
  public enum Color: String, CaseIterable {
    case white
    case black

    var opposite: Color {
      switch self {
      case .white: return .black
      case .black: return .white
      }
    }
  }

  /// Figure
  public enum Figure: String, CaseIterable {
    case bishop = "B"
    case king = "K"
    case knight = "N"
    case pawn = "X"
    case queen = "Q"
    case rook = "R"
  }

  /// Color
  public let color: Color

  /// Figure
  public let figure: Figure
}
