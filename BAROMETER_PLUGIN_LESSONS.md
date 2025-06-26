# Tauri iOS Plugin Development: Lessons from the Barometer Plugin

## Overview
This document captures the key patterns and lessons learned while implementing the barometer plugin for Tauri on iOS. These patterns apply to other iOS plugins that need to bridge native iOS APIs with Tauri's Rust/TypeScript ecosystem.

## Key Issues Encountered and Solutions

### 1. Swift Argument Parsing
**Issue**: The app crashed when pressing buttons because of incorrect argument parsing in Swift methods.

**Solution**: Use `invoke.parseArgs()` with properly defined Codable structs for all parameter parsing.

```swift
// ❌ WRONG - Tauri's Invoke doesn't have getDouble/getString methods
guard let interval = invoke.getDouble("interval") else { ... }

// ✅ CORRECT - Define a struct and use parseArgs
struct UpdateIntervalArgs: Codable {
    let interval: Double
}

@objc func setUpdateInterval(_ invoke: Invoke) {
    guard let args = try? invoke.parseArgs(UpdateIntervalArgs.self) else {
        invoke.reject("Invalid arguments")
        return
    }
    // Use args.interval
}
```

### 2. Return Value Formatting
**Issue**: Returning Swift structs directly caused crashes. Tauri expects dictionaries.

**Solution**: Always convert Swift structs to dictionaries before resolving.

```swift
// ❌ WRONG - Cannot return Swift structs directly
invoke.resolve(pressureData)

// ✅ CORRECT - Convert to dictionary
var response: [String: Any] = [
    "pressure": pressureData.pressure,
    "timestamp": pressureData.timestamp
]

// Handle optionals properly
if let altitude = pressureData.relativeAltitude {
    response["relativeAltitude"] = altitude
}

invoke.resolve(response)
```

### 3. TypeScript API Parameter Passing
**Issue**: Confusion about how to pass parameters from TypeScript to Swift.

**Pattern**: 
- Simple parameters (single values) are passed as objects with the parameter name as key
- Complex objects can be passed directly or wrapped, depending on Swift implementation

```typescript
// For simple parameters
await invoke('plugin:barometer|set_update_interval', { interval: 1.0 })
await invoke('plugin:barometer|set_reference_pressure', { pressure: 101.325 })

// For complex objects
await invoke('plugin:barometer|calibrate_barometer', { calibration: calibrationObject })
```

### 4. iOS Permissions
**Issue**: Hardware features require specific iOS permissions.

**Solution**: There are two approaches to add iOS permissions:

**Option 1**: Create an Info.plist in the project root (easier)
- Create `Info.plist` in the example app root directory (not src-tauri)
- Add only the permission keys you need
- Tauri will merge this with the generated Info.plist

**Option 2**: Edit the generated Info.plist after building
- First run `tauri ios build` to generate the iOS project
- Then edit `src-tauri/gen/apple/[app-name]_iOS/Info.plist`
- Add the required permission keys

**Important**: Do NOT use `infoPlist` in tauri.conf.json as it's not supported.

Example for barometer:
```xml
<key>NSMotionUsageDescription</key>
<string>This app uses the barometer to measure atmospheric pressure and altitude.</string>
```

Example for camera:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera to take photos and videos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select and save photos and videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone to record audio with videos.</string>
```

### 5. Async Operations and Callbacks
**Issue**: CMAltimeter provides data through async callbacks, which need careful handling.

**Best Practices**:
- Use `[weak self]` in closures to avoid retain cycles
- Check for nil self before using it
- Stop updates immediately for single readings
- Handle all error cases explicitly

```swift
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
    // Always stop updates for single readings
    self?.altimeter.stopRelativeAltitudeUpdates()
    
    if let error = error {
        invoke.reject(error.localizedDescription)
        return
    }
    
    guard let data = data, let self = self else {
        invoke.reject("No data available")
        return
    }
    
    // Process data...
}
```

### 6. Event System Issues
**Issue**: Swift/Rust bridge has type incompatibility for event triggering.

**Temporary Solution**: Disable events and use polling from the frontend.

```swift
// TODO: Re-enable once JSObject type compatibility is resolved
// self?.trigger("pressureUpdate", data: updateData)
```

### 7. Plugin Naming Conventions
**Issue**: Inconsistent naming between Rust (snake_case) and Swift (camelCase).

**Pattern**: 
- Rust commands use snake_case: `start_pressure_updates`
- Swift methods use camelCase: `startPressureUpdates`
- The bridge handles the conversion automatically

### 8. Build Configuration
**Issue**: IPA naming mismatches preventing `tauri ios dev` from working.

**Solution**: Ensure PRODUCT_NAME in project.yml matches expected naming:

```yaml
settingGroups:
  app:
    base:
      PRODUCT_NAME: Barometer Test
```

## General Patterns for iOS Plugin Development

### 1. Plugin Structure
```
plugin-name/
├── ios/
│   ├── Sources/
│   │   └── PluginName.swift    # Main plugin implementation
│   └── Package.swift            # Swift package definition
├── src/
│   ├── commands.rs             # Tauri command definitions
│   ├── models.rs               # Shared data models
│   ├── mobile.rs               # iOS/Android bridge
│   └── lib.rs                  # Plugin entry point
└── guest-js/
    └── index.ts                # TypeScript API
