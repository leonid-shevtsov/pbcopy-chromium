// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "pbcopy-chromium",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.66.0"),
    ],
    targets: [
        .executableTarget(
            name: "pbcopy-chromium",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ]
        ),
    ]
)
