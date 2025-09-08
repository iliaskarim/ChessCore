/// A square on a chessboard.
///
/// Each square is identified by its ``File`` (column) and ``Rank`` (row).
public struct Square: Hashable {
  /// A square's file.
  ///
  /// A file identifies a square's column on the board, labeled from `a` to `h`.
  public enum File: Int, CaseIterable {
    case a = 1, b, c, d, e, f, g, h
  }

  /// A square's rank.
  ///
  /// A rank identifies a square's row on the board, numbered from `1` to `8`.
  public enum Rank: Int, CaseIterable {
    case one = 1, two, three, four, five, six, seven, eight
  }

  /// Square file.
  public let file: File

  /// Square rank.
  public let rank: Rank

  /// Creates a square from a file and rank.
  ///
  /// - Parameters:
  ///   - file: The square's file.
  ///   - rank: The square's rank.
  public init(file: File, rank: Rank) {
    self.file = file
    self.rank = rank
  }
}

extension Square: CustomStringConvertible {
  public var description: String {
    "\(file)\(rank)"
  }
}

extension Square.File: CustomStringConvertible {
  public var description: String {
    String(Character(UnicodeScalar(rawValue + 96)!))
  }
}

extension Square.Rank: CustomStringConvertible {
  public var description: String {
    String(rawValue)
  }
}
