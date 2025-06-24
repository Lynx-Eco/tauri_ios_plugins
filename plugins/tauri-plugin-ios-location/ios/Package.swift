// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-location",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-location",
            targets: ["tauri-plugin-ios-location"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-location",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)