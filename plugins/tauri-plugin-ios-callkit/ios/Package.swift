// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-callkit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-callkit",
            targets: ["tauri-plugin-ios-callkit"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-callkit",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)