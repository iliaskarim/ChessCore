private protocol AnyMoveBox: CustomStringConvertible, Sendable {
  var disambiguationFile: Square.File? { get }

  var disambiguationRank: Square.Rank? { get }

  var figure: Piece.Figure { get }

  var isCapture: Bool { get }

  var promotion: Piece.Figure? { get }

  func hash(into hasher: inout Hasher)

  func isEqual(to other: any AnyMoveBox) -> Bool

  func targetSquare(for color: Piece.Color) -> Square

  func transforms(for piece: Piece, from square: Square) -> [Board.Transform]
}

private struct Box<Value: Move & Hashable>: AnyMoveBox {
  var description: String {
    value.description
  }

  var disambiguationFile: Square.File? {
    value.disambiguationFile
  }

  var disambiguationRank: Square.Rank? {
    value.disambiguationRank
  }

  var figure: Piece.Figure {
    value.figure
  }

  var isCapture: Bool {
    value.isCapture
  }

  var promotion: Piece.Figure? {
    value.promotion
  }

  let value: Value

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(Value.self))
    hasher.combine(value)
  }

  func isEqual(to other: any AnyMoveBox) -> Bool {
    guard let other = other as? Self else {
      return false
    }

    return value == other.value
  }

  func targetSquare(for color: Piece.Color) -> Square {
    value.targetSquare(for: color)
  }

  func transforms(for piece: Piece, from square: Square) -> [Board.Transform] {
    value.transforms(for: piece, from: square)
  }
}

/// A move stored so it can be compared with moves of another type.
public struct AnyMove: Move, Equatable, Hashable, Sendable {
  public static func == (lhs: AnyMove, rhs: AnyMove) -> Bool {
    lhs.box.isEqual(to: rhs.box)
  }

  public var description: String {
    box.description
  }

  public var disambiguationFile: Square.File? {
    box.disambiguationFile
  }

  public var disambiguationRank: Square.Rank? {
    box.disambiguationRank
  }

  public var figure: Piece.Figure {
    box.figure
  }

  public var isCapture: Bool {
    box.isCapture
  }

  public var promotion: Piece.Figure? {
    box.promotion
  }

  private let box: any AnyMoveBox

  public func hash(into hasher: inout Hasher) {
    box.hash(into: &hasher)
  }

  public func targetSquare(for color: Piece.Color) -> Square {
    box.targetSquare(for: color)
  }

  public func transforms(for piece: Piece, from square: Square) -> [Board.Transform] {
    box.transforms(for: piece, from: square)
  }

  /// Wraps `base`. Wrapping an `AnyMove` returns that value unchanged.
  public init(_ base: some Move & Hashable) {
    if let base = base as? AnyMove {
      self = base
    } else {
      box = Box(value: base)
    }
  }
}
