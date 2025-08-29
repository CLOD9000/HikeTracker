// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HikeTracker",
    platforms: [
            .iOS(.v14)   // o v14/v15 se vuoi richiedere una versione minima più recente
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HikeTracker",
            targets: ["HikeTracker"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HikeTracker"),
        .testTarget(
            name: "HikeTrackerTests",
            dependencies: ["HikeTracker"]
        ),
    ]
)
