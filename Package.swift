// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "VaporCursorPagination",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(
      name: "VaporCursorPagination",
      targets: ["VaporCursorPagination"],
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.48.6"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
  ],
  targets: [
    .target(
      name: "VaporCursorPagination",
      dependencies: [
        .fluentKit,
        .vapor,
      ],
    ),
    .testTarget(
      name: "VaporCursorPaginationTests",
      dependencies: ["VaporCursorPagination"],
    ),
  ],
  swiftLanguageModes: [.v6],
)

extension PackageDescription.Target.Dependency {
  static var fluentKit: Self {
    .product(name: "FluentKit", package: "fluent-kit")
  }
  static var vapor: Self {
    .product(name: "Vapor", package: "vapor")
  }
}
