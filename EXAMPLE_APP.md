# Example Tauri App with iOS Plugins

## Quick Start Guide

### 1. Create a new Tauri app

```bash
npm create tauri-app@latest test-ios-plugins -- --beta
cd test-ios-plugins
```

### 2. Update `src-tauri/Cargo.toml`

```toml
[package]
name = "test-ios-plugins"
version = "0.0.0"
description = "Test app for iOS plugins"
authors = ["you"]
edition = "2021"

[build-dependencies]
tauri-build = { version = "2.0.0" }

[dependencies]
tauri = { version = "2.1.1", features = [] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Add iOS plugins
tauri-plugin-ios-healthkit = { path = "../tauri_ios_plugins/plugins/tauri-plugin-ios-healthkit" }
tauri-plugin-ios-contacts = { path = "../tauri_ios_plugins/plugins/tauri-plugin-ios-contacts" }
tauri-plugin-ios-camera = { path = "../tauri_ios_plugins/plugins/tauri-plugin-ios-camera" }
tauri-plugin-ios-location = { path = "../tauri_ios_plugins/plugins/tauri-plugin-ios-location" }
# Add more as needed

[features]
default = ["custom-protocol"]
custom-protocol = ["tauri/custom-protocol"]
```

### 3. Update `src-tauri/src/main.rs`

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
        .plugin(tauri_plugin_ios_location::init())
        .invoke_handler(tauri::generate_handler![])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 4. Create Frontend Test Interface

Create `src/main.js`:

```javascript
// Test HealthKit
async function testHealthKit() {
    const { invoke } = window.__TAURI__.tauri;
    
    try {
        // Request authorization
        await invoke('plugin:ios-healthkit|request_authorization', {
            read: ['heartRate', 'stepCount'],
            write: ['stepCount']
        });
        console.log('✓ HealthKit authorized');
        
        // Get latest heart rate
        const heartRate = await invoke('plugin:ios-healthkit|get_latest_quantity_sample', {
            type: 'heartRate'
        });
        console.log('Heart rate:', heartRate);
    } catch (error) {
        console.error('HealthKit error:', error);
    }
}

// Test Contacts
async function testContacts() {
    const { invoke } = window.__TAURI__.tauri;
    
    try {
        // Check authorization
        const status = await invoke('plugin:ios-contacts|check_authorization_status');
        console.log('Contact authorization:', status);
        
        if (status !== 'authorized') {
            await invoke('plugin:ios-contacts|request_authorization');
        }
        
        // Get all contacts
        const contacts = await invoke('plugin:ios-contacts|get_all_contacts');
        console.log(`Found ${contacts.length} contacts`);
    } catch (error) {
        console.error('Contacts error:', error);
    }
}

// Test Camera
async function testCamera() {
    const { invoke } = window.__TAURI__.tauri;
    
    try {
        // Check if camera is available
        const available = await invoke('plugin:ios-camera|is_camera_available');
        console.log('Camera available:', available);
        
        // Request permission
        const permission = await invoke('plugin:ios-camera|request_camera_permission');
        console.log('Camera permission:', permission);
    } catch (error) {
        console.error('Camera error:', error);
    }
}

// Test Location
async function testLocation() {
    const { invoke } = window.__TAURI__.tauri;
    
    try {
        // Request permission
        await invoke('plugin:ios-location|request_authorization', {
            precision: 'full'
        });
        
        // Get current location
        const location = await invoke('plugin:ios-location|get_current_location');
        console.log('Current location:', location);
    } catch (error) {
        console.error('Location error:', error);
    }
}

// Create UI
document.addEventListener('DOMContentLoaded', () => {
    document.body.innerHTML = `
        <div style="padding: 20px; font-family: system-ui;">
            <h1>iOS Plugins Test</h1>
            <button onclick="testHealthKit()">Test HealthKit</button>
            <button onclick="testContacts()">Test Contacts</button>
            <button onclick="testCamera()">Test Camera</button>
            <button onclick="testLocation()">Test Location</button>
            <div id="output" style="margin-top: 20px; padding: 10px; background: #f0f0f0; min-height: 200px;">
                <pre id="console-output"></pre>
            </div>
        </div>
    `;
    
    // Redirect console to UI
    const output = document.getElementById('console-output');
    const originalLog = console.log;
    const originalError = console.error;
    
    console.log = (...args) => {
        originalLog(...args);
        output.textContent += args.join(' ') + '\n';
    };
    
    console.error = (...args) => {
        originalError(...args);
        output.textContent += '❌ ' + args.join(' ') + '\n';
    };
});
```

### 5. Build and Run

#### Desktop (for development)
```bash
npm run tauri dev
```

#### iOS Simulator
```bash
# Install iOS targets
rustup target add aarch64-apple-ios x86_64-apple-ios

# Initialize mobile project
npm run tauri ios init

# Run on simulator
npm run tauri ios dev
```

#### Physical iOS Device
1. Connect your iPhone/iPad
2. Open `src-tauri/gen/apple/test-ios-plugins.xcodeproj` in Xcode
3. Select your device as the target
4. Build and run

### 6. Testing Each Plugin

Create a comprehensive test page `src/plugin-tests.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>iOS Plugin Tests</title>
    <style>
        body {
            font-family: -apple-system, system-ui;
            padding: 20px;
            background: #f5f5f5;
        }
        .plugin-card {
            background: white;
            border-radius: 10px;
            padding: 15px;
            margin: 10px 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        button {
            background: #007AFF;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            margin: 5px;
            cursor: pointer;
        }
        button:hover {
            background: #0051D5;
        }
        .status {
            padding: 5px 10px;
            border-radius: 3px;
            display: inline-block;
            margin: 5px 0;
        }
        .status.success { background: #4CAF50; color: white; }
        .status.error { background: #f44336; color: white; }
        .status.info { background: #2196F3; color: white; }
        pre {
            background: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <h1>iOS Plugins Test Suite</h1>
    
    <div class="plugin-card">
        <h2>🏥 HealthKit</h2>
        <button onclick="testHealthKit.requestAuth()">Request Authorization</button>
        <button onclick="testHealthKit.readHeartRate()">Read Heart Rate</button>
        <button onclick="testHealthKit.writeSteps()">Write Steps</button>
        <div id="healthkit-output"></div>
    </div>
    
    <div class="plugin-card">
        <h2>👥 Contacts</h2>
        <button onclick="testContacts.checkAuth()">Check Authorization</button>
        <button onclick="testContacts.requestAuth()">Request Authorization</button>
        <button onclick="testContacts.getAllContacts()">Get All Contacts</button>
        <button onclick="testContacts.searchContacts()">Search "John"</button>
        <div id="contacts-output"></div>
    </div>
    
    <div class="plugin-card">
        <h2>📷 Camera</h2>
        <button onclick="testCamera.checkAvailable()">Check Availability</button>
        <button onclick="testCamera.requestPermission()">Request Permission</button>
        <button onclick="testCamera.capturePhoto()">Capture Photo</button>
        <div id="camera-output"></div>
    </div>
    
    <div class="plugin-card">
        <h2>📍 Location</h2>
        <button onclick="testLocation.requestAuth()">Request Authorization</button>
        <button onclick="testLocation.getCurrentLocation()">Get Current Location</button>
        <button onclick="testLocation.startMonitoring()">Start Monitoring</button>
        <button onclick="testLocation.stopMonitoring()">Stop Monitoring</button>
        <div id="location-output"></div>
    </div>
    
    <div class="plugin-card">
        <h2>🎵 Music</h2>
        <button onclick="testMusic.checkAuth()">Check Authorization</button>
        <button onclick="testMusic.getPlaylists()">Get Playlists</button>
        <button onclick="testMusic.getCurrentSong()">Get Current Song</button>
        <div id="music-output"></div>
    </div>

    <script>
        const { invoke } = window.__TAURI__.tauri;
        
        function updateOutput(pluginId, message, type = 'info') {
            const output = document.getElementById(`${pluginId}-output`);
            const status = document.createElement('div');
            status.className = `status ${type}`;
            status.textContent = message;
            output.appendChild(status);
            
            // Auto-scroll
            output.scrollTop = output.scrollHeight;
        }
        
        // HealthKit Tests
        const testHealthKit = {
            async requestAuth() {
                try {
                    await invoke('plugin:ios-healthkit|request_authorization', {
                        read: ['heartRate', 'stepCount', 'activeEnergyBurned'],
                        write: ['stepCount']
                    });
                    updateOutput('healthkit', 'Authorization granted', 'success');
                } catch (error) {
                    updateOutput('healthkit', `Auth failed: ${error}`, 'error');
                }
            },
            
            async readHeartRate() {
                try {
                    const sample = await invoke('plugin:ios-healthkit|get_latest_quantity_sample', {
                        type: 'heartRate'
                    });
                    updateOutput('healthkit', `Heart Rate: ${sample.value} ${sample.unit}`, 'success');
                } catch (error) {
                    updateOutput('healthkit', `Read failed: ${error}`, 'error');
                }
            },
            
            async writeSteps() {
                try {
                    await invoke('plugin:ios-healthkit|save_quantity_sample', {
                        sample: {
                            type: 'stepCount',
                            value: 1000,
                            unit: 'count',
                            startDate: new Date().toISOString(),
                            endDate: new Date().toISOString()
                        }
                    });
                    updateOutput('healthkit', 'Saved 1000 steps', 'success');
                } catch (error) {
                    updateOutput('healthkit', `Write failed: ${error}`, 'error');
                }
            }
        };
        
        // Contacts Tests
        const testContacts = {
            async checkAuth() {
                try {
                    const status = await invoke('plugin:ios-contacts|check_authorization_status');
                    updateOutput('contacts', `Authorization status: ${status}`, 'info');
                } catch (error) {
                    updateOutput('contacts', `Check failed: ${error}`, 'error');
                }
            },
            
            async requestAuth() {
                try {
                    await invoke('plugin:ios-contacts|request_authorization');
                    updateOutput('contacts', 'Authorization granted', 'success');
                } catch (error) {
                    updateOutput('contacts', `Auth failed: ${error}`, 'error');
                }
            },
            
            async getAllContacts() {
                try {
                    const contacts = await invoke('plugin:ios-contacts|get_all_contacts');
                    updateOutput('contacts', `Found ${contacts.length} contacts`, 'success');
                    if (contacts.length > 0) {
                        console.log('First contact:', contacts[0]);
                    }
                } catch (error) {
                    updateOutput('contacts', `Fetch failed: ${error}`, 'error');
                }
            },
            
            async searchContacts() {
                try {
                    const results = await invoke('plugin:ios-contacts|search_contacts', {
                        query: 'John'
                    });
                    updateOutput('contacts', `Found ${results.length} contacts named "John"`, 'success');
                } catch (error) {
                    updateOutput('contacts', `Search failed: ${error}`, 'error');
                }
            }
        };
        
        // Camera Tests
        const testCamera = {
            async checkAvailable() {
                try {
                    const available = await invoke('plugin:ios-camera|is_camera_available');
                    updateOutput('camera', `Camera available: ${available}`, 'info');
                } catch (error) {
                    updateOutput('camera', `Check failed: ${error}`, 'error');
                }
            },
            
            async requestPermission() {
                try {
                    const granted = await invoke('plugin:ios-camera|request_camera_permission');
                    updateOutput('camera', granted ? 'Permission granted' : 'Permission denied', 
                               granted ? 'success' : 'error');
                } catch (error) {
                    updateOutput('camera', `Permission failed: ${error}`, 'error');
                }
            },
            
            async capturePhoto() {
                try {
                    const photo = await invoke('plugin:ios-camera|capture_photo', {
                        options: {
                            quality: 0.8,
                            format: 'jpeg'
                        }
                    });
                    updateOutput('camera', `Photo captured: ${photo.width}x${photo.height}`, 'success');
                } catch (error) {
                    updateOutput('camera', `Capture failed: ${error}`, 'error');
                }
            }
        };
        
        // Location Tests
        const testLocation = {
            async requestAuth() {
                try {
                    const status = await invoke('plugin:ios-location|request_authorization', {
                        precision: 'full'
                    });
                    updateOutput('location', `Authorization: ${status}`, 'success');
                } catch (error) {
                    updateOutput('location', `Auth failed: ${error}`, 'error');
                }
            },
            
            async getCurrentLocation() {
                try {
                    const location = await invoke('plugin:ios-location|get_current_location');
                    updateOutput('location', 
                        `Location: ${location.latitude.toFixed(6)}, ${location.longitude.toFixed(6)}`, 
                        'success');
                } catch (error) {
                    updateOutput('location', `Location failed: ${error}`, 'error');
                }
            },
            
            async startMonitoring() {
                try {
                    await invoke('plugin:ios-location|start_location_updates');
                    updateOutput('location', 'Started location monitoring', 'success');
                } catch (error) {
                    updateOutput('location', `Start failed: ${error}`, 'error');
                }
            },
            
            async stopMonitoring() {
                try {
                    await invoke('plugin:ios-location|stop_location_updates');
                    updateOutput('location', 'Stopped location monitoring', 'success');
                } catch (error) {
                    updateOutput('location', `Stop failed: ${error}`, 'error');
                }
            }
        };
        
        // Music Tests
        const testMusic = {
            async checkAuth() {
                try {
                    const status = await invoke('plugin:ios-music|get_authorization_status');
                    updateOutput('music', `Music library access: ${status}`, 'info');
                } catch (error) {
                    updateOutput('music', `Check failed: ${error}`, 'error');
                }
            },
            
            async getPlaylists() {
                try {
                    const playlists = await invoke('plugin:ios-music|get_playlists');
                    updateOutput('music', `Found ${playlists.length} playlists`, 'success');
                } catch (error) {
                    updateOutput('music', `Playlists failed: ${error}`, 'error');
                }
            },
            
            async getCurrentSong() {
                try {
                    const song = await invoke('plugin:ios-music|get_now_playing');
                    if (song) {
                        updateOutput('music', `Now playing: ${song.title} by ${song.artist}`, 'success');
                    } else {
                        updateOutput('music', 'No song currently playing', 'info');
                    }
                } catch (error) {
                    updateOutput('music', `Now playing failed: ${error}`, 'error');
                }
            }
        };
    </script>
</body>
</html>
```

### 7. Run Tests

1. **Desktop Testing**: Check that plugins return appropriate "Not supported on desktop" errors
2. **iOS Simulator**: Test basic functionality and permission dialogs
3. **Physical Device**: Full testing with real sensor data

### 8. Debugging Tips

- Use Safari Web Inspector to debug the webview
- Check Xcode console for native iOS logs
- Use `console.log` extensively to trace execution
- Monitor the Rust console for backend errors

### 9. Common Issues

- **Build Errors**: Make sure all path dependencies are correct
- **Permission Denials**: Reset simulator/device permissions in Settings
- **Runtime Errors**: Check that you're calling the correct command names
- **iOS Version**: Some features require specific iOS versions