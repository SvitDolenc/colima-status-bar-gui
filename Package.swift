// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ColimaGUI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ColimaGUI", targets: ["ColimaGUI"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ColimaGUI",
            dependencies: [],
            path: "ColimaGUI"
        )
    ]
)
