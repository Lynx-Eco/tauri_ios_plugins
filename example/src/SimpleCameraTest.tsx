import { createSignal, For } from "solid-js";

export default function SimpleCameraTest() {
  const [results, setResults] = createSignal<string[]>([]);

  const addResult = (message: string) => {
    setResults([...results(), `${new Date().toLocaleTimeString()}: ${message}`]);
  };

  const testPickImage = async () => {
    try {
      const { invoke } = await import("@tauri-apps/api/core");
      const result = await invoke('plugin:ios-camera|pick_image', {
        options: {
          allowMultiple: true,
          limit: 5
        }
      });
      addResult(`Pick image result: ${JSON.stringify(result)}`);
    } catch (e: any) {
      addResult(`Error picking images: ${e.message || e}`);
    }
  };

  const testPickVideo = async () => {
    try {
      const { invoke } = await import("@tauri-apps/api/core");
      const result = await invoke('plugin:ios-camera|pick_video', {
        options: {
          allowMultiple: true,
          limit: 3
        }
      });
      addResult(`Pick video result: ${JSON.stringify(result)}`);
    } catch (e: any) {
      addResult(`Error picking videos: ${e.message || e}`);
    }
  };

  const testPickMedia = async () => {
    try {
      const { invoke } = await import("@tauri-apps/api/core");
      const result = await invoke('plugin:ios-camera|pick_media', {
        options: {
          allowMultiple: true,
          limit: 10
        }
      });
      addResult(`Pick media result: ${JSON.stringify(result)}`);
    } catch (e: any) {
      addResult(`Error picking media: ${e.message || e}`);
    }
  };

  const testGetCameraInfo = async () => {
    try {
      const { invoke } = await import("@tauri-apps/api/core");
      const result = await invoke('plugin:ios-camera|get_camera_info');
      addResult(`Camera info: ${JSON.stringify(result)}`);
    } catch (e: any) {
      addResult(`Error getting camera info: ${e.message || e}`);
    }
  };

  const testAdvancedFeature = async () => {
    try {
      const { invoke } = await import("@tauri-apps/api/core");
      
      // Test start camera session
      await invoke('plugin:ios-camera|start_camera_session', {
        config: {
          sessionPreset: 'high',
          enableAudio: true,
          enableVideoStabilization: true,
          enableContinuousAutoFocus: true,
          enableContinuousAutoExposure: true
        }
      });
      addResult("Camera session started");

      // Test stop camera session
      setTimeout(async () => {
        await invoke('plugin:ios-camera|stop_camera_session');
        addResult("Camera session stopped");
      }, 2000);
      
    } catch (e: any) {
      addResult(`Error with advanced features: ${e.message || e}`);
    }
  };

  return (
    <div style={{ padding: "20px" }}>
      <h2>Simple Camera Test</h2>
      
      <div style={{ "margin-bottom": "20px" }}>
        <button onClick={testPickImage}>Test Pick Image</button>
        <button onClick={testPickVideo}>Test Pick Video</button>
        <button onClick={testPickMedia}>Test Pick Media</button>
        <button onClick={testGetCameraInfo}>Test Get Camera Info</button>
        <button onClick={testAdvancedFeature}>Test Advanced Feature</button>
      </div>

      <div style={{ 
        "margin-top": "20px", 
        "padding": "10px", 
        "background": "#f0f0f0", 
        "border-radius": "5px",
        "max-height": "400px",
        "overflow-y": "auto",
        "font-family": "monospace",
        "font-size": "12px"
      }}>
        <h3>Results</h3>
        <For each={results()}>
          {(result) => <div style={{ "margin-bottom": "5px" }}>{result}</div>}
        </For>
      </div>
    </div>
  );
}