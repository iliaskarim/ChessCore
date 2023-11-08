/// A model representing a square on a chess board.
public struct Position: Hashable {
  /// File
  public enum File: String, CaseIterable {
    case a
    case b
    case c
    case d
    case e
    case f
    case g
    case h
  }

  /// Rank
  public enum Rank: Int, CaseIterable {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
  }

  /// File
  public let file: File

  /// Rank
  public let rank: Rank

  /// Designated initializer
  public init(file: File, rank: Rank) {
    self.file = file
    self.rank = rank
  }
}

extension Position {
  init?(file: File?, rank: Rank?) {
    guard let file = file, let rank = rank else {
      return nil
    }
    self = Self.init(file: file, rank: rank)
  }
}

extension Position: CustomStringConvertible {
  public var description: String {
    file.rawValue.appending(String(rank.rawValue))
  }
}

extension Position.File {
  var integerValue: Int {
    Self.allCases.firstIndex(of: self)! + 1
  }

  init?(integerValue: Int) {
    guard Self.allCases.indices.contains(integerValue - 1) else {
      return nil
    }
    self = Self.allCases[integerValue - 1]
  }

  static func + (lhs: Position.File, rhs: Int) -> Position.File? {
    Self.init(integerValue: lhs.integerValue + rhs)
  }

  static func - (lhs: Position.File, rhs: Int) -> Position.File? {
    Self.init(integerValue: lhs.integerValue - rhs)
  }
}

extension Position.Rank {
  static func == (lhs: Position.Rank, rhs: Int) -> Bool {
    lhs.rawValue == rhs
  }

  static func + (lhs: Position.Rank, rhs: Int) -> Position.Rank? {
    Position.Rank(rawValue: lhs.rawValue + rhs)
  }

  static func - (lhs: Position.Rank, rhs: Int) -> Position.Rank? {
    Position.Rank(rawValue: lhs.rawValue - rhs)
  }

  static func - (lhs: Position.Rank, rhs: Position.Rank) -> Int {
    lhs.rawValue - rhs.rawValue
  }
}
