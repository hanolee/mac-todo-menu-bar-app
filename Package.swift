// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TodoMenuBar",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "TodoMenuBar",
            path: "Sources/TodoMenuBar"
        )
    ]
)
