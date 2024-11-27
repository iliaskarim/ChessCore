
// MARK: - Square

/// A model representing a square on a chess board.
public struct Square: Hashable {
  /// File
  enum File: Int, CaseIterable {
    case a = 1, b, c, d, e, f, g, h

    internal init?(_ character: Character) {
      guard let ascii = character.asciiValue else {
        return nil
      }
      self.init(rawValue: Int(ascii) - 96)
    }
  }

  /// Rank
  enum Rank: Int, CaseIterable {
    case one = 1, two, three, four, five, six, seven, eight

    internal init?(_ character: Character) {
      guard let int = Int(String(character)) else {
        return nil
      }
      self.init(rawValue: int)
    }
  }

  internal let file: File

  internal let rank: Rank
  
  /// Designated initializer
  init(file: File, rank: Rank) {
    self.file = file
    self.rank = rank
  } 
  
  /// Convenience initializer
  public init?(_ string: String) {
    guard let file = string.first.map(File.init) ?? nil, let rank = string.last.map(Rank.init) ?? nil, string.count == 2 else {
      return nil
    }
    self.init(file: file, rank: rank)
  }
}

extension Square {
  static func + (lhs: Self, rhs: Vector) -> Self? {
    guard let file = File(rawValue: lhs.file.rawValue + rhs.files), let rank = Rank(rawValue: lhs.rank.rawValue + rhs.ranks) else {
      return nil
    }
    return .init(file: file, rank: rank)
  }

  static func - (lhs: Self, rhs: Vector) -> Self? {
    lhs + Vector(files: -1 * rhs.files, ranks: -1 * rhs.ranks)
  }
}
