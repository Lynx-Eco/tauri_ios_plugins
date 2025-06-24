# Tauri iOS Plugins Test Plan

## 1. Build Verification

### Workspace Build
```bash
# Build the entire workspace
cargo build

# Check for any compilation errors
cargo check

# Run clippy for linting
cargo clippy -- -D warnings
```

### Individual Plugin Build
```bash
# Test each plugin individually
cd plugins/tauri-plugin-ios-healthkit
cargo build
```

## 2. Example App Creation

### Create a Test Tauri App
```bash
# Create a new Tauri app
npm create tauri-app@latest -- --beta
cd test-ios-plugins-app

# Add plugins to Cargo.toml
```

### Example Cargo.toml
```toml
[dependencies]
tauri = { version = "2.1.1", features = [] }
tauri-plugin-ios-healthkit = { path = "../tauri_ios_plugins/plugins/tauri-plugin-ios-healthkit" }
tauri-plugin-ios-contacts = { path = "../tauri_ios_plugins/plugins/tauri-plugin-ios-contacts" }
# Add other plugins as needed
```

### Example main.rs
```rust
#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_ios_healthkit::init())
        .plugin(tauri_plugin_ios_contacts::init())
        .plugin(tauri_plugin_ios_camera::init())
        // Add other plugins
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## 3. iOS Simulator Testing

### Build for iOS
```bash
# Install iOS prerequisites
rustup target add aarch64-apple-ios x86_64-apple-ios
cargo install cargo-mobile2

# Initialize iOS project
cargo mobile init

# Build and run on iOS simulator
npm run tauri ios dev
```

### Test Each Plugin's Functionality

#### HealthKit Plugin
```javascript
// Request authorization
await healthkit.requestAuthorization({
    read: ['heartRate', 'stepCount'],
    write: ['stepCount']
});

// Read data
const heartRate = await healthkit.getLatestQuantitySample('heartRate');
console.log('Heart rate:', heartRate);
```

#### Contacts Plugin
```javascript
// Check authorization
const status = await contacts.checkAuthorizationStatus();
console.log('Contact access:', status);

// Fetch contacts
const contacts = await contacts.getAllContacts();
console.log('Contacts count:', contacts.length);
```

#### Camera Plugin
```javascript
// Check camera availability
const available = await camera.isCameraAvailable();
console.log('Camera available:', available);

// Request permission
const permission = await camera.requestCameraPermission();
console.log('Camera permission:', permission);
```

## 4. Physical Device Testing

### Deploy to Physical iOS Device
1. Connect iPhone/iPad via USB
2. Open Xcode project in `src-tauri/gen/apple`
3. Select your device as target
4. Build and run

### Test Permission Dialogs
- Each plugin should show proper iOS permission dialogs
- Test granting and denying permissions
- Verify error handling when permissions are denied

## 5. API Testing

### Create Test Suite
```javascript
// test-healthkit.js
import { healthkit } from '@tauri-apps/plugin-ios-healthkit';

async function testHealthKit() {
    try {
        // Test authorization
        const authResult = await healthkit.requestAuthorization({
            read: ['heartRate', 'stepCount'],
            write: ['stepCount']
        });
        console.log('✓ Authorization:', authResult);

        // Test reading data
        const heartRate = await healthkit.getLatestQuantitySample('heartRate');
        console.log('✓ Latest heart rate:', heartRate);

        // Test writing data
        await healthkit.saveQuantitySample({
            type: 'stepCount',
            value: 1000,
            unit: 'count',
            startDate: new Date().toISOString(),
            endDate: new Date().toISOString()
        });
        console.log('✓ Saved step count');

    } catch (error) {
        console.error('✗ HealthKit test failed:', error);
    }
}
```

## 6. Platform-Specific Testing

### Desktop Fallback
```javascript
// Test that desktop returns appropriate errors
try {
    await healthkit.requestAuthorization({read: ['heartRate']});
} catch (error) {
    console.assert(error.message.includes('Not supported on desktop'));
}
```

### iOS Version Compatibility
- Test on different iOS versions (13, 14, 15, 16, 17)
- Verify version-specific features work correctly
- Check graceful degradation for older iOS versions

## 7. Error Handling Tests

### Permission Denied
```javascript
// User denies permission - should handle gracefully
try {
    const contacts = await contacts.getAllContacts();
} catch (error) {
    if (error.code === 'PERMISSION_DENIED') {
        console.log('✓ Permission denied handled correctly');
    }
}
```

### Invalid Parameters
```javascript
// Test with invalid data
try {
    await healthkit.saveQuantitySample({
        type: 'invalidType',
        value: -1
    });
} catch (error) {
    console.log('✓ Invalid parameter handled correctly');
}
```

## 8. Performance Testing

### Memory Usage
- Monitor memory usage when handling large datasets
- Test with 1000+ contacts
- Check for memory leaks with repeated API calls

### Battery Impact
- Test continuous sensor monitoring (Motion, Location)
- Verify proper cleanup when stopping monitoring

## 9. Integration Testing

### Plugin Interactions
```javascript
// Test multiple plugins together
const location = await location.getCurrentLocation();
const weather = await customAPI.getWeather(location.latitude, location.longitude);
await widgets.setWidgetData({
    kind: 'weather',
    content: {
        title: 'Current Weather',
        body: weather.temperature
    }
});
```

## 10. Create Demo App

### Build a showcase app that:
1. Lists all available plugins
2. Shows permission status for each
3. Demonstrates key features of each plugin
4. Handles errors gracefully
5. Works on both iOS and desktop (with appropriate fallbacks)

## Testing Checklist

- [ ] Workspace builds without errors
- [ ] Each plugin builds individually
- [ ] Plugins can be imported in a Tauri app
- [ ] iOS simulator runs without crashes
- [ ] Permissions are requested correctly
- [ ] API calls work as expected
- [ ] Errors are handled gracefully
- [ ] Desktop fallbacks work
- [ ] Physical device testing passes
- [ ] No memory leaks
- [ ] Documentation examples work

## Common Issues to Check

1. **Swift/Rust Bridge**: Verify data serialization works correctly
2. **Async Operations**: Ensure promises resolve/reject properly
3. **Event Emission**: Test that events reach the JavaScript layer
4. **Thread Safety**: Verify no crashes with concurrent API calls
5. **State Management**: Check that plugin state persists correctly

## Automated Testing

### Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_error_conversion() {
        let error = Error::PermissionDenied;
        let tauri_error: tauri::Error = error.into();
        assert!(tauri_error.to_string().contains("Permission denied"));
    }
}
```

### Integration Tests
```rust
#[cfg(test)]
mod integration_tests {
    use tauri::test::{mock_builder, MockRuntime};

    #[test]
    fn test_plugin_initialization() {
        let app = mock_builder()
            .plugin(tauri_plugin_ios_healthkit::init())
            .build()
            .expect("Failed to build app");
        
        // Test plugin is accessible
        let healthkit = app.healthkit();
        assert!(healthkit.is_available().is_ok());
    }
}
```

## Continuous Integration

### GitHub Actions Workflow
```yaml
name: Test iOS Plugins

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dtolnay/rust-toolchain@stable
      - run: cargo build --all
      - run: cargo test --all
      - run: cargo clippy --all -- -D warnings
```

## Documentation Testing

### Verify README examples
- Copy each code example from README files
- Ensure they compile and run
- Update any outdated examples

### API Documentation
```bash
# Generate and review API docs
cargo doc --no-deps --open
```