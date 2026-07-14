// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Notibility",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "Notibility", targets: ["Notibility"]),
        .executable(name: "NotibilityMac", targets: ["NotibilityMac"])
    ],
    targets: [
        .target(
            name: "Notibility",
            path: "Sources/Notibility"
        ),
        .executableTarget(
            name: "NotibilityMac",
            dependencies: ["Notibility"],
            path: "Sources/NotibilityMac"
        )
    ]
)
