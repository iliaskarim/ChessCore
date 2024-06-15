/// A model representing a square on a chess board.
public struct Square: Hashable {
  /// File
  enum File: String, CaseIterable {
    case a, b, c, d, e, f, g, h
  }

  /// Rank
  enum Rank: Int, CaseIterable {
    case one = 1, two, three, four, five, six, seven, eight
  }

  /// File
  let file: File

  /// Rank
  let rank: Rank
}
