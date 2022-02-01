// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Focus",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "URLBar",
            targets: ["URLBar"]),
        .library(
            name: "UIHelpers",
            targets: ["UIHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.1")
    ],
    targets: [
        .target(
            name: "URLBar",
            dependencies: [
                "UIHelpers",
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "UIHelpers"
        )
    ]
)
