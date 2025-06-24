import { createSignal, For, Show } from "solid-js";
import { invoke } from "@tauri-apps/api/core";
import "./App.css";

interface TestResult {
  plugin: string;
  test: string;
  success: boolean;
  message: string;
  timestamp: Date;
}

function App() {
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
      await invoke("plugin:ios-healthkit|request_authorization", {
        read: ["heartRate", "stepCount", "activeEnergyBurned"],
        write: ["stepCount"]
      });
      addResult(plugin, "Request Authorization", true, "Authorization granted");
      
      try {
        const heartRate = await invoke("plugin:ios-healthkit|get_latest_quantity_sample", {
          type: "heartRate"
        });
        addResult(plugin, "Read Heart Rate", true, `Heart rate: ${JSON.stringify(heartRate)}`);
      } catch (e) {
        addResult(plugin, "Read Heart Rate", false, String(e));
      }
      
    } catch (e) {
      addResult(plugin, "Request Authorization", false, String(e));
    }
  };

  // Contacts Tests
  const testContacts = async () => {
    const plugin = "Contacts";
    
    try {
      const status = await invoke("plugin:ios-contacts|check_authorization_status");
      addResult(plugin, "Check Authorization", true, `Status: ${status}`);
      
      if (status !== "authorized") {
        await invoke("plugin:ios-contacts|request_authorization");
        addResult(plugin, "Request Authorization", true, "Authorization requested");
      }
      
      const contacts = await invoke("plugin:ios-contacts|get_all_contacts");
      addResult(plugin, "Get All Contacts", true, `Found ${(contacts as any[]).length} contacts`);
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Camera Tests
  const testCamera = async () => {
    const plugin = "Camera";
    
    try {
      const available = await invoke("plugin:ios-camera|is_camera_available");
      addResult(plugin, "Check Availability", true, `Camera available: ${available}`);
      
      const permission = await invoke("plugin:ios-camera|request_camera_permission");
      addResult(plugin, "Request Permission", true, `Permission: ${permission}`);
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Location Tests
  const testLocation = async () => {
    const plugin = "Location";
    
    try {
      const status = await invoke("plugin:ios-location|request_authorization", {
        precision: "full"
      });
      addResult(plugin, "Request Authorization", true, `Status: ${status}`);
      
      const location = await invoke("plugin:ios-location|get_current_location");
      addResult(plugin, "Get Current Location", true, `Location: ${JSON.stringify(location)}`);
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Music Tests
  const testMusic = async () => {
    const plugin = "Music";
    
    try {
      const status = await invoke("plugin:ios-music|get_authorization_status");
      addResult(plugin, "Check Authorization", true, `Status: ${status}`);
      
      const playlists = await invoke("plugin:ios-music|get_playlists");
      addResult(plugin, "Get Playlists", true, `Found ${(playlists as any[]).length} playlists`);
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Photos Tests
  const testPhotos = async () => {
    const plugin = "Photos";
    
    try {
      const status = await invoke("plugin:ios-photos|get_authorization_status");
      addResult(plugin, "Check Authorization", true, `Status: ${status}`);
      
      if (status !== "authorized") {
        await invoke("plugin:ios-photos|request_authorization", {
          accessLevel: "readWrite"
        });
        addResult(plugin, "Request Authorization", true, "Authorization requested");
      }
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Keychain Tests
  const testKeychain = async () => {
    const plugin = "Keychain";
    
    try {
      await invoke("plugin:ios-keychain|set_password", {
        data: {
          service: "test-app",
          account: "test-user",
          password: "test-password-123"
        }
      });
      addResult(plugin, "Set Password", true, "Password stored");
      
      const result = await invoke("plugin:ios-keychain|get_password", {
        query: {
          service: "test-app",
          account: "test-user"
        }
      });
      addResult(plugin, "Get Password", true, `Retrieved: ${JSON.stringify(result)}`);
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Motion Tests
  const testMotion = async () => {
    const plugin = "Motion";
    
    try {
      const accelAvailable = await invoke("plugin:ios-motion|is_accelerometer_available");
      addResult(plugin, "Check Accelerometer", true, `Available: ${accelAvailable}`);
      
      if (accelAvailable) {
        await invoke("plugin:ios-motion|start_accelerometer_updates");
        addResult(plugin, "Start Accelerometer", true, "Updates started");
        
        // Wait a bit then get data
        setTimeout(async () => {
          try {
            const data = await invoke("plugin:ios-motion|get_accelerometer_data");
            addResult(plugin, "Get Accelerometer Data", true, JSON.stringify(data));
            
            await invoke("plugin:ios-motion|stop_accelerometer_updates");
            addResult(plugin, "Stop Accelerometer", true, "Updates stopped");
          } catch (e) {
            addResult(plugin, "Get Data Failed", false, String(e));
          }
        }, 1000);
      }
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Barometer Tests
  const testBarometer = async () => {
    const plugin = "Barometer";
    
    try {
      const available = await invoke("plugin:ios-barometer|is_barometer_available");
      addResult(plugin, "Check Availability", true, `Available: ${available}`);
      
      if (available) {
        const pressure = await invoke("plugin:ios-barometer|get_pressure_data");
        addResult(plugin, "Get Pressure", true, JSON.stringify(pressure));
      }
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Proximity Tests
  const testProximity = async () => {
    const plugin = "Proximity";
    
    try {
      const available = await invoke("plugin:ios-proximity|is_proximity_available");
      addResult(plugin, "Check Availability", true, `Available: ${available}`);
      
      if (available) {
        await invoke("plugin:ios-proximity|enable_proximity_monitoring");
        addResult(plugin, "Enable Monitoring", true, "Proximity monitoring enabled");
        
        const state = await invoke("plugin:ios-proximity|get_proximity_state");
        addResult(plugin, "Get State", true, JSON.stringify(state));
      }
    } catch (e) {
      addResult(plugin, "Test Failed", false, String(e));
    }
  };

  // Run all tests
  const runAllTests = async () => {
    setTesting(true);
    setResults([]);
    
    await testHealthKit();
    await testContacts();
    await testCamera();
    await testLocation();
    await testMusic();
    await testPhotos();
    await testKeychain();
    await testMotion();
    await testBarometer();
    await testProximity();
    
    setTesting(false);
  };

  const plugins = [
    { name: "HealthKit", test: testHealthKit },
    { name: "Contacts", test: testContacts },
    { name: "Camera", test: testCamera },
    { name: "Location", test: testLocation },
    { name: "Music", test: testMusic },
    { name: "Photos", test: testPhotos },
    { name: "Keychain", test: testKeychain },
    { name: "Motion", test: testMotion },
    { name: "Barometer", test: testBarometer },
    { name: "Proximity", test: testProximity }
  ];

  const filteredResults = () => {
    if (selectedPlugin() === "all") return results();
    return results().filter(r => r.plugin === selectedPlugin());
  };

  return (
    <div class="container">
      <h1>iOS Plugins Test Suite</h1>
      
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
            "margin-right": "10px"
          }}
        >
          {testing() ? "Testing..." : "Run All Tests"}
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

      <div class="plugin-grid" style={{ "display": "grid", "grid-template-columns": "repeat(auto-fill, minmax(200px, 1fr))", "gap": "10px", "margin-bottom": "20px" }}>
        <For each={plugins}>
          {(plugin) => (
            <button
              onClick={() => {
                setResults([]);
                plugin.test();
              }}
              disabled={testing()}
              style={{
                "padding": "15px",
                "border": "1px solid #ddd",
                "border-radius": "8px",
                "background": "white",
                "cursor": "pointer"
              }}
            >
              Test {plugin.name}
            </button>
          )}
        </For>
      </div>

      <div class="results" style={{ "max-height": "500px", "overflow-y": "auto", "border": "1px solid #ddd", "border-radius": "8px", "padding": "10px" }}>
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
    </div>
  );
}

export default App;