```

### 2. Swift Plugin Class Pattern
```swift
class MyPlugin: Plugin {
    // Initialize resources
    override init() {
        super.init()
        // Setup code
    }
    
    // Define methods with @objc
    @objc func myMethod(_ invoke: Invoke) {
        // Parse arguments
        guard let args = try? invoke.parseArgs(MyArgs.self) else {
            invoke.reject("Invalid arguments")
            return
        }
        
        // Process and return dictionary
        invoke.resolve(["key": value])
    }
}

// Export function for Tauri
@_cdecl("init_plugin_my_plugin")
func initPlugin() -> Plugin {
    return MyPlugin()
}
```

### 3. Error Handling Pattern
```swift
// Always provide meaningful error messages
guard condition else {
    invoke.reject("Descriptive error message")
    return
}

// For async operations, handle all paths
asyncOperation { result, error in
    if let error = error {
        invoke.reject(error.localizedDescription)
        return
    }
    
    guard let result = result else {
        invoke.reject("No data available")
        return
    }
    
    invoke.resolve(["data": result])
}
```

### 4. Testing Strategy
1. Create a minimal test component to isolate each API method
2. Add console logging to track execution flow
3. Test methods incrementally (availability → getters → setters → complex operations)
4. Check Xcode console for native logs and Safari for web console logs

### 5. Common Pitfalls to Avoid
- Don't assume methods like `getDouble()` exist on Invoke - always use `parseArgs()`
- Don't return Swift structs directly - convert to dictionaries
- Don't forget to handle optionals when building response dictionaries
- Don't skip adding required iOS permissions to Info.plist
- Don't forget `[weak self]` in async closures
- Always test on a real device for hardware-dependent features

### 6. Debugging Tips
1. Add print statements in Swift code - they appear in Xcode console
2. Use console.log in TypeScript - appears in Safari Web Inspector
3. Create minimal test cases to isolate issues
4. Check for required device capabilities and permissions
5. Verify plugin initialization with logging

## Camera Plugin Specific Lessons

### 1. iOS Version Compatibility
**Issue**: PHPickerViewController requires iOS 14+, causing compilation errors on older targets.

**Solution**: Use `@available` attributes and provide fallbacks:

```swift
// For properties
@available(iOS 14.0, *)
private var currentPHPickerController: PHPickerViewController?

// For methods using iOS 14+ APIs
if #available(iOS 14.0, *) {
    // Use PHPickerViewController
    var config = PHPickerConfiguration()
    // ...
} else {
    // Fallback to UIImagePickerController
    let picker = UIImagePickerController()
    // ...
}

// For extensions
@available(iOS 14.0, *)
extension CameraPlugin: PHPickerViewControllerDelegate {
    // ...
}
```

### 2. Video Quality Enums
**Issue**: `.type3840x2160` is not available on iOS versions before 11.0.

**Solution**: Use conditional compilation:

```swift
case "ultra":
    if #available(iOS 11.0, *) {
        return .type3840x2160
    } else {
        return .typeHigh
    }
```

### 3. Override Methods in Plugin Subclasses
**Issue**: When overriding base Plugin methods like `checkPermissions` and `requestPermissions`, you must:
- Add the `override` keyword
- Remove `throws` as the base method doesn't throw
- Keep the exact same signature

```swift
// ✅ CORRECT
@objc public override func checkPermissions(_ invoke: Invoke) {
    // implementation
}

// ❌ WRONG
@objc public func checkPermissions(_ invoke: Invoke) throws {
    // will cause compilation error
}
```

### 4. Array Return Values
**Issue**: Returning arrays directly causes issues with Tauri's bridge.

**Solution**: Always wrap arrays in dictionaries:

```swift
// ❌ WRONG
invoke.resolve(cameras)

// ✅ CORRECT
invoke.resolve(["cameras": cameras])

// For picker results with multiple items
if options.allowMultiple {
    invoke.resolve(["items": mediaItems])
} else {
    invoke.resolve(mediaItems.first ?? [:])
}
```

### 5. Cargo Package Naming
**Issue**: Multiple packages with the same name in workspace cause conflicts.

**Solution**: Use unique names for example apps:

```toml
[package]
name = "tauri-camera-example"  # Not just "tauri-app"
```

Also update main.rs to use the correct lib name:
```rust
fn main() {
    tauri_camera_example_lib::run();
}
```

## Conclusion
The key to successful Tauri iOS plugin development is understanding the bridge between Swift, Rust, and TypeScript. Always:
- Use proper argument parsing with Codable structs
- Convert return values to dictionaries
- Handle async operations carefully
- Add required permissions
- Test incrementally with good logging
- Handle iOS version compatibility with @available
- Wrap array returns in dictionaries
- Use override keyword for base class methods

These patterns should help create robust iOS plugins that integrate smoothly with Tauri applications.