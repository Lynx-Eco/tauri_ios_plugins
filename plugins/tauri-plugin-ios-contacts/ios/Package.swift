// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-contacts",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-contacts",
            targets: ["tauri-plugin-ios-contacts"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-contacts",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)