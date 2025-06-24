# Tauri Plugin iOS Bluetooth

A comprehensive Tauri plugin for iOS Bluetooth Low Energy (BLE) functionality using Core Bluetooth.

## Features

### Central Mode (Client)
- Scan for BLE peripherals with filtering
- Connect/disconnect peripherals
- Discover services and characteristics
- Read/write characteristic values
- Subscribe to notifications/indications
- Read/write descriptors
- Monitor RSSI values

### Peripheral Mode (Server)
- Advertise as a BLE peripheral
- Add custom services and characteristics
- Handle read/write requests from centrals
- Send notifications/indications to subscribed centrals
- Manage multiple connections

## Installation

Add the plugin to your Tauri project:

```toml
[dependencies]
tauri-plugin-ios-bluetooth = { path = "../path/to/plugin" }
```

## Usage

### Central Mode Example

```rust
use tauri_plugin_ios_bluetooth::{BluetoothExt, ScanOptions, ScanMode, ConnectionOptions};

#[tauri::command]
async fn scan_for_devices<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    // Request authorization if needed
    let status = app.bluetooth()
        .request_authorization()
        .map_err(|e| e.to_string())?;
    
    if status != AuthorizationStatus::Authorized {
        return Err("Bluetooth not authorized".to_string());
    }
    
    // Check if Bluetooth is enabled
    if !app.bluetooth().is_bluetooth_enabled().unwrap_or(false) {
        return Err("Bluetooth is not enabled".to_string());
    }
    
    // Start scanning
    let options = ScanOptions {
        service_uuids: vec![], // Scan for all devices
        allow_duplicates: false,
        scan_mode: ScanMode::Balanced,
    };
    
    app.bluetooth()
        .start_central_scan(options)
        .map_err(|e| e.to_string())?;
    
    Ok(())
}

#[tauri::command]
async fn connect_to_device<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    device_uuid: String,
) -> Result<(), String> {
    let options = ConnectionOptions {
        auto_connect: false,
        timeout_ms: Some(10000), // 10 seconds
    };
    
    app.bluetooth()
        .connect_peripheral(device_uuid, options)
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn read_battery_level<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    device_uuid: String,
) -> Result<u8, String> {
    // Battery service UUID: 180F
    // Battery level characteristic UUID: 2A19
    
    // Discover services
    let services = app.bluetooth()
        .discover_services(device_uuid.clone(), Some(vec!["180F".to_string()]))
        .map_err(|e| e.to_string())?;
    
    // Discover characteristics
    let characteristics = app.bluetooth()
        .discover_characteristics(
            device_uuid.clone(),
            "180F".to_string(),
            Some(vec!["2A19".to_string()])
        )
        .map_err(|e| e.to_string())?;
    
    // Read battery level
    let value = app.bluetooth()
        .read_characteristic(device_uuid, "2A19".to_string())
        .map_err(|e| e.to_string())?;
    
    Ok(value.first().copied().unwrap_or(0))
}
```

### Peripheral Mode Example

```rust
use tauri_plugin_ios_bluetooth::{
    BluetoothExt, AdvertisingData, PeripheralService, PeripheralCharacteristic,
    CharacteristicProperties, CharacteristicPermissions
};

#[tauri::command]
async fn start_advertising<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    // Create a custom service
    let service = PeripheralService {
        uuid: "12345678-1234-1234-1234-123456789012".to_string(),
        is_primary: true,
        characteristics: vec![
            PeripheralCharacteristic {
                uuid: "87654321-4321-4321-4321-210987654321".to_string(),
                properties: CharacteristicProperties {
                    read: true,
                    write: true,
                    notify: true,
                    ..Default::default()
                },
                permissions: CharacteristicPermissions {
                    readable: true,
                    writeable: true,
                    ..Default::default()
                },
                value: Some(vec![0x01, 0x02, 0x03]),
                descriptors: vec![],
            }
        ],
    };
    
    // Add the service
    app.bluetooth()
        .add_service(service)
        .map_err(|e| e.to_string())?;
    
    // Start advertising
    let advertising_data = AdvertisingData {
        local_name: Some("My Tauri Device".to_string()),
        service_uuids: vec!["12345678-1234-1234-1234-123456789012".to_string()],
        manufacturer_data: None,
        service_data: None,
        tx_power_level: None,
        is_connectable: true,
    };
    
    app.bluetooth()
        .start_peripheral_advertising(advertising_data)
        .map_err(|e| e.to_string())
}
```

## Events

The plugin emits various events for Bluetooth state changes:

