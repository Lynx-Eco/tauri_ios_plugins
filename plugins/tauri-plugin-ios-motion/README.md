# Tauri Plugin iOS Motion

A comprehensive Tauri plugin for accessing iOS motion sensors including accelerometer, gyroscope, magnetometer, device motion, activity tracking, pedometer, and altimeter data.

## Features

- **Accelerometer**: Access device acceleration data in three axes
- **Gyroscope**: Get rotation rate data
- **Magnetometer**: Measure magnetic field strength and direction
- **Device Motion**: Combined sensor data with attitude, rotation, and gravity
- **Activity Tracking**: Detect user activities (walking, running, cycling, etc.)
- **Pedometer**: Count steps, measure distance, and track floors climbed
- **Altimeter**: Measure relative altitude and atmospheric pressure

## Installation

Add the plugin to your Tauri project:

```bash
cargo add tauri-plugin-ios-motion
```

## Configuration

### iOS

Add required usage descriptions to your `Info.plist`:

```xml
<key>NSMotionUsageDescription</key>
<string>This app needs access to motion sensors to track your physical activity.</string>
```

### Rust

Register the plugin in your Tauri app:

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_ios_motion::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Usage

### JavaScript/TypeScript

```typescript
import { motion } from 'tauri-plugin-ios-motion-api';

// Check sensor availability
const isAccelAvailable = await motion.isAccelerometerAvailable();
const isGyroAvailable = await motion.isGyroscopeAvailable();

// Start accelerometer updates
await motion.startAccelerometerUpdates();

// Get current accelerometer data
const accelData = await motion.getAccelerometerData();
console.log(`Acceleration - X: ${accelData.x}, Y: ${accelData.y}, Z: ${accelData.z}`);

// Start gyroscope updates
await motion.startGyroscopeUpdates();

// Get device motion data (combined sensors)
await motion.startDeviceMotionUpdates();
const deviceMotion = await motion.getDeviceMotionData();
console.log(`Attitude - Roll: ${deviceMotion.attitude.roll}, Pitch: ${deviceMotion.attitude.pitch}`);

// Track user activity
if (await motion.isActivityAvailable()) {
    await motion.startActivityUpdates();
    const activity = await motion.getMotionActivity();
    console.log(`User is: ${activity.walking ? 'walking' : activity.running ? 'running' : 'stationary'}`);
}

// Use pedometer
if (await motion.isPedometerAvailable()) {
    await motion.startPedometerUpdates();
    const steps = await motion.getPedometerData(startDate, endDate);
    console.log(`Steps: ${steps.numberOfSteps}, Distance: ${steps.distance}m`);
}

// Get altitude data
if (await motion.isRelativeAltitudeAvailable()) {
    const altitude = await motion.getAltimeterData();
    console.log(`Relative altitude: ${altitude.relativeAltitude}m, Pressure: ${altitude.pressure}kPa`);
}

// Set update intervals (in seconds)
await motion.setUpdateInterval({
    accelerometer: 0.1,
    gyroscope: 0.1,
    magnetometer: 0.1,
    deviceMotion: 0.1
});

// Listen for real-time updates
await motion.onMotionUpdate((event) => {
    switch (event.eventType) {
        case 'accelerometerUpdate':
            console.log('New accelerometer data:', event.data);
            break;
        case 'activityUpdate':
            console.log('Activity changed:', event.data);
            break;
        case 'pedometerUpdate':
            console.log('Step count updated:', event.data);
            break;
    }
});

// Stop updates when done
await motion.stopAccelerometerUpdates();
await motion.stopGyroscopeUpdates();
await motion.stopDeviceMotionUpdates();
```

### Rust

```rust
use tauri_plugin_ios_motion::{MotionExt, AccelerometerData};
use chrono::{DateTime, Utc};

// Get motion instance
let motion = app.motion();

// Check availability
let accel_available = motion.is_accelerometer_available()?;

// Start updates
motion.start_accelerometer_updates()?;

// Get data
let accel_data = motion.get_accelerometer_data()?;
println!("Acceleration: x={}, y={}, z={}", accel_data.x, accel_data.y, accel_data.z);

// Query activity history
let start = Utc::now() - chrono::Duration::hours(24);
let end = Utc::now();
let activities = motion.query_activity_history(ActivityQuery {
    start_date: start,
    end_date: end,
})?;

// Get pedometer data
let steps = motion.get_pedometer_data(start, end)?;
println!("Steps in last 24 hours: {}", steps.number_of_steps);
```

