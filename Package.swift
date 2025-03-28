// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SlowMotionVideoApp",
    products: [
        .executable(
            name: "SlowMotionSimulator",
            targets: ["SlowMotionSimulator"])
    ],
    targets: [
        .target(
            name: "SlowMotionSimulator",
            path: "SlowMotionSimulator")
    ]
)