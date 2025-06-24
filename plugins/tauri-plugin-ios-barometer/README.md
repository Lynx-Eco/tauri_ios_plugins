# Tauri Plugin iOS Barometer

A Tauri plugin for accessing the iOS barometric pressure sensor to measure atmospheric pressure, altitude, and predict weather changes.

## Features

- **Pressure Monitoring**: Real-time atmospheric pressure measurements
- **Altitude Calculation**: Calculate altitude based on pressure readings
- **Weather Prediction**: Simple weather condition predictions based on pressure trends
- **Calibration Support**: Calibrate the barometer with reference values
- **Pressure History**: Track pressure changes over time

## Installation

Add the plugin to your Tauri project:

```bash
cargo add tauri-plugin-ios-barometer
```

## Configuration

### iOS

No special permissions are required for barometer access on iOS.

### Rust

Register the plugin in your Tauri app:

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_ios_barometer::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Usage

### JavaScript/TypeScript

```typescript
import { barometer } from 'tauri-plugin-ios-barometer-api';

// Check if barometer is available
const isAvailable = await barometer.isBarometerAvailable();
if (!isAvailable) {
    console.log("Barometer not available on this device");
    return;
}

// Get current pressure data
const pressure = await barometer.getPressureData();
console.log(`Pressure: ${pressure.pressure} kPa`);
console.log(`Relative Altitude: ${pressure.relativeAltitude} meters`);

// Start continuous pressure updates
await barometer.startPressureUpdates();

// Set update interval (in seconds)
await barometer.setUpdateInterval(0.5);

// Calculate altitude from pressure
const altitude = await barometer.getAltitudeFromPressure(pressure.pressure);
console.log(`Calculated altitude: ${altitude} meters`);

// Get/Set reference pressure for altitude calculations
const refPressure = await barometer.getReferencePressure();
await barometer.setReferencePressure(101.325); // Sea level standard

// Get weather prediction
const weather = await barometer.getWeatherData();
console.log(`Weather condition: ${weather.weatherCondition}`);
console.log(`Pressure trend: ${weather.pressureTrend}`);

// Calibrate barometer
await barometer.calibrateBarometer({
    referencePressure: 101.325,
    referenceAltitude: 0, // Sea level
    calibrationDate: new Date().toISOString()
});

// Listen for pressure updates
await barometer.onBarometerUpdate((event) => {
    switch (event.eventType) {
        case 'pressureUpdate':
            console.log('New pressure:', event.data.pressure);
            break;
        case 'altitudeUpdate':
            console.log('Altitude changed:', event.data.altitude);
            break;
        case 'weatherChange':
            console.log('Weather condition changed:', event.data);
            break;
    }
});

// Stop updates when done
await barometer.stopPressureUpdates();
await barometer.stopAltitudeUpdates();
```

### Rust

```rust
use tauri_plugin_ios_barometer::{BarometerExt, PressureData};

// Get barometer instance
let barometer = app.barometer();

// Check availability
let available = barometer.is_barometer_available()?;

// Get pressure reading
let pressure_data = barometer.get_pressure_data()?;
println!("Current pressure: {} kPa", pressure_data.pressure);

// Start monitoring
barometer.start_pressure_updates()?;

// Get weather data
let weather = barometer.get_weather_data()?;
match weather.weather_condition {
    WeatherCondition::Fair => println!("Good weather expected"),
    WeatherCondition::Stormy => println!("Storm approaching"),
    _ => println!("Weather changing"),
}
```

## API Reference

### Methods

- `isBarometerAvailable()` - Check if barometer is available
- `startPressureUpdates()` - Start continuous pressure monitoring
- `stopPressureUpdates()` - Stop pressure monitoring
- `getPressureData()` - Get current pressure reading
- `setUpdateInterval(interval)` - Set update frequency (seconds)
- `getReferencePressure()` - Get reference pressure for calculations
- `setReferencePressure(pressure)` - Set reference pressure (kPa)
- `getAltitudeFromPressure(pressure)` - Calculate altitude
- `startAltitudeUpdates()` - Start altitude monitoring
- `stopAltitudeUpdates()` - Stop altitude monitoring
- `getWeatherData()` - Get weather prediction data
- `calibrateBarometer(calibration)` - Calibrate the sensor

## Data Types

### PressureData
```typescript
{
    pressure: number;           // Atmospheric pressure in kilopascals (kPa)
    relativeAltitude?: number;  // Relative altitude change in meters
    temperature?: number;       // Temperature in Celsius (if available)
    timestamp: string;          // ISO 8601 timestamp
}
```

### WeatherData
```typescript
{
    pressure: number;           // Current pressure (kPa)
    pressureTrend: 'rising' | 'falling' | 'steady';
    altitude?: number;          // Calculated altitude (meters)
    temperature?: number;       // Temperature (Celsius)
    humidity?: number;          // Humidity percentage
    weatherCondition: 'fair' | 'changing' | 'stormy' | 'unknown';
    timestamp: string;
}
```

### BarometerCalibration
```typescript
{
    referencePressure: number;  // Reference pressure (kPa)
    referenceAltitude: number;  // Reference altitude (meters)
    calibrationDate: string;    // ISO 8601 date
}
```

## Events

The plugin emits these events:

- `barometer://pressure-update` - New pressure reading
- `barometer://altitude-update` - Altitude changed
- `barometer://weather-change` - Weather condition changed
- `barometer://calibration-complete` - Calibration finished
- `barometer://error` - Error occurred

## Pressure Units

- Pressure is measured in kilopascals (kPa)
- Standard atmospheric pressure at sea level: 101.325 kPa
- Valid pressure range: 80-120 kPa

## Altitude Calculation

Altitude is calculated using the barometric formula:

```
h = (T₀/L) × (1 - (P/P₀)^(R×L/(g×M)))
```

Where:
- h = altitude
- T₀ = standard temperature (288.15 K)
- L = temperature lapse rate (0.0065 K/m)
- P = measured pressure
- P₀ = reference pressure
- R = gas constant
- g = gravity
- M = molar mass of air

## Weather Prediction

Simple weather predictions based on:
- **High pressure (>102.5 kPa)**: Fair weather
- **Low pressure (<100.5 kPa)**: Stormy conditions
- **Falling pressure**: Weather changing
- **Rising pressure**: Improving conditions

## Platform Support

This plugin only works on iOS devices with barometric pressure sensors (iPhone 6 and later). Desktop platforms will return `NotSupported` errors.

## License

This plugin is licensed under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.