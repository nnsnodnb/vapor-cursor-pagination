// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "VaporCursorPagination",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "VaporCursorPagination",
      targets: ["VaporCursorPagination"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.48.6"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    // for testing
    .package(url: "https://github.com/vapor/fluent.git", from: "4.4.0"),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.9.0")
  ],
  targets: [
    .target(
      name: "VaporCursorPagination",
      dependencies: [
        .fluentKit,
        .vapor
      ]
    ),
    .testTarget(
      name: "VaporCursorPaginationTests",
      dependencies: [
        "VaporCursorPagination",
        .fluent,
        .fluentSQLiteDriver,
        .vaporTesting
      ]
    )
  ],
  swiftLanguageModes: [.v6]
)

extension PackageDescription.Target.Dependency {
  static var fluent: Self {
    .product(name: "Fluent", package: "fluent")
  }
  static var fluentKit: Self {
    .product(name: "FluentKit", package: "fluent-kit")
  }
  static var fluentSQLiteDriver: Self {
    .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
  }
  static var vapor: Self {
    .product(name: "Vapor", package: "vapor")
  }
  static var vaporTesting: Self {
    .product(name: "VaporTesting", package: "vapor")
  }
}