## API Reference

### Accelerometer

- `startAccelerometerUpdates()` - Start receiving accelerometer updates
- `stopAccelerometerUpdates()` - Stop accelerometer updates
- `getAccelerometerData()` - Get current accelerometer reading
- `isAccelerometerAvailable()` - Check if accelerometer is available

### Gyroscope

- `startGyroscopeUpdates()` - Start receiving gyroscope updates
- `stopGyroscopeUpdates()` - Stop gyroscope updates
- `getGyroscopeData()` - Get current gyroscope reading
- `isGyroscopeAvailable()` - Check if gyroscope is available

### Magnetometer

- `startMagnetometerUpdates()` - Start receiving magnetometer updates
- `stopMagnetometerUpdates()` - Stop magnetometer updates
- `getMagnetometerData()` - Get current magnetometer reading
- `isMagnetometerAvailable()` - Check if magnetometer is available

### Device Motion

- `startDeviceMotionUpdates()` - Start receiving combined sensor updates
- `stopDeviceMotionUpdates()` - Stop device motion updates
- `getDeviceMotionData()` - Get current device motion data
- `isDeviceMotionAvailable()` - Check if device motion is available

### Activity Tracking

- `getMotionActivity()` - Get current activity
- `startActivityUpdates()` - Start activity monitoring
- `stopActivityUpdates()` - Stop activity monitoring
- `queryActivityHistory(query)` - Query historical activity data

### Pedometer

- `startPedometerUpdates()` - Start step counting
- `stopPedometerUpdates()` - Stop step counting
- `getPedometerData(startDate, endDate)` - Get step data for date range
- `isPedometerAvailable()` - Check pedometer availability
- `isStepCountingAvailable()` - Check step counting support
- `isDistanceAvailable()` - Check distance measurement support
- `isFloorCountingAvailable()` - Check floor counting support

### Altimeter

- `getAltimeterData()` - Get current altitude data
- `startAltimeterUpdates()` - Start altitude monitoring
- `stopAltimeterUpdates()` - Stop altitude monitoring
- `isRelativeAltitudeAvailable()` - Check altitude sensor availability

### Configuration

- `setUpdateInterval(intervals)` - Set sensor update intervals

## Data Types

### AccelerometerData
```typescript
{
    x: number;      // Acceleration in X axis (g-force)
    y: number;      // Acceleration in Y axis (g-force)
    z: number;      // Acceleration in Z axis (g-force)
    timestamp: string; // ISO 8601 timestamp
}
```

### GyroscopeData
```typescript
{
    x: number;      // Rotation rate around X axis (radians/second)
    y: number;      // Rotation rate around Y axis (radians/second)
    z: number;      // Rotation rate around Z axis (radians/second)
    timestamp: string; // ISO 8601 timestamp
}
```

### DeviceMotionData
```typescript
{
    attitude: {
        roll: number;
        pitch: number;
        yaw: number;
        rotationMatrix: RotationMatrix;
        quaternion: Quaternion;
    };
    rotationRate: Vector3D;
    gravity: Vector3D;
    userAcceleration: Vector3D;
    magneticField?: CalibratedMagneticField;
    heading?: number;
    timestamp: string;
}
```

### MotionActivity
```typescript
{
    stationary: boolean;
    walking: boolean;
    running: boolean;
    automotive: boolean;
    cycling: boolean;
    unknown: boolean;
    startDate: string;
    confidence: 'low' | 'medium' | 'high';
}
```

### PedometerData
```typescript
{
    startDate: string;
    endDate: string;
    numberOfSteps: number;
    distance?: number;      // meters
    floorsAscended?: number;
    floorsDescended?: number;
    currentPace?: number;   // seconds per meter
    currentCadence?: number; // steps per second
    averageActivePace?: number;
}
```

## Events

The plugin emits various events for real-time updates:

- `motion://accelerometer-update` - New accelerometer data
- `motion://gyroscope-update` - New gyroscope data
- `motion://magnetometer-update` - New magnetometer data
- `motion://device-motion-update` - New device motion data
- `motion://activity-update` - Activity changed
- `motion://pedometer-update` - Step count updated
- `motion://altimeter-update` - Altitude changed
- `motion://error` - Error occurred

## Platform Support

This plugin only works on iOS devices. Desktop platforms will return `NotSupported` errors.

## Permissions

iOS requires motion sensor permissions. The plugin will automatically request permissions when needed. Make sure to include appropriate usage descriptions in your Info.plist.

## License

This plugin is licensed under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.