```rust
// Listen for state changes
app.listen_global("stateChanged", |event| {
    println!("Bluetooth state: {:?}", event.payload());
});

// Listen for discovered peripherals
app.listen_global("peripheralDiscovered", |event| {
    println!("Found device: {:?}", event.payload());
});

// Listen for connection events
app.listen_global("peripheralConnected", |event| {
    println!("Connected to: {:?}", event.payload());
});

app.listen_global("peripheralDisconnected", |event| {
    println!("Disconnected from: {:?}", event.payload());
});

// Listen for characteristic updates
app.listen_global("characteristicValueUpdated", |event| {
    println!("Value updated: {:?}", event.payload());
});

// Peripheral mode events
app.listen_global("readRequestReceived", |event| {
    println!("Read request: {:?}", event.payload());
});

app.listen_global("writeRequestReceived", |event| {
    println!("Write request: {:?}", event.payload());
});
```

## Handling Notifications

```rust
#[tauri::command]
async fn subscribe_to_heart_rate<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    device_uuid: String,
) -> Result<(), String> {
    // Heart rate measurement characteristic: 2A37
    app.bluetooth()
        .subscribe_to_characteristic(device_uuid, "2A37".to_string())
        .map_err(|e| e.to_string())?;
    
    // Values will be received via characteristicValueUpdated events
    Ok(())
}
```

## Platform Support

This plugin only supports iOS. Desktop platforms will return `DesktopNotSupported` errors.

## Permissions

### iOS

Add to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to communicate with devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to share data with other devices</string>
```

For background operation:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>bluetooth-peripheral</string>
</array>
```

## Common BLE Services

| Service | UUID | Description |
|---------|------|-------------|
| Generic Access | 1800 | Device information |
| Generic Attribute | 1801 | GATT service |
| Device Information | 180A | Manufacturer info |
| Battery Service | 180F | Battery level |
| Heart Rate | 180D | Heart rate measurement |
| Blood Pressure | 1810 | Blood pressure |
| Health Thermometer | 1809 | Temperature |
| Glucose | 1808 | Glucose measurements |

## Error Handling

The plugin provides detailed error types:
- `NotAvailable` - Bluetooth not available
- `NotAuthorized` - Bluetooth not authorized
- `PoweredOff` - Bluetooth powered off
- `ConnectionFailed` - Connection attempt failed
- `PeripheralNotFound` - Device not found
- `CharacteristicNotFound` - Characteristic not found

## Best Practices

1. **Always check authorization and state** before performing operations
2. **Stop scanning** when you find the device you need
3. **Disconnect properly** when done to save battery
4. **Handle disconnections gracefully** - devices may disconnect unexpectedly
5. **Use service/characteristic UUIDs** for filtering when possible
6. **Implement timeouts** for connection attempts
7. **Cache discovered services** to avoid repeated discovery

## Example: Heart Rate Monitor

```rust
use tauri_plugin_ios_bluetooth::*;
use std::sync::Arc;
use tokio::sync::Mutex;

pub struct HeartRateMonitor {
    device_uuid: Option<String>,
    latest_heart_rate: Arc<Mutex<Option<u8>>>,
}

impl HeartRateMonitor {
    pub async fn start_monitoring<R: Runtime>(
        &mut self,
        app: &AppHandle<R>,
    ) -> Result<(), String> {
        // Scan for heart rate devices
        let options = ScanOptions {
            service_uuids: vec!["180D".to_string()], // Heart Rate Service
            allow_duplicates: false,
            scan_mode: ScanMode::LowLatency,
        };
        
        app.bluetooth()
            .start_central_scan(options)
            .map_err(|e| e.to_string())?;
        
        // Wait for device discovery (handled via events)
        // ...
        
        Ok(())
    }
    
    pub async fn connect_and_subscribe<R: Runtime>(
        &mut self,
        app: &AppHandle<R>,
        device_uuid: String,
    ) -> Result<(), String> {
        // Connect
        let options = ConnectionOptions::default();
        app.bluetooth()
            .connect_peripheral(device_uuid.clone(), options)
            .map_err(|e| e.to_string())?;
        
        // Discover heart rate service
        app.bluetooth()
            .discover_services(device_uuid.clone(), Some(vec!["180D".to_string()]))
            .map_err(|e| e.to_string())?;
        
        // Discover heart rate measurement characteristic
        app.bluetooth()
            .discover_characteristics(
                device_uuid.clone(),
                "180D".to_string(),
                Some(vec!["2A37".to_string()])
            )
            .map_err(|e| e.to_string())?;
        
        // Subscribe to notifications
        app.bluetooth()
            .subscribe_to_characteristic(device_uuid.clone(), "2A37".to_string())
            .map_err(|e| e.to_string())?;
        
        self.device_uuid = Some(device_uuid);
        Ok(())
    }
    
    pub fn parse_heart_rate_data(data: &[u8]) -> Option<u8> {
        if data.is_empty() {
            return None;
        }
        
        let flags = data[0];
        let is_16bit = (flags & 0x01) != 0;
        
        if is_16bit && data.len() >= 3 {
            Some(data[1]) // Just return low byte for simplicity
        } else if data.len() >= 2 {
            Some(data[1])
        } else {
            None
        }
    }
}
```