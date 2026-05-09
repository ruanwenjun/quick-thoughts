// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QuickThoughts",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "QuickThoughts", targets: ["QuickThoughts"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "QuickThoughts",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts"),
            ]
        ),
        .testTarget(
            name: "QuickThoughtsTests",
            dependencies: ["QuickThoughts"]
        ),
    ]
)
