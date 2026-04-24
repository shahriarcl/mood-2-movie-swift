// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mood2MovieSwift",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Mood2MovieSwift",
            targets: ["Mood2MovieSwift"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Mood2MovieSwift",
            path: "Mood2MovieSwift/Mood2MovieSwift"
        ),
        .testTarget(
            name: "Mood2MovieSwiftTests",
            dependencies: ["Mood2MovieSwift"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
