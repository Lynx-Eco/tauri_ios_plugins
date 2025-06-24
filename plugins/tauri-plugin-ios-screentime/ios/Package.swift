// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-screentime",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-screentime",
            targets: ["tauri-plugin-ios-screentime"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-screentime",
            dependencies: [
                .product(name: "Tauri", package: "Tauri")
            ],
            path: "Sources")
    ]
)