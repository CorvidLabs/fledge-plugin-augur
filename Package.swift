// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "fledge-plugin-augur",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "fledge-augur", targets: ["fledge-augur"])
    ],
    dependencies: [
        // augur's library product, pinned to the released tag. Resolving this
        // requires read access to the private CorvidLabs/augur repository.
        .package(url: "https://github.com/CorvidLabs/augur.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "fledge-augur",
            dependencies: [
                .product(name: "AugurKit", package: "augur"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
