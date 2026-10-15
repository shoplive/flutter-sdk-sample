// swift-tools-version: 5.9
// Dev-only test package (not shipped): runs the SDK-independent bridge core of the Shoplive Flutter iOS plugins
// on the macOS host with `swift test`. Sources/BridgeCore/BridgeCore.swift is a symlink to
// shoplive_flutter_sample/ios/Classes/BridgeCore.swift; the copies in shoplive_core and shoplive_streamer must be identical.
import PackageDescription

let package = Package(
    name: "BridgeCoreTests",
    platforms: [.macOS(.v12)],
    targets: [
        .target(name: "BridgeCore", path: "Sources/BridgeCore"),
        .testTarget(name: "BridgeCoreTests", dependencies: ["BridgeCore"], path: "Tests/BridgeCoreTests"),
    ]
)
