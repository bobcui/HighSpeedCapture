// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "SlowMotionVideoApp",
    products: [
        .executable(name: "SlowMotionSimulator", targets: ["SlowMotionSimulator"]),
        .library(name: "SlowMotionVideoApp", targets: ["SlowMotionVideoApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(name: "SlowMotionSimulator", path: "SlowMotionSimulator"),
        .target(name: "SlowMotionVideoApp", path: "SlowMotionVideoApp")
    ]
)