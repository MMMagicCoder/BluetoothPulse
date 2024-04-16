// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BluetoothPulse",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "BluetoothPulse",
            targets: ["BluetoothPulse"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BluetoothPulse",
            dependencies: [])
    ]
)

