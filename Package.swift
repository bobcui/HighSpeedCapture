// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SlowMotionVideoApp",
    dependencies: [],
    targets: [
        .target(
            name: "SlowMotionSimulator",
            dependencies: [],
            path: "SlowMotionSimulator")
    ]
)