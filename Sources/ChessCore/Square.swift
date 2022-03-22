//
//  Square.swift
//  chess
//
//  Created by Ilias Karim on 3/18/22.
//  Copyright © 2022 Ilias Karim. All rights reserved.
//

public struct Square: Hashable {
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
