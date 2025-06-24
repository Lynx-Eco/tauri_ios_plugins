# Tauri Plugin iOS Proximity

A Tauri plugin for accessing the iOS proximity sensor to detect when objects are near the device's screen.

## Features

- **Proximity Detection**: Detect when objects are near the device
- **Real-time Monitoring**: Get notified when proximity state changes
- **Display Control**: Manage screen auto-lock behavior
- **Session Statistics**: Track proximity detection metrics

## Installation

Add the plugin to your Tauri project:

```bash
cargo add tauri-plugin-ios-proximity
```

## Configuration

### iOS

No special permissions are required for proximity sensor access on iOS.

### Rust

Register the plugin in your Tauri app:

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_ios_proximity::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Usage

### JavaScript/TypeScript

```typescript
import { proximity } from 'tauri-plugin-ios-proximity-api';

// Check if proximity sensor is available
const isAvailable = await proximity.isProximityAvailable();
console.log(`Proximity sensor available: ${isAvailable}`);

// Enable proximity monitoring (required before use)
await proximity.enableProximityMonitoring();

// Start monitoring proximity
await proximity.startProximityMonitoring();

// Get current proximity state
const state = await proximity.getProximityState();
console.log(`Object is ${state.isClose ? 'near' : 'far from'} the device`);

// Control display auto-lock
// Disable auto-lock (keep screen on)
await proximity.setDisplayAutoLock(false);

// Get auto-lock state
const lockState = await proximity.getDisplayAutoLockState();
console.log(`Auto-lock enabled: ${lockState.enabled}`);

// Listen for proximity changes
await proximity.onProximityChange((event) => {
    switch (event.eventType) {
        case 'proximityDetected':
            console.log('Object detected near device');
            // Screen typically turns off when proximity detected
            break;
        case 'proximityCleared':
            console.log('Object moved away from device');
            // Screen turns back on
            break;
        case 'monitoringStarted':
            console.log('Proximity monitoring started');
            break;
        case 'monitoringStopped':
            console.log('Proximity monitoring stopped');
            break;
    }
});

// Stop monitoring when done
await proximity.stopProximityMonitoring();

// Disable proximity sensor
await proximity.disableProximityMonitoring();
```

### Rust

```rust
use tauri_plugin_ios_proximity::{ProximityExt, ProximityState};

// Get proximity instance
let proximity = app.proximity();

// Check availability
let available = proximity.is_proximity_available()?;

// Enable and start monitoring
proximity.enable_proximity_monitoring()?;
proximity.start_proximity_monitoring()?;

// Get current state
let state = proximity.get_proximity_state()?;
if state.is_close {
    println!("Object detected near screen");
}

// Control display
proximity.set_display_auto_lock(false)?; // Keep screen on
```

## API Reference

### Methods

- `isProximityAvailable()` - Check if proximity sensor is available
- `enableProximityMonitoring()` - Enable the proximity sensor
- `disableProximityMonitoring()` - Disable the proximity sensor
- `startProximityMonitoring()` - Start monitoring proximity changes
- `stopProximityMonitoring()` - Stop monitoring proximity changes
- `getProximityState()` - Get current proximity state
- `setDisplayAutoLock(enabled)` - Control screen auto-lock behavior
- `getDisplayAutoLockState()` - Get display auto-lock configuration

## Data Types

### ProximityState
```typescript
{
    isClose: boolean;      // True if object is near
    timestamp: string;     // ISO 8601 timestamp
}
```

### DisplayAutoLockState
```typescript
{
    enabled: boolean;                    // Auto-lock enabled
    proximityMonitoringEnabled: boolean; // Sensor active
}
```

### ProximityEvent
```typescript
{
    eventType: 'proximityDetected' | 'proximityCleared' | 'monitoringStarted' | 'monitoringStopped' | 'error';
    state: ProximityState;
    timestamp: string;
}
```

## Events

The plugin emits these events:

- `proximity://proximity-detected` - Object detected near screen
- `proximity://proximity-cleared` - Object moved away
- `proximity://monitoring-started` - Monitoring activated
- `proximity://monitoring-stopped` - Monitoring deactivated
- `proximity://error` - Error occurred

## Typical Use Cases

### Phone Call Detection
The proximity sensor is commonly used during phone calls to turn off the screen when the phone is held to the ear:

```typescript
// During call setup
await proximity.enableProximityMonitoring();
await proximity.startProximityMonitoring();

// During call teardown
await proximity.stopProximityMonitoring();
await proximity.disableProximityMonitoring();
```

### Pocket Detection
Detect if the device is in a pocket or bag:

```typescript
const state = await proximity.getProximityState();
if (state.isClose) {
    // Device might be in pocket
    // Disable certain features to save battery
}
```

### Display Management
Control screen behavior for specific apps:

```typescript
// Keep screen on for reading app
await proximity.setDisplayAutoLock(false);

// Re-enable auto-lock when done
await proximity.setDisplayAutoLock(true);
```

## Important Notes

1. **Screen Behavior**: When proximity is detected, iOS automatically turns off the screen
2. **Enable First**: You must call `enableProximityMonitoring()` before starting monitoring
3. **Battery Impact**: Continuous proximity monitoring can impact battery life
4. **Call Integration**: The system automatically manages proximity during phone calls

## Platform Support

This plugin only works on iOS devices with proximity sensors (all iPhones). Desktop platforms will return `NotSupported` errors.

## License

This plugin is licensed under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.