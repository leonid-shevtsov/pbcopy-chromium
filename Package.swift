// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "pbcopy-chromium",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "ChromiumPasteboard",
            targets: ["ChromiumPasteboard"]
        ),
        .executable(
            name: "pbcopy-chromium",
            targets: ["pbcopy-chromium"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.66.0"),
    ],
    targets: [
        .target(
            name: "ChromiumPasteboard",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ]
        ),
        .executableTarget(
            name: "pbcopy-chromium",
            dependencies: [
                "ChromiumPasteboard",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
