// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "tauri-plugin-ios-barometer",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "tauri-plugin-ios-barometer",
            targets: ["tauri-plugin-ios-barometer"])
    ],
    dependencies: [
        .package(name: "Tauri", path: "../.tauri/tauri-api")
    ],
    targets: [
        .target(
            name: "tauri-plugin-ios-barometer",
            dependencies: ["Tauri"],
            path: "Sources"
        )
    ]
)