// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "EditorCore",
    platforms: [.macOS(.v13)],
    products: [.library(name: "EditorCore", targets: ["EditorCore"])],
    targets: [
        .target(name: "EditorCore"),
        .testTarget(name: "EditorCoreTests", dependencies: ["EditorCore"]),
    ]
)
