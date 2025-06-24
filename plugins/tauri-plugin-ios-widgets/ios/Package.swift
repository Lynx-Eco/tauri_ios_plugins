// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-widgets",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-widgets",
            targets: ["tauri-plugin-ios-widgets"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-widgets",
            dependencies: ["Tauri"],
            path: "Sources"
        )
    ]
)