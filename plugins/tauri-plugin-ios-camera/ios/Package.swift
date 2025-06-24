// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-camera",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-camera",
            targets: ["tauri-plugin-ios-camera"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-camera",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)