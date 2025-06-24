// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-bluetooth",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-bluetooth",
            targets: ["tauri-plugin-ios-bluetooth"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-bluetooth",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)