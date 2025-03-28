// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SlowMotionVideoApp",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "SlowMotionSimulator",
            targets: ["SlowMotionSimulatorTarget"])
    ],
    dependencies: [
        
    ],
    targets: [
        .executableTarget(
            name: "SlowMotionSimulatorTarget",
            dependencies: [],
            path: "SlowMotionSimulator")
    ]
)