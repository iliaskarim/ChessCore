// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "ChessCore",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "ChessCore",
      targets: ["ChessCore"]
    )
  ],
  targets: [
    .target(
      name: "ChessCore",
      dependencies: []
    ),
    .testTarget(
      name: "ChessCoreTests",
      dependencies: ["ChessCore"]
    )
  ]
)
