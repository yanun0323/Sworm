// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sworm",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Sworm",
            targets: ["Sworm"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Sworm",
            dependencies: [
                .product(name: "SQLite", package: "sqlite.swift")
            ]
        ),
//        .executableTarget(
//            name: "Sworm",
//            dependencies: [
//                .product(name: "SQLite", package: "SQLite.swift")
//            ]
//        ),
        .testTarget(
            name: "SwormTests",
            dependencies: ["Sworm"]
        ),
    ]
)
