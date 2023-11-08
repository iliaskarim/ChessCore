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
