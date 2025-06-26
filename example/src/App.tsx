import { createSignal, For, Show } from "solid-js";
import "./App.css";
import SimpleCameraTest from "./SimpleCameraTest";

// Import all iOS plugins
import * as HealthKit from "@tauri-plugin/ios-healthkit";
import * as Contacts from "@tauri-plugin/ios-contacts";
import * as Camera from "@tauri-plugin/ios-camera";
import * as Microphone from "@tauri-plugin/ios-microphone";
import * as Location from "@tauri-plugin/ios-location";
import * as Photos from "@tauri-plugin/ios-photos";
import * as Music from "@tauri-plugin/ios-music";
import * as Keychain from "@tauri-plugin/ios-keychain";
import * as ScreenTime from "@tauri-plugin/ios-screentime";
import * as Files from "@tauri-plugin/ios-files";
import * as Messages from "@tauri-plugin/ios-messages";
import * as CallKit from "@tauri-plugin/ios-callkit";
import * as Bluetooth from "@tauri-plugin/ios-bluetooth";
import * as Shortcuts from "@tauri-plugin/ios-shortcuts";
import * as Widgets from "@tauri-plugin/ios-widgets";
import * as Motion from "@tauri-plugin/ios-motion";
import * as Barometer from "@tauri-plugin/ios-barometer";
import * as Proximity from "@tauri-plugin/ios-proximity";

interface TestResult {
  plugin: string;
  test: string;
  success: boolean;
  message: string;
  timestamp: Date;
}

