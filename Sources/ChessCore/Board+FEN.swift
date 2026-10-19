private extension Board {
  static func castlingRights(from field: String) throws -> [Piece.Color: Set<Castling>] {
    var rights = [Piece.Color: Set<Castling>](
      uniqueKeysWithValues: Piece.Color.allCases.map { color in
        (color, [])
      }
    )
    guard field != "-" else {
      return rights
    }

    guard !field.isEmpty else {
      throw FENError.invalidCastlingRights
    }

    var seen = Set<Character>()
    for character in field {
      guard seen.insert(character).inserted else {
        throw FENError.invalidCastlingRights
      }

      switch character {
      case "K":
        rights[.white, default: []].insert(.kingside)

      case "Q":
        rights[.white, default: []].insert(.queenside)

      case "k":
        rights[.black, default: []].insert(.kingside)

      case "q":
        rights[.black, default: []].insert(.queenside)

      default:
        throw FENError.invalidCastlingRights
      }
    }

    return rights
  }

  static func enPassantSquare(from field: String) throws -> Square? {
    guard field != "-" else {
      return nil
    }

    guard let square = square(from: field) else {
      throw FENError.invalidEnPassantSquare
    }

    return square
  }

  static func fullmoveNumber(from field: String) throws -> Int {
    guard let fullmove = integer(from: field), fullmove > 0 else {
      throw FENError.invalidFullmoveNumber
    }

    return fullmove
  }

  static func halfmoveClock(from field: String) throws -> Int {
    guard let clock = integer(from: field) else {
      throw FENError.invalidHalfmoveClock
    }

    return clock
  }

  static func pieces(from placement: String) throws -> [Square: Piece] {
    let ranks = placement.split(separator: "/", omittingEmptySubsequences: false)
    guard ranks.count == Square.Rank.allCases.count else {
      throw FENError.invalidPlacement
    }

    var pieces = [Square: Piece]()
    for (index, rankText) in ranks.enumerated() {
      guard let rank = Square.Rank(rawValue: Square.Rank.allCases.count - index) else {
        throw FENError.invalidPlacement
      }

      var file = Square.File.a.rawValue
      for character in rankText {
        if character.isASCII, let skip = character.wholeNumberValue {
          guard (1 ... Square.File.allCases.count).contains(skip) else {
            throw FENError.invalidPlacement
          }

          file += skip
        } else {
          guard let squareFile = Square.File(rawValue: file),
                let piece = Piece(fen: character) else {
            throw FENError.invalidPlacement
          }

          pieces[.init(file: squareFile, rank: rank)] = piece
          file += 1
        }
      }

      guard file == Square.File.a.rawValue + Square.File.allCases.count else {
        throw FENError.invalidPlacement
      }
    }

    return pieces
  }

  static func sideToMove(from field: String) throws -> Piece.Color {
    switch field {
    case "w":
      .white

    case "b":
      .black

    default:
      throw FENError.invalidSideToMove
    }
  }

  private static func integer(from field: String) -> Int? {
    guard !field.isEmpty, field.allSatisfy({ $0.isASCII && $0.isNumber }) else {
      return nil
    }

    return Int(field)
  }

  private static func square(from field: String) -> Square? {
    let characters = Array(field)
    guard characters.count == 2,
          characters[0].isASCII,
          characters[1].isASCII,
          let fileScalar = characters[0].asciiValue,
          let file = Square.File(rawValue: Int(fileScalar) - 96),
          let rankValue = characters[1].wholeNumberValue,
          let rank = Square.Rank(rawValue: rankValue) else {
      return nil
    }

    return .init(file: file, rank: rank)
  }
}

private extension Piece {
  var fen: String {
    let symbol = figure == .pawn ? "P" : figure.rawValue
    return color == .white ? symbol : symbol.lowercased()
  }

  init?(fen character: Character) {
    guard character.isLetter else {
      return nil
    }

    let symbol = String(character).uppercased()
    guard let figure = symbol == "P" ? Figure.pawn : Figure(rawValue: symbol) else {
      return nil
    }

    self.init(color: character.isUppercase ? .white : .black, figure: figure)
  }
}

extension Board {
  /// Forsyth-Edwards Notation for this position.
  ///
  /// Fields are piece placement, the side to move, castling rights, the en
  /// passant target square, the halfmove clock, and the fullmove number. A new
  /// board starts at halfmove 0 and fullmove 1. Applying a move advances both.
  public var fen: String {
    [
      fenPlacement,
      toMove == .white ? "w" : "b",
      fenCastling,
      enPassantSquare?.description ?? "-",
      String(halfmoveClock),
      String(fullmoveNumber)
    ].joined(separator: " ")
  }

  private var fenCastling: String {
    let marks = [
      (Piece.Color.white, Castling.kingside, "K"),
      (.white, .queenside, "Q"),
      (.black, .kingside, "k"),
      (.black, .queenside, "q")
    ].compactMap { color, side, mark in
      hasCastlingRight(side, for: color) ? mark : nil
    }
    .joined()

    return marks.isEmpty ? "-" : marks
  }

  private var fenPlacement: String {
    Square.Rank.allCases.reversed().map(fenRank).joined(separator: "/")
  }

  /// Creates a board from Forsyth-Edwards Notation.
  ///
  /// Castling rights come from the string. A king and rook on their home
  /// squares do not grant a right the string omits.
  ///
  /// - Parameters:
  ///   - fen: Piece placement, the side to move, castling rights, the en passant
  ///     target square, the halfmove clock, and the fullmove number.
  /// - Throws: `FENError` when `fen` is not valid notation.
  public init(fen: String) throws {
    let fields = fen.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
    guard fields.count == 6 else {
      throw FENError.invalidFieldCount
    }

    let pieces = try Self.pieces(from: fields[0])
    let toMove = try Self.sideToMove(from: fields[1])
    let castlingRights = try Self.castlingRights(from: fields[2])
    let enPassantSquare = try Self.enPassantSquare(from: fields[3])
    let halfmoveClock = try Self.halfmoveClock(from: fields[4])
    let fullmoveNumber = try Self.fullmoveNumber(from: fields[5])
    self.init(
      pieces: pieces,
      enPassantSquare: enPassantSquare,
      toMove: toMove,
      castlingRights: castlingRights,
      halfmoveClock: halfmoveClock,
      fullmoveNumber: fullmoveNumber
    )
  }

  private func fenRank(_ rank: Square.Rank) -> String {
    var empty = 0
    var text = ""
    for file in Square.File.allCases {
      if let piece = pieces[.init(file: file, rank: rank)] {
        if empty > 0 {
          text.append(String(empty))
          empty = 0
        }

        text.append(piece.fen)
      } else {
        empty += 1
      }
    }

    if empty > 0 {
      text.append(String(empty))
    }

    return text
  }
}
