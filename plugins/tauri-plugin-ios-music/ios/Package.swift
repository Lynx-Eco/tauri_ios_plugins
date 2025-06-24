// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-music",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-music",
            targets: ["tauri-plugin-ios-music"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-music",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)