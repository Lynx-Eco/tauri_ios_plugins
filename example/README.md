# iOS Plugins Test App

This is a comprehensive test application for all Tauri iOS plugins. Built with Tauri + Solid + TypeScript.

## Features

- Tests all 18 iOS plugins
- Desktop fallback testing
- iOS Simulator support
- Physical device testing
- Real-time test results
- Individual and batch testing

## Prerequisites

- Rust with iOS targets
- Xcode 14+ (for iOS development)
- Node.js 16+ and pnpm
- iOS Simulator or physical iOS device

## Setup

1. Install dependencies:
```bash
pnpm install
```

2. Install iOS targets (if not already installed):
```bash
rustup target add aarch64-apple-ios x86_64-apple-ios
```

3. Install cargo-mobile2 (for iOS development):
```bash
cargo install cargo-mobile2
```

## Running the App

### Desktop (Development)

Test that plugins properly return "Not supported on desktop" errors:

```bash
pnpm tauri dev
```

### iOS Simulator

1. Initialize the iOS project (first time only):
```bash
pnpm tauri ios init
```

2. Run on iOS simulator:
```bash
pnpm tauri ios dev
```

### Physical iOS Device

1. Connect your iPhone/iPad via USB
2. Open the Xcode project:
```bash
open src-tauri/gen/apple/example.xcodeproj
```
3. Select your device as the target
4. Configure signing (requires Apple Developer account)
5. Build and run (Cmd+R)

## Testing the Plugins

The app provides a comprehensive testing interface:

### Test Controls
- **Run All Tests** - Executes tests for all plugins sequentially
- **Individual Plugin Buttons** - Test specific plugins
- **Filter Dropdown** - View results by plugin

### Plugins Included

1. **HealthKit** - Health and fitness data
2. **Contacts** - Address book access
3. **Camera** - Camera capture
4. **Microphone** - Audio recording
5. **Location** - GPS and location services
6. **Photos** - Photo library
7. **Music** - Media library
8. **Keychain** - Secure storage
9. **ScreenTime** - App usage statistics
10. **Files** - File system access
11. **Messages** - SMS/MMS functionality
12. **CallKit** - VoIP integration
13. **Bluetooth** - BLE device management
14. **Shortcuts** - Siri Shortcuts
15. **Widgets** - Home screen widgets
16. **Motion** - Accelerometer & gyroscope
17. **Barometer** - Atmospheric pressure
18. **Proximity** - Proximity sensor

## Expected Behavior

### On Desktop
- All plugin calls return "Not supported on desktop" errors
- Useful for testing error handling

### On iOS Simulator
- Most plugins work with limitations:
  - Camera shows UI but can't capture real photos
  - Some sensors unavailable (barometer, proximity)
  - Limited health data
  - No real SMS/calling capabilities

### On Physical Device
- Full functionality for all plugins
- Real sensor data
- Actual permission dialogs
- Access to real user data (with permission)

## iOS Permissions

The app will request permissions as needed. Add these to your `Info.plist` for production apps:

```xml
<key>NSHealthShareUsageDescription</key>
<string>This app needs access to health data</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app needs to write health data</string>
<key>NSContactsUsageDescription</key>
<string>This app needs access to contacts</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access</string>
<key>NSAppleMusicUsageDescription</key>
<string>This app needs music library access</string>
<key>NSMotionUsageDescription</key>
<string>This app needs motion sensor access</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access</string>
```

## Debugging

### JavaScript Console
1. Run on iOS Simulator/Device
2. Open Safari
3. Enable Developer menu (Preferences > Advanced)
4. Go to Develop > [Your Device] > [Your App]

### Native Logs
View in Xcode console while running the app

### Common Issues

**Build fails**
```bash
# Clean and rebuild
cargo clean
pnpm tauri ios init --reinstall-deps
```

**Permission denied**
- Reset app permissions: Settings > General > Reset > Reset Location & Privacy
- Grant permissions when prompted

**Plugin not found**
- Ensure all plugins are added to `Cargo.toml`
- Check that plugins are registered in `lib.rs`

## Development Workflow

1. Make changes to plugin code
2. Run `cargo check` to verify compilation
3. Test on desktop first (quick iteration)
4. Test on iOS Simulator
5. Final testing on physical device

## Adding Custom Tests

Edit `src/App.tsx` to add new test cases:

```typescript
const testCustom = async () => {
  const plugin = "HealthKit";
  try {
    // Your test code here
    const result = await invoke("plugin:ios-healthkit|your_command", {
      // parameters
    });
    addResult(plugin, "Custom Test", true, `Result: ${JSON.stringify(result)}`);
  } catch (e) {
    addResult(plugin, "Custom Test", false, String(e));
  }
};
```

## Performance Testing

For performance-sensitive plugins (Motion, Location):
1. Test with continuous updates
2. Monitor CPU and battery usage in Xcode
3. Verify proper cleanup when stopping

## Contributing

When adding new plugins:
1. Follow the existing plugin structure
2. Add to workspace `Cargo.toml`
3. Register in example app
4. Add test cases
5. Update documentation

## License

This example app is part of the Tauri iOS Plugins project.