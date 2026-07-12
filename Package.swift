// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Notibility",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Notibility",
            path: "Sources/Notibility"
        )
    ]
)
