# Tauri Plugin iOS Location

Comprehensive location services for Tauri iOS applications using Core Location.

## Features

- Current location with configurable accuracy
- Continuous location updates
- Significant location change monitoring
- Region monitoring (geofencing)
- Heading/compass updates
- Forward and reverse geocoding
- Distance calculations
- Background location support
- Permission management

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-location = "0.1"
```

## iOS Configuration

Add to your app's `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show your position on the map</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access in the background for continuous tracking</string>
```

For background location updates, add to your app's capabilities:
- Background Modes > Location updates

## Usage

### Rust

```rust
use tauri_plugin_ios_location::{LocationExt, LocationOptions, LocationAccuracy, PermissionRequest};

// Get current location
#[tauri::command]
async fn get_location(app: tauri::AppHandle) -> Result<LocationData, String> {
    let location = app.location();
    
    // Check permissions
    let permissions = location.check_permissions()
        .map_err(|e| e.to_string())?;
    
    if permissions.when_in_use != PermissionState::Granted {
        location.request_permissions(PermissionRequest {
            accuracy: LocationAccuracy::Best,
            background: false,
        }).map_err(|e| e.to_string())?;
    }
    
    // Get location with options
    let options = LocationOptions {
        accuracy: LocationAccuracy::NearestTenMeters,
        distance_filter: Some(10.0), // 10 meters
        timeout: Some(30000), // 30 seconds
        maximum_age: Some(5000), // 5 seconds
        enable_high_accuracy: true,
        show_background_location_indicator: true,
    };
    
    location.get_current_location(options)
        .map_err(|e| e.to_string())
}

// Monitor region (geofencing)
#[tauri::command]
async fn monitor_area(app: tauri::AppHandle) -> Result<(), String> {
    let region = Region {
        identifier: "home".to_string(),
        center: Coordinates {
            latitude: 37.7749,
            longitude: -122.4194,
        },
        radius: 100.0, // 100 meters
        notify_on_entry: true,
        notify_on_exit: true,
    };
    
    app.location()
        .start_monitoring_region(region)
        .map_err(|e| e.to_string())
}
```

### JavaScript/TypeScript

```typescript
import { 
  checkPermissions,
  requestPermissions,
  getCurrentLocation,
  startLocationUpdates,
  stopLocationUpdates,
  geocodeAddress,
  reverseGeocode,
  getDistance,
  addPluginListener
} from 'tauri-plugin-ios-location';

// Check and request permissions
const permissions = await checkPermissions();
if (permissions.whenInUse !== 'granted') {
  await requestPermissions({
    accuracy: 'best',
    background: false
  });
}

// Get current location
const location = await getCurrentLocation({
  accuracy: 'nearestTenMeters',
  distanceFilter: 10,
  timeout: 30000,
  maximumAge: 5000,
  enableHighAccuracy: true
});

console.log(`Location: ${location.coordinates.latitude}, ${location.coordinates.longitude}`);
console.log(`Accuracy: ${location.accuracy}m`);

// Start continuous location updates
await startLocationUpdates({
  accuracy: 'best',
  distanceFilter: 5,
  showBackgroundLocationIndicator: true
});

// Listen for location updates
const locationListener = await addPluginListener(
  'ios-location',
  'locationUpdate',
  (location) => {
    console.log('New location:', location.coordinates);
    console.log('Speed:', location.speed, 'm/s');
    console.log('Heading:', location.heading, '°');
  }
);

// Geocoding
const geocodeResults = await geocodeAddress('1 Infinite Loop, Cupertino, CA');
geocodeResults.forEach(result => {
  console.log(`Found: ${result.placemark.formattedAddress}`);
  console.log(`Coords: ${result.coordinates.latitude}, ${result.coordinates.longitude}`);
});

// Reverse geocoding
const placemarks = await reverseGeocode({
  latitude: 37.3318,
  longitude: -122.0312
});

placemarks.forEach(place => {
  console.log(`${place.name}, ${place.locality}, ${place.country}`);
});

// Calculate distance
const distance = await getDistance(
  { latitude: 37.7749, longitude: -122.4194 }, // San Francisco
  { latitude: 34.0522, longitude: -118.2437 }  // Los Angeles
);
console.log(`Distance: ${distance / 1000} km`);

// Region monitoring
await startMonitoringRegion({
  identifier: 'office',
  center: { latitude: 37.7749, longitude: -122.4194 },
  radius: 50,
  notifyOnEntry: true,
  notifyOnExit: true
});

// Listen for region events
const regionListener = await addPluginListener(
  'ios-location',
  'regionEntered',
  (event) => {
    console.log(`Entered region: ${event.identifier}`);
  }
);

// Clean up
locationListener.remove();
regionListener.remove();
await stopLocationUpdates();
```

## API Reference

### Types

#### LocationData
```typescript
interface LocationData {
  coordinates: Coordinates;
  altitude?: number;
  accuracy: number;
  altitudeAccuracy?: number;
  heading?: number;
  speed?: number;
  timestamp: string;
  floor?: { level: number };
}
```

#### LocationOptions
```typescript
interface LocationOptions {
  accuracy: LocationAccuracy;
  distanceFilter?: number;        // Minimum distance (meters) to trigger update
  timeout?: number;               // Timeout in milliseconds
  maximumAge?: number;            // Maximum age of cached location
  enableHighAccuracy: boolean;
  showBackgroundLocationIndicator: boolean;
}
```

#### LocationAccuracy
```typescript
type LocationAccuracy = 
  | 'best'
  | 'bestForNavigation'
  | 'nearestTenMeters'
  | 'hundredMeters'
  | 'kilometer'
  | 'threeKilometers'
  | 'reduced';
```

### Commands

#### `checkPermissions()`
Check location permission status.

#### `requestPermissions(request: PermissionRequest)`
Request location permissions.

#### `getCurrentLocation(options?: LocationOptions)`
Get a single location update.

#### `startLocationUpdates(options?: LocationOptions)`
Start continuous location updates.

#### `stopLocationUpdates()`
Stop location updates.

#### `startMonitoringRegion(region: Region)`
Start monitoring a geographic region.

#### `stopMonitoringRegion(identifier: string)`
Stop monitoring a region.

#### `geocodeAddress(address: string)`
Convert address to coordinates.

#### `reverseGeocode(coordinates: Coordinates)`
Convert coordinates to address.

#### `getDistance(from: Coordinates, to: Coordinates)`
Calculate distance between two points in meters.

## Events

The plugin emits the following events:

- `locationUpdate` - New location data available
- `headingUpdate` - Compass heading changed
- `regionEntered` - Entered a monitored region
- `regionExited` - Exited a monitored region
- `authorizationChanged` - Location permission changed
- `error` - Location error occurred

## Accuracy Levels

- `best` - Highest possible accuracy
- `bestForNavigation` - Best for navigation apps
- `nearestTenMeters` - Accurate to ~10 meters
- `hundredMeters` - Accurate to ~100 meters
- `kilometer` - Accurate to ~1 kilometer
- `threeKilometers` - Accurate to ~3 kilometers
- `reduced` - Reduced accuracy (iOS 14+)

## Error Handling

The plugin provides detailed error types:

- `LocationServicesDisabled` - Location services turned off
- `PermissionDenied` - User denied location access
- `LocationNotAvailable` - Unable to determine location
- `Timeout` - Location request timed out
- `RegionMonitoringNotAvailable` - Device doesn't support regions

## Background Location

For background location updates:
1. Request "always" authorization
2. Enable "Location updates" background mode
3. Set `showBackgroundLocationIndicator` to show the blue status bar

## License

MIT or Apache-2.0