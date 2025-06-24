// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-proximity",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-proximity",
            targets: ["tauri-plugin-ios-proximity"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-proximity",
            dependencies: ["Tauri"],
            path: "Sources"
        )
    ]
)