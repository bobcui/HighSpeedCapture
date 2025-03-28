// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SlowMotionVideoApp",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "SlowMotionVideoApp",
            targets: ["SlowMotionVideoAppTarget"]),
        .executable(
            name: "SlowMotionSimulator",
            targets: ["SlowMotionSimulatorTarget"])
    ],
    dependencies: [
        
    ],
    targets: [
        .executableTarget(
            name: "SlowMotionVideoAppTarget",
            dependencies: [],
            path: "SlowMotionVideoApp"),
        .executableTarget(
            name: "SlowMotionSimulatorTarget",
            dependencies: [],
            path: "SlowMotionSimulator")
    ]
)