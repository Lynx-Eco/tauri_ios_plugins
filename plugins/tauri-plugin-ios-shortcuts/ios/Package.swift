// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-shortcuts",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-shortcuts",
            targets: ["tauri-plugin-ios-shortcuts"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-shortcuts",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)