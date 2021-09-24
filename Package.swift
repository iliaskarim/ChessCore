// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Chess-Core",
  products: [
    .library(
      name: "Chess",
      targets: ["Chess"]),
  ],
  targets: [
    .target(
      name: "Chess",
      dependencies: []),
    .testTarget(
      name: "ChessTests",
      dependencies: ["Chess"]),
  ]
)
