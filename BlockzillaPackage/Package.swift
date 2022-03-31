// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Focus",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "UIHelpers",
            targets: ["UIHelpers"]),
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "UIHelpers"
        ),
        .target(
            name: "DesignSystem"
        )
    ]
)
