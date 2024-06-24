
struct Vector {
  /// File translation
  let files: Int

  /// Rank translation
  let ranks: Int

  /// Designated initializer
  init(files: Int = 0, ranks: Int = 0) {
    self.files = files
    self.ranks = ranks
  }
}
