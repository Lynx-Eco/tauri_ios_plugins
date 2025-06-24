# Tauri iOS Plugins

A collection of Tauri plugins providing access to native iOS APIs for iPhone applications.

## Overview

This workspace contains individual Tauri plugins that interface with various iOS system APIs, allowing Tauri applications to access native iOS functionality like HealthKit, Contacts, Camera, and more.

## Available Plugins

### Core System APIs
- **tauri-plugin-ios-healthkit** - Access to health and fitness data through HealthKit
- **tauri-plugin-ios-contacts** - Read and write access to the device's contacts
- **tauri-plugin-ios-camera** - Camera capture and photo library access
- **tauri-plugin-ios-microphone** - Audio recording capabilities
- **tauri-plugin-ios-screentime** - Screen time and app usage statistics
- **tauri-plugin-ios-location** - Core Location services for GPS and location data

### Media & Storage
- **tauri-plugin-ios-photos** - Photo library management and metadata
- **tauri-plugin-ios-music** - Access to the device's music library
- **tauri-plugin-ios-files** - File system and document access
- **tauri-plugin-ios-keychain** - Secure credential storage using iOS Keychain

### Communication & Connectivity
- **tauri-plugin-ios-messages** - SMS and iMessage integration
- **tauri-plugin-ios-callkit** - Phone call integration and management
- **tauri-plugin-ios-bluetooth** - Bluetooth device discovery and communication

### System Features
- **tauri-plugin-ios-shortcuts** - Siri Shortcuts integration
- **tauri-plugin-ios-widgets** - Widget Kit integration for home screen widgets

### Sensors & Motion
- **tauri-plugin-ios-motion** - Accelerometer, gyroscope, and motion data
- **tauri-plugin-ios-barometer** - Atmospheric pressure readings
- **tauri-plugin-ios-proximity** - Proximity sensor data

## Project Structure

```
tauri_ios_plugins/
├── Cargo.toml              # Workspace configuration
├── README.md               # This file
├── plugins/                # Individual plugin packages
│   ├── tauri-plugin-ios-healthkit/
│   │   ├── Cargo.toml
│   │   ├── build.rs
│   │   ├── src/
│   │   │   ├── lib.rs
│   │   │   ├── models.rs
│   │   │   ├── error.rs
│   │   │   ├── commands.rs
│   │   │   ├── desktop.rs
│   │   │   └── mobile.rs
│   │   └── ios/           # iOS-specific implementation
│   │       ├── Package.swift
│   │       └── Sources/
│   └── ...                # Other plugins follow same structure
└── crates/
    └── shared/            # Shared utilities and types

```

## Getting Started

### Prerequisites
- Rust 1.70 or higher
- Xcode 14.0 or higher (for iOS development)
- iOS 13.0+ deployment target
- Tauri 2.0

### Installation

Add the desired plugin to your Tauri app's `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-healthkit = { path = "../path/to/tauri_ios_plugins/plugins/tauri-plugin-ios-healthkit" }
```

### Usage Example

```rust
use tauri_plugin_ios_healthkit::HealthKitExt;

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_ios_healthkit::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

In your frontend code:

```javascript
import { checkPermissions, requestPermissions, queryQuantitySamples } from '@tauri-apps/plugin-ios-healthkit';

// Check current permissions
const status = await checkPermissions();

// Request permissions
const permissions = await requestPermissions({
  read: ['steps', 'heartRate'],
  write: ['steps']
});

// Query health data
const samples = await queryQuantitySamples({
  dataType: 'steps',
  startDate: '2024-01-01T00:00:00Z',
  endDate: '2024-01-31T23:59:59Z'
});
```

## iOS Permissions

Each plugin requires specific iOS permissions to be declared in your app's `Info.plist`. The required permissions are documented in each plugin's README.

Example for HealthKit:
```xml
<key>NSHealthShareUsageDescription</key>
<string>This app needs access to read your health data</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app needs access to write health data</string>
```

## Development

### Building a Plugin

```bash
cd plugins/tauri-plugin-ios-healthkit
cargo build
```

### Running Tests

```bash
cargo test --workspace
```

### Adding a New Plugin

1. Create a new directory under `plugins/`
2. Copy the structure from an existing plugin (like healthkit)
3. Update the `Cargo.toml` workspace members
4. Implement the iOS-specific code in Swift
5. Add appropriate permissions to documentation

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

This project is licensed under either of:
- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE))
- MIT license ([LICENSE-MIT](LICENSE-MIT))

at your option.

## Acknowledgments

Built with [Tauri](https://tauri.app), the framework for building smaller, faster, and more secure desktop and mobile applications with a web frontend.