function App() {
  const [showCameraDemo, setShowCameraDemo] = createSignal(false);
  const [results, setResults] = createSignal<TestResult[]>([]);
  const [testing, setTesting] = createSignal(false);
  const [selectedPlugin, setSelectedPlugin] = createSignal("all");

  const addResult = (plugin: string, test: string, success: boolean, message: string) => {
    setResults([...results(), { plugin, test, success, message, timestamp: new Date() }]);
  };

  // HealthKit Tests
  const testHealthKit = async () => {
    const plugin = "HealthKit";
    
    try {
      // Check permissions
      const permStatus = await HealthKit.checkPermissions();
      addResult(plugin, "Check Permissions", true, `Read: ${JSON.stringify(permStatus.read.steps)}, Write: ${JSON.stringify(permStatus.write.steps)}`);
      
      // Request permissions
      const newPerms = await HealthKit.requestPermissions({
        read: [HealthKit.HealthKitDataType.Steps, HealthKit.HealthKitDataType.HeartRate],
        write: [HealthKit.HealthKitDataType.Steps]
      });
      addResult(plugin, "Request Permissions", true, "Permissions requested");
      
      // Query samples
      const endDate = new Date().toISOString();
      const startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
      
      const samples = await HealthKit.queryQuantitySamples({
        dataType: HealthKit.HealthKitDataType.Steps,
        startDate,
        endDate,
        limit: 10
      });
      addResult(plugin, "Query Steps", true, `Found ${samples.length} samples`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Contacts Tests
  const testContacts = async () => {
    const plugin = "Contacts";
    
    try {
      // Check permissions
      const perm = await Contacts.checkPermissions();
      addResult(plugin, "Check Permissions", true, `Status: ${perm}`);
      
      if (perm !== Contacts.PermissionState.Granted) {
        const newPerm = await Contacts.requestPermissions();
        addResult(plugin, "Request Permissions", true, `New status: ${newPerm}`);
      }
      
      // Get contacts
      const contactList = await Contacts.getContacts({ limit: 10 });
      addResult(plugin, "Get Contacts", true, `Found ${contactList.length} contacts`);
      
      // Get groups
      const groups = await Contacts.getGroups();
      addResult(plugin, "Get Groups", true, `Found ${groups.length} groups`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Camera Tests
  const testCamera = async () => {
    const plugin = "Camera";
    
    try {
      // Check permissions
      const perms = await Camera.checkPermissions();
      addResult(plugin, "Check Permissions", true, `Camera: ${perms.camera}, Photos: ${perms.photoLibrary}`);
      
      // Request permissions if needed
      if (perms.camera !== Camera.PermissionState.Granted) {
        const newPerms = await Camera.requestPermissions({
          camera: true,
          photoLibrary: true
        });
        addResult(plugin, "Request Permissions", true, "Permissions requested");
      }
      
      // Get camera info
      const cameraList = await Camera.getCameraInfo();
      addResult(plugin, "Camera Info", true, `Found ${cameraList.length} cameras`);
      
      // Note: Taking photos would open camera UI
      addResult(plugin, "Camera API", true, "Camera API is available");
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Microphone Tests
  const testMicrophone = async () => {
    const plugin = "Microphone";
    
    try {
      // Check permissions
      const perm = await Microphone.checkPermissions();
      addResult(plugin, "Check Permissions", true, `Status: ${perm}`);
      
      if (perm !== Microphone.PermissionState.Granted) {
        const newPerm = await Microphone.requestPermissions();
        addResult(plugin, "Request Permissions", true, `New status: ${newPerm}`);
      }
      
      // Get available inputs
      const inputs = await Microphone.getAvailableInputs();
      addResult(plugin, "Get Inputs", true, `Found ${inputs.length} audio inputs`);
      
      // Get recording state
      const state = await Microphone.getRecordingState();
      addResult(plugin, "Recording State", true, `State: ${state}`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Location Tests
  const testLocation = async () => {
    const plugin = "Location";
    
    try {
      // Check permissions
      const perm = await Location.checkPermissions();
      addResult(plugin, "Check Permissions", true, `Status: ${perm.location}`);
      
      if (perm.location !== Location.PermissionState.Granted) {
        const newPerm = await Location.requestPermissions({
          precise: true,
          background: false
        });
        addResult(plugin, "Request Permissions", true, `New status: ${newPerm.location}`);
      }
      
      // Get current location
      try {
        const loc = await Location.getCurrentLocation({
          accuracy: Location.LocationAccuracy.Best,
          timeout: 10000
        });
        addResult(plugin, "Get Location", true, `Lat: ${loc.latitude.toFixed(4)}, Lon: ${loc.longitude.toFixed(4)}`);
      } catch (e) {
        addResult(plugin, "Get Location", false, "Location unavailable");
      }
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Photos Tests
  const testPhotos = async () => {
    const plugin = "Photos";
    
    try {
      // Check permissions
      const perm = await Photos.checkPermissions();
      addResult(plugin, "Check Permissions", true, `Status: ${perm}`);
      
      if (perm !== Photos.PermissionState.Authorized) {
        const newPerm = await Photos.requestPermissions({
          accessLevel: Photos.PhotoAccessLevel.ReadWrite
        });
        addResult(plugin, "Request Permissions", true, `New status: ${newPerm}`);
      }
      
      // Get albums
      const albums = await Photos.getAlbums({
        albumType: Photos.AlbumType.User
      });
      addResult(plugin, "Get Albums", true, `Found ${albums.length} albums`);
      
      // Get assets count
      const assets = await Photos.getAssets({
        mediaType: Photos.MediaType.Image,
        limit: 1
      });
      addResult(plugin, "Check Assets", true, assets.length > 0 ? "Photos available" : "No photos");
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Music Tests
  const testMusic = async () => {
    const plugin = "Music";
    
    try {
      // Check permissions
      const perm = await Music.checkPermissions();
      addResult(plugin, "Check Permissions", true, `Status: ${perm}`);
      
      if (perm !== Music.PermissionState.Authorized) {
        const newPerm = await Music.requestPermissions();
        addResult(plugin, "Request Permissions", true, `New status: ${newPerm}`);
      }
      
      // Get playlists
      const playlists = await Music.getPlaylists({ limit: 10 });
      addResult(plugin, "Get Playlists", true, `Found ${playlists.length} playlists`);
      
      // Get playback state
      const state = await Music.getPlaybackState();
      addResult(plugin, "Playback State", true, `State: ${state.playbackState}`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Keychain Tests
  const testKeychain = async () => {
    const plugin = "Keychain";
    
    try {
      // Set item
      await Keychain.setItem({
        key: "test-key",
        value: "test-value",
        accessible: Keychain.KeychainAccessible.WhenUnlocked
      });
      addResult(plugin, "Set Item", true, "Item stored in keychain");
      
      // Get item
      const value = await Keychain.getItem("test-key");
      addResult(plugin, "Get Item", true, `Retrieved: ${value}`);
      
      // Check if item exists
      const exists = await Keychain.hasItem("test-key");
      addResult(plugin, "Has Item", true, `Exists: ${exists}`);
      
      // Delete item
      await Keychain.deleteItem("test-key");
      addResult(plugin, "Delete Item", true, "Item deleted");
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // ScreenTime Tests
  const testScreenTime = async () => {
    const plugin = "ScreenTime";
    
    try {
      // Check if available
      const available = await ScreenTime.isScreenTimeAvailable();
      addResult(plugin, "Check Availability", true, `Available: ${available}`);
      
      if (available) {
        // Check permissions
        const perm = await ScreenTime.checkPermissions();
        addResult(plugin, "Check Permissions", true, `Status: ${perm}`);
        
        // Get device activity
        const endDate = new Date();
        const startDate = new Date(Date.now() - 24 * 60 * 60 * 1000);
        
        const activity = await ScreenTime.getDeviceActivity({
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString()
        });
        addResult(plugin, "Device Activity", true, `Total screen time: ${activity.totalScreenTime} minutes`);
      }
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Files Tests
  const testFiles = async () => {
    const plugin = "Files";
    
    try {
      // List documents
      const docs = await Files.listDocuments();
      addResult(plugin, "List Documents", true, `Found ${docs.length} documents`);
      
      // Get file info for app directory
      const info = await Files.getFileInfo({
        path: ".",
        includeMetadata: true
      });
      addResult(plugin, "File Info", true, `Type: ${info.isDirectory ? "Directory" : "File"}`);
      
      // Test write and read
      const testContent = "Test content from iOS Files plugin";
      await Files.writeFile({
        path: "test.txt",
        content: testContent
      });
      addResult(plugin, "Write File", true, "File written successfully");
      
      const readContent = await Files.readFile("test.txt");
      addResult(plugin, "Read File", true, `Content matches: ${readContent === testContent}`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Messages Tests
  const testMessages = async () => {
    const plugin = "Messages";
    
    try {
      // Check if can send text
      const canSend = await Messages.canSendText();
      addResult(plugin, "Can Send Text", true, `Can send: ${canSend}`);
      
      // Check iMessage availability
      const hasIMessage = await Messages.checkIMessageAvailability();
      addResult(plugin, "iMessage Available", true, `Available: ${hasIMessage}`);
      
      // Note: Actually sending messages would require user interaction
      addResult(plugin, "Messages API", true, "Messages API is available");
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // CallKit Tests
  const testCallKit = async () => {
    const plugin = "CallKit";
    
    try {
      // Check capability
      const capable = await CallKit.checkCallCapability();
      addResult(plugin, "Check Capability", true, `VoIP capable: ${capable}`);
      
      // Get active calls
      const calls = await CallKit.getActiveCalls();
      addResult(plugin, "Active Calls", true, `Active calls: ${calls.length}`);
      
      // Get audio routes
      const routes = await CallKit.getAudioRoutes();
      addResult(plugin, "Audio Routes", true, `Available routes: ${routes.length}`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Bluetooth Tests
  const testBluetooth = async () => {
    const plugin = "Bluetooth";
    
    try {
      // Check if enabled
      const enabled = await Bluetooth.isBluetoothEnabled();
      addResult(plugin, "Bluetooth Enabled", true, `Enabled: ${enabled}`);
      
      // Get authorization status
      const auth = await Bluetooth.getAuthorizationStatus();
      addResult(plugin, "Authorization Status", true, `Status: ${auth}`);
      
      if (auth !== Bluetooth.AuthorizationStatus.Authorized) {
        const newAuth = await Bluetooth.requestAuthorization();
        addResult(plugin, "Request Authorization", true, `New status: ${newAuth}`);
      }
      
      // Get connected peripherals
      const connected = await Bluetooth.getConnectedPeripherals();
      addResult(plugin, "Connected Devices", true, `Connected: ${connected.length}`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Shortcuts Tests
  const testShortcuts = async () => {
    const plugin = "Shortcuts";
    
    try {
      // Get all shortcuts
      const shortcuts = await Shortcuts.getAllShortcuts();
      addResult(plugin, "Get Shortcuts", true, `Found ${shortcuts.length} shortcuts`);
      
      // Create a shortcut
      await Shortcuts.createShortcut({
        title: "Test Shortcut",
        phrase: "Run test shortcut"
      });
      addResult(plugin, "Create Shortcut", true, "Shortcut created");
      
      // Get voice shortcuts
      const voiceShortcuts = await Shortcuts.getVoiceShortcuts();
      addResult(plugin, "Voice Shortcuts", true, `Found ${voiceShortcuts.length} voice shortcuts`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Widgets Tests
  const testWidgets = async () => {
    const plugin = "Widgets";
    
    try {
      // Get current widgets
      const widgets = await Widgets.getCurrentWidgets();
      addResult(plugin, "Get Widgets", true, `Found ${widgets.length} widgets`);
      
      // Reload all timelines
      await Widgets.reloadAllTimelines();
      addResult(plugin, "Reload Timelines", true, "All timelines reloaded");
      
      // Get widget info
      const families = await Widgets.getAvailableWidgetFamilies();
      addResult(plugin, "Widget Families", true, `Available families: ${families.length}`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Motion Tests
  const testMotion = async () => {
    const plugin = "Motion";
    
    try {
      // Check accelerometer
      const accelAvailable = await Motion.isAccelerometerAvailable();
      addResult(plugin, "Accelerometer Available", true, `Available: ${accelAvailable}`);
      
      if (accelAvailable) {
        // Start updates
        await Motion.startAccelerometerUpdates({ interval: 0.1 });
        addResult(plugin, "Start Accelerometer", true, "Updates started");
        
        // Get data
        setTimeout(async () => {
          try {
            const data = await Motion.getAccelerometerData();
            addResult(plugin, "Accelerometer Data", true, `X: ${data.x.toFixed(2)}, Y: ${data.y.toFixed(2)}, Z: ${data.z.toFixed(2)}`);
            
            // Stop updates
            await Motion.stopAccelerometerUpdates();
            addResult(plugin, "Stop Accelerometer", true, "Updates stopped");
          } catch (e) {
            addResult(plugin, "Get Data Failed", false, String(e));
          }
        }, 1000);
      }
      
      // Check pedometer
      const pedometerAvailable = await Motion.isPedometerAvailable();
      addResult(plugin, "Pedometer Available", true, `Available: ${pedometerAvailable}`);
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Barometer Tests
  const testBarometer = async () => {
    const plugin = "Barometer";
    
    try {
      // Check availability
      const available = await Barometer.isBarometerAvailable();
      addResult(plugin, "Check Availability", true, `Available: ${available}`);
      
      if (available) {
        // Get pressure data
        const pressure = await Barometer.getPressureData();
        addResult(plugin, "Pressure Data", true, `Pressure: ${pressure.pressure.toFixed(2)} kPa`);
        
        // Get weather data
        const weather = await Barometer.getWeatherData();
        addResult(plugin, "Weather Data", true, `Temperature: ${weather.temperature?.toFixed(1)}°C, Humidity: ${weather.humidity?.toFixed(0)}%`);
      }
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Proximity Tests
  const testProximity = async () => {
    const plugin = "Proximity";
    
    try {
      // Check availability
      const available = await Proximity.isProximityAvailable();
      addResult(plugin, "Check Availability", true, `Available: ${available}`);
      
      if (available) {
        // Enable monitoring
        await Proximity.setProximityMonitoringEnabled(true);
        addResult(plugin, "Enable Monitoring", true, "Proximity monitoring enabled");
        
        // Get state
        const state = await Proximity.getProximityState();
        addResult(plugin, "Proximity State", true, `Near: ${state.isNear}`);
        
        // Disable monitoring
        await Proximity.setProximityMonitoringEnabled(false);
        addResult(plugin, "Disable Monitoring", true, "Proximity monitoring disabled");
      }
      
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Run all tests
  const runAllTests = async () => {
    setTesting(true);
    setResults([]);
    
    // Run tests in sequence with small delays
    const tests = [
      testHealthKit,
      testContacts,
      testCamera,
      testMicrophone,
      testLocation,
      testPhotos,
      testMusic,
      testKeychain,
      testScreenTime,
      testFiles,
      testMessages,
      testCallKit,
      testBluetooth,
      testShortcuts,
      testWidgets,
      testMotion,
      testBarometer,
      testProximity
    ];
    
    for (const test of tests) {
      await test();
      // Small delay between tests
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    
    setTesting(false);
  };

  const plugins = [
    { name: "HealthKit", test: testHealthKit },
    { name: "Contacts", test: testContacts },
    { name: "Camera", test: testCamera },
    { name: "Microphone", test: testMicrophone },
    { name: "Location", test: testLocation },
    { name: "Photos", test: testPhotos },
    { name: "Music", test: testMusic },
    { name: "Keychain", test: testKeychain },
    { name: "ScreenTime", test: testScreenTime },
    { name: "Files", test: testFiles },
    { name: "Messages", test: testMessages },
    { name: "CallKit", test: testCallKit },
    { name: "Bluetooth", test: testBluetooth },
    { name: "Shortcuts", test: testShortcuts },
    { name: "Widgets", test: testWidgets },
    { name: "Motion", test: testMotion },
    { name: "Barometer", test: testBarometer },
    { name: "Proximity", test: testProximity }
  ];

  const filteredResults = () => {
    if (selectedPlugin() === "all") return results();
    return results().filter(r => r.plugin === selectedPlugin());
  };

  const successCount = () => filteredResults().filter(r => r.success).length;
  const failureCount = () => filteredResults().filter(r => !r.success).length;

  return (
    <div class="container">
      <Show when={showCameraDemo()}>
        <div>
          <button onClick={() => setShowCameraDemo(false)} style={{ "margin-bottom": "20px" }}>
            ← Back to Test Suite
          </button>
          <SimpleCameraTest />
        </div>
      </Show>
      
      <Show when={!showCameraDemo()}>
        <h1>iOS Plugins Test Suite</h1>
        
        <button 
          onClick={() => setShowCameraDemo(true)} 
          style={{ 
            "background-color": "#007AFF",
            "color": "white",
            "border": "none",
            "padding": "15px 30px",
            "border-radius": "8px",
            "margin-bottom": "20px",
            "font-size": "16px",
            "cursor": "pointer"
          }}
        >
          Open Camera Demo →
        </button>
      
      <div class="stats" style={{ "margin-bottom": "20px", "padding": "15px", "background": "#f0f0f0", "border-radius": "8px" }}>
        <strong>Results:</strong> {filteredResults().length} total, 
        <span style={{ "color": "#28a745", "margin": "0 10px" }}>✓ {successCount()} passed</span>
        <span style={{ "color": "#dc3545" }}>✗ {failureCount()} failed</span>
      </div>
      
      <div class="controls" style={{ "margin-bottom": "20px" }}>
        <button 
          onClick={runAllTests} 
          disabled={testing()}
          style={{ 
            "background-color": "#007AFF",
            "color": "white",
            "border": "none",
            "padding": "10px 20px",
            "border-radius": "5px",
            "margin-right": "10px",
            "cursor": testing() ? "not-allowed" : "pointer",
            "opacity": testing() ? 0.6 : 1
          }}
        >
          {testing() ? "Testing..." : "Run All Tests"}
        </button>
        
        <button 
          onClick={() => setResults([])}
          disabled={testing()}
          style={{ 
            "background-color": "#6c757d",
            "color": "white",
            "border": "none",
            "padding": "10px 20px",
            "border-radius": "5px",
            "margin-right": "10px",
            "cursor": testing() ? "not-allowed" : "pointer",
            "opacity": testing() ? 0.6 : 1
          }}
        >
          Clear Results
        </button>
        
        <select 
          value={selectedPlugin()} 
          onChange={(e) => setSelectedPlugin(e.currentTarget.value)}
          style={{ "padding": "10px", "border-radius": "5px" }}
        >
          <option value="all">All Plugins</option>
          <For each={plugins}>
            {(plugin) => <option value={plugin.name}>{plugin.name}</option>}
          </For>
        </select>
      </div>

      <div class="plugin-grid" style={{ 
        "display": "grid", 
        "grid-template-columns": "repeat(auto-fill, minmax(200px, 1fr))", 
        "gap": "10px", 
        "margin-bottom": "20px" 
      }}>
        <For each={plugins}>
          {(plugin) => (
            <button
              onClick={() => {
                setSelectedPlugin(plugin.name);
                plugin.test();
              }}
              disabled={testing()}
              style={{
                "padding": "15px",
                "border": "1px solid #ddd",
                "border-radius": "8px",
                "background": "white",
                "cursor": testing() ? "not-allowed" : "pointer",
                "transition": "all 0.2s",
                "opacity": testing() ? 0.6 : 1
              }}
              onMouseEnter={(e) => {
                if (!testing()) {
                  e.currentTarget.style.background = "#f8f9fa";
                  e.currentTarget.style.borderColor = "#007AFF";
                }
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = "white";
                e.currentTarget.style.borderColor = "#ddd";
              }}
            >
              Test {plugin.name}
            </button>
          )}
        </For>
      </div>

      <div class="results" style={{ 
        "max-height": "500px", 
        "overflow-y": "auto", 
        "border": "1px solid #ddd", 
        "border-radius": "8px", 
        "padding": "10px" 
      }}>
        <h2>Test Results ({filteredResults().length})</h2>
        <Show when={filteredResults().length === 0}>
          <p style={{ "color": "#666" }}>No test results yet. Click a button above to start testing.</p>
        </Show>
        <For each={filteredResults()}>
          {(result) => (
            <div 
              style={{
                "padding": "10px",
                "margin": "5px 0",
                "border-radius": "5px",
                "background-color": result.success ? "#d4edda" : "#f8d7da",
                "border": `1px solid ${result.success ? "#c3e6cb" : "#f5c6cb"}`
              }}
            >
              <strong>{result.plugin}</strong> - {result.test}<br/>
              <span style={{ "color": result.success ? "#155724" : "#721c24" }}>
                {result.success ? "✓" : "✗"} {result.message}
              </span><br/>
              <small style={{ "color": "#666" }}>{result.timestamp.toLocaleTimeString()}</small>
            </div>
          )}
        </For>
      </div>
      </Show>
    </div>
  );
}

export default App;