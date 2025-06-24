// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-healthkit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-healthkit",
            targets: ["tauri-plugin-ios-healthkit"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-healthkit",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)