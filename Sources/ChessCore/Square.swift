//
//  Square.swift
//  chess
//
//  Created by Ilias Karim on 3/18/22.
//  Copyright © 2022 Ilias Karim. All rights reserved.
//

public struct Square: Hashable {
  static var a1 = Square(file: .a, rank: .one)
  static var b1 = Square(file: .b, rank: .one)
  static var c1 = Square(file: .c, rank: .one)
  static var d1 = Square(file: .d, rank: .one)
  static var e1 = Square(file: .e, rank: .one)
  static var f1 = Square(file: .f, rank: .one)
  static var g1 = Square(file: .g, rank: .one)
  static var h1 = Square(file: .h, rank: .one)

  static var a8 = Square(file: .a, rank: .eight)
  static var b8 = Square(file: .b, rank: .eight)
  static var c8 = Square(file: .c, rank: .eight)
  static var d8 = Square(file: .d, rank: .eight)
  static var e8 = Square(file: .e, rank: .eight)
  static var f8 = Square(file: .f, rank: .eight)
  static var g8 = Square(file: .g, rank: .eight)
  static var h8 = Square(file: .h, rank: .eight)

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

  let file: File
  let rank: Rank
}

extension Square {
  init?(file: File?, rank: Rank?) {
    guard let file = file, let rank = rank else {
      return nil
    }
    self = Self.init(file: file, rank: rank)
  }
}

extension Square: CustomStringConvertible {
  public var description: String {
    file.rawValue.appending(String(rank.rawValue))
  }
}

extension Square.File {
  var integerValue: Int {
    Self.allCases.firstIndex(of: self)! + 1
  }

  init?(integerValue: Int) {
    guard Self.allCases.indices.contains(integerValue - 1) else {
      return nil
    }
    self = Self.allCases[integerValue - 1]
  }

  static func + (lhs: Square.File, rhs: Int) -> Square.File? {
    Self.init(integerValue: lhs.integerValue + rhs)
  }

  static func - (lhs: Square.File, rhs: Int) -> Square.File? {
    Self.init(integerValue: lhs.integerValue - rhs)
  }
}

extension Square.Rank {
  static func == (lhs: Square.Rank, rhs: Int) -> Bool {
    lhs.rawValue == rhs
  }

  static func + (lhs: Square.Rank, rhs: Int) -> Square.Rank? {
    Square.Rank(rawValue: lhs.rawValue + rhs)
  }

  static func - (lhs: Square.Rank, rhs: Int) -> Square.Rank? {
    Square.Rank(rawValue: lhs.rawValue - rhs)
  }

  static func - (lhs: Square.Rank, rhs: Square.Rank) -> Int {
    lhs.rawValue - rhs.rawValue
  }
}
