# iOS Plugins Test Suite

This is a comprehensive test application for all 18 Tauri iOS plugins. It provides a user-friendly interface to test each plugin's functionality individually or all at once.

## Features

- **All 18 iOS Plugins Integrated**:
  - HealthKit - Health and fitness data
  - Contacts - Address book access
  - Camera - Photo/video capture
  - Microphone - Audio recording
  - Location - GPS and geolocation
  - Photos - Photo library access
  - Music - Apple Music integration
  - Keychain - Secure storage
  - ScreenTime - App usage tracking
  - Files - File management
  - Messages - SMS/iMessage
  - CallKit - VoIP calling
  - Bluetooth - BLE connectivity
  - Shortcuts - Siri Shortcuts
  - Widgets - Home screen widgets
  - Motion - Motion sensors
  - Barometer - Atmospheric pressure
  - Proximity - Proximity sensor

- **Test Interface**:
  - Run all tests at once
  - Test individual plugins
  - Filter results by plugin
  - Clear results
  - Real-time test status with success/failure indicators
  - Timestamp for each test result
  - Results counter showing passed/failed tests

## Prerequisites

- macOS with Xcode installed
- iOS device or simulator
- Node.js and pnpm
- Rust toolchain with iOS targets
- Tauri CLI v2

## Setup

1. Install dependencies:
```bash
pnpm install
```

2. Install iOS targets (if not already installed):
```bash
rustup target add aarch64-apple-ios x86_64-apple-ios
```

3. Initialize iOS project (first time only):
```bash
pnpm tauri ios init
```

## Running the App

### Development Mode (iOS Simulator)

To run in development mode:
```bash
pnpm tauri ios dev
```

### Building for iOS

To build the iOS app:
```bash
pnpm tauri ios build
```

### Running on Physical Device

1. Connect your iPhone/iPad via USB
2. Open the Xcode project:
```bash
open src-tauri/gen/apple/example.xcodeproj
```
3. Select your device as the target
4. Configure signing (requires Apple Developer account)
5. Build and run (Cmd+R)

## Usage

1. **Run All Tests**: Click the "Run All Tests" button to execute tests for all 18 plugins sequentially.

2. **Test Individual Plugin**: Click on any plugin button in the grid to test that specific plugin.

3. **Filter Results**: Use the dropdown to filter test results by plugin.

4. **Clear Results**: Click "Clear Results" to remove all test results.

## Test Implementation

Each plugin test follows this pattern:
1. Check current permissions
2. Request permissions if needed
3. Test basic functionality
4. Report results with meaningful messages

Example test flow:
- ✓ Check Permissions - Status: granted
- ✓ Query Data - Found 10 items
- ✗ Write Data - Error: insufficient permissions

## Permissions

The app includes all necessary iOS permission descriptions in the Info.plist:
- Health data access (read/write)
- Contacts access
- Camera and photo library
- Microphone
- Location services (when in use & always)
- Motion sensors
- Bluetooth
- Siri integration
- Face ID

Make sure to grant these permissions when prompted for the tests to work properly.

## Test Results

Each test result shows:
- Plugin name
- Test name
- Success/failure status (✓/✗)
- Result message
- Timestamp

Results are color-coded:
- Green background: Successful test
- Red background: Failed test

The results counter at the top shows:
- Total number of tests run
- Number of passed tests (green)
- Number of failed tests (red)

## Platform Behavior

### iOS Simulator
- Most plugins work with limitations:
  - Camera shows UI but uses simulated photos
  - Some sensors unavailable (barometer, proximity)
  - Limited health data
  - No real SMS/calling capabilities

### Physical Device
- Full functionality for all plugins
- Real sensor data
- Actual permission dialogs
- Access to real user data (with permission)

## Troubleshooting

### Build Errors

If you encounter build errors:

1. Clean and rebuild:
```bash
pnpm tauri ios build --clean
```

2. Ensure all plugins are built:
```bash
cd ../plugins
for plugin in tauri-plugin-ios-*; do
  echo "Building $plugin"
  cd "$plugin"
  pnpm install && pnpm run build
  cd ..
done
```

3. Reset iOS project:
```bash
rm -rf src-tauri/gen
pnpm tauri ios init
```

### Permission Issues

- Reset app permissions: Settings > General > Reset > Reset Location & Privacy
- Delete app and reinstall for fresh permissions

### Plugin Not Found

- Verify plugin is in `Cargo.toml` dependencies
- Check plugin is registered in `src-tauri/src/lib.rs`
- Ensure plugin has `dist-js` folder with built JavaScript

## Development

The main test logic is in `src/App.tsx`. Each plugin has:
- Dedicated test function (e.g., `testHealthKit`)
- Proper error handling
- Meaningful result messages
- TypeScript types from plugin packages

To add new tests:
1. Import the plugin package
2. Create a test function following existing patterns
3. Add to the plugins array
4. Add to the test runner

## Notes

- Some tests require actual hardware (e.g., barometer, proximity sensor)
- Some tests may require specific conditions (e.g., Bluetooth devices nearby)
- Camera and photo picker tests will open system UIs
- Location tests require location services to be enabled
- Music tests require Apple Music access
- ScreenTime tests require Family Sharing or parental controls setup

## Performance Considerations

For continuous update plugins (Motion, Location):
- Tests start updates and stop them after getting data
- Monitor CPU usage in Xcode when testing
- Ensure proper cleanup to avoid battery drain

## Contributing

When adding new plugin tests:
1. Follow the existing test patterns
2. Include meaningful error messages
3. Test all permission states
4. Add appropriate timeout handling
5. Update this documentation