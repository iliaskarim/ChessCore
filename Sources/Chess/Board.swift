//
//  Board.swift
//  chess
//
//  Created by Ilias Karim on 7/15/21.
//  Copyright © 2021 Ilias Karim. All rights reserved.
//

struct Board: CustomStringConvertible {
  struct Square: Hashable, CustomStringConvertible {
    enum Rank: Int, CaseIterable {
      case one = 1
      case two
      case three
      case four
      case five
      case six
      case seven
      case eight
    }

    enum File: String, CaseIterable {
      case a
      case b
      case c
      case d
      case e
      case f
      case g
      case h
    }

    let file: File
    let rank: Rank

    var description: String {
      file.rawValue.appending(String(rank.rawValue))
    }

    var initialPiece: Piece? {
      let figures: [File: Piece.Figure] = [
        .a: .rook,
        .b: .knight,
        .c: .bishop,
        .d: .queen,
        .e: .king,
        .f: .bishop,
        .g: .knight,
        .h: .rook
      ]
      switch (file, rank) {
      case (let file, .one):
        return Piece(color: .white, figure: figures[file]!)
      case (_, .two):
        return Piece(color: .white, figure: .pawn)
      case (_, .seven):
        return Piece(color: .black, figure: .pawn)
      case (let file, .eight):
        return Piece(color: .black, figure: figures[file]!)
      default: return nil
      }
    }

    enum InvalidNotation: Error {
      case incorrectLength(length: Int)
      case invalidFileName(name: String)
      case invalidRankIndex(index: String)
    }

    init(notation: String) throws {
      guard notation.count == 2 else {
        throw InvalidNotation.incorrectLength(length: notation.count)
      }
      let fileName = String(notation[notation.startIndex..<notation.index(notation.startIndex, offsetBy: 1)])
      guard let file = File(rawValue: fileName) else {
        throw InvalidNotation.invalidFileName(name: fileName)
      }
      let rankIndexString = notation[notation.index(notation.startIndex, offsetBy: 1)..<notation.endIndex]
      guard let rankIndex = Int(rankIndexString), let rank = Rank(rawValue: rankIndex) else {
        throw InvalidNotation.invalidRankIndex(index: String(rankIndexString))
      }
      self.init(file: file, rank: rank)
    }

    init(file: File, rank: Rank) {
      self.file = file
      self.rank = rank
    }
  }

  var squares: [Square: Piece]

  func capturesFromSquare(_ square: Square) -> [Square] {
    guard let piece = squares[square] else { return [] }
    return piece.capturesFromSquare(square).map { sequence -> [Square] in
      guard let firstObstructedIndex = sequence.firstIndex(where: { move in
        squares[move] != nil
      }) else {
        return sequence
      }
      return [Square](sequence[sequence.startIndex...firstObstructedIndex])
    }.flatMap { $0 }.filter { move in
      squares[move]?.color != piece.color
    }
  }

  func check(color: Piece.Color) -> Bool {
    let kingsSquare = squares.first { _, piece in
      piece == Piece(color: color, figure: .king)
    }!.key

    return squares.filter { $0.value.color == color.opposite }.contains { square in
      capturesFromSquare(square.key).contains(kingsSquare)
    }
  }

  func checkmate(color: Piece.Color) -> Bool {
    let movableSquares = squares.filter { $0.value.color == color }
    for movableSquare in movableSquares {
      let moveOrigin = movableSquare.key
      let moveDestinations = movesFromSquare(moveOrigin) + capturesFromSquare(moveOrigin) // to do: test for en passant captures
      let boardCopy = self
    }
    return false
  }

  func movesFromSquare(_ square: Square) -> [Square] {
    guard let piece = squares[square] else { return [] }
    return piece.movesFromSquare(square).map { sequence -> [Square] in
      guard let firstObstructedIndex = sequence.firstIndex(where: { move in
        squares[move] != nil
      }) else {
        return sequence
      }
      return [Square](sequence[sequence.startIndex..<firstObstructedIndex])
    }.flatMap { $0 }
  }

  init(_ squares: [Square: Piece]? = nil) {
    self.squares = squares ?? Square.Rank.allCases.reduce(into: [:]) { result, rank in
      Square.File.allCases.forEach { file in
        let square = Square(file: file, rank: rank)
        result[square] = square.initialPiece
      }
    }
  }

  // MARK: 
  var description: String {
    Square.Rank.allCases.reversed().map { rank in
      " ".appending(String(rank.rawValue).appending(" ").appending(
        Square.File.allCases.map { file in
          if let piece = squares[Square(file: file, rank: rank)] {
            return piece.color == .white ? piece.figure.rawValue : piece.figure.rawValue.lowercased()
          } else {
            return " "
          }
        }.joined(separator: " ")
      ))
    }.joined(separator: "\n").appending("\n   ").appending(
      Square.File.allCases.map { file in
        file.rawValue
      }.joined(separator: " ")
    )
  }
}

extension Board.Square {
  init?(file: File?, rank: Rank?) {
    guard let file = file, let rank = rank else {
      return nil
    }
    self = Self.init(file: file, rank: rank)
  }
}

extension Board.Square.File {
  var integerValue: Int {
    Self.allCases.firstIndex(of: self)! + 1
  }

  init?(integerValue: Int) {
    guard Self.allCases.indices.contains(integerValue - 1) else {
      return nil
    }
    self = Self.allCases[integerValue - 1]
  }

  static func + (lhs: Board.Square.File, rhs: Int) -> Board.Square.File? {
    Self.init(integerValue: lhs.integerValue + rhs)
  }

  static func - (lhs: Board.Square.File, rhs: Int) -> Board.Square.File? {
    Self.init(integerValue: lhs.integerValue - rhs)
  }
}

extension Board.Square.Rank {
  static func == (lhs: Board.Square.Rank, rhs: Int) -> Bool {
    lhs.rawValue == rhs
  }

  static func + (lhs: Board.Square.Rank, rhs: Int) -> Board.Square.Rank? {
    Board.Square.Rank(rawValue: lhs.rawValue + rhs)
  }

  static func - (lhs: Board.Square.Rank, rhs: Int) -> Board.Square.Rank? {
    Board.Square.Rank(rawValue: lhs.rawValue - rhs)
  }
}
