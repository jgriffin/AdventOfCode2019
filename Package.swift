// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AdventOfCode2019",
    platforms: [
        .macOS(.v10_15), .iOS(.v17),
    ],
    products: [
        .library(
            name: "AdventOfCode2019",
            targets: ["AdventOfCode2019"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.13.0"),
        .package(url: "https://github.com/jgriffin/EulerTools.git", from: "0.2.3"),
    ],
    targets: [
        .target(
            name: "AdventOfCode2019",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Parsing", package: "swift-parsing"),
            ]
        ),
        .testTarget(
            name: "AdventOfCode2019Tests",
            dependencies: [
                "AdventOfCode2019",
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "EulerTools", package: "EulerTools"),
            ],
            resources: [.process("resources")]
        ),
    ]
)
