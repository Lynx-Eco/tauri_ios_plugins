// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-microphone",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-microphone",
            targets: ["tauri-plugin-ios-microphone"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-microphone",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)