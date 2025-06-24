# Tauri Plugin iOS HealthKit

Access iOS HealthKit data in your Tauri applications.

## Features

- Read health and fitness data (steps, heart rate, workouts, etc.)
- Write health data with user permission
- Query historical health records
- Real-time health data updates
- Comprehensive permission management

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-healthkit = "0.1"
```

## iOS Configuration

Add to your app's `Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>This app reads your health data to provide personalized insights</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app saves workout and activity data to HealthKit</string>
```

## Usage

### Rust

```rust
use tauri_plugin_ios_healthkit::{HealthKitExt, PermissionRequest, HealthKitDataType};

// In your Tauri command
#[tauri::command]
async fn get_steps(app: tauri::AppHandle) -> Result<Vec<QuantitySample>, String> {
    let healthkit = app.healthkit();
    
    // Request permissions
    let permissions = PermissionRequest {
        read: vec![HealthKitDataType::Steps],
        write: vec![],
    };
    
    healthkit.request_permissions(permissions)
        .map_err(|e| e.to_string())?;
    
    // Query step data
    let query = QuantityQuery {
        data_type: HealthKitDataType::Steps,
        start_date: "2024-01-01T00:00:00Z".to_string(),
        end_date: "2024-01-31T23:59:59Z".to_string(),
        limit: Some(100),
    };
    
    healthkit.query_quantity_samples(query)
        .map_err(|e| e.to_string())
}
```

### JavaScript/TypeScript

```typescript
import { requestPermissions, queryQuantitySamples } from 'tauri-plugin-ios-healthkit';

// Request permissions
const permissions = await requestPermissions({
  read: ['steps', 'heartRate'],
  write: ['steps']
});

// Query health data
const steps = await queryQuantitySamples({
  dataType: 'steps',
  startDate: '2024-01-01T00:00:00Z',
  endDate: '2024-01-31T23:59:59Z',
  limit: 100
});

console.log(`Total steps: ${steps.reduce((sum, s) => sum + s.value, 0)}`);
```

## Supported Data Types

### Quantity Types
- `steps` - Step count
- `heartRate` - Heart rate (bpm)
- `activeEnergyBurned` - Active calories (kcal)
- `distanceWalkingRunning` - Distance (meters)
- `flightsClimbed` - Flights of stairs
- `height` - Height (meters)
- `weight` - Body weight (kg)
- `bodyMassIndex` - BMI
- `bodyFatPercentage` - Body fat (%)

### Category Types
- `sleepAnalysis` - Sleep data

### Characteristic Types
- `biologicalSex` - Biological sex
- `dateOfBirth` - Birth date
- `bloodType` - Blood type

## API Reference

### Commands

#### `checkPermissions()`
Check current HealthKit permissions status.

#### `requestPermissions(permissions: PermissionRequest)`
Request read/write permissions for specific data types.

#### `queryQuantitySamples(query: QuantityQuery)`
Query quantity-based health samples.

#### `writeQuantitySample(sample: QuantitySample)`
Write a new health sample to HealthKit.

## Error Handling

The plugin provides detailed error types:

- `NotAvailable` - HealthKit not available on device
- `PermissionDenied` - User denied permission
- `InvalidDateFormat` - Invalid ISO 8601 date
- `QueryFailed` - HealthKit query failed
- `WriteFailed` - Failed to write data

## License

MIT or Apache-2.0