import { createSignal, Show, For } from "solid-js";
import * as Camera from "@tauri-plugin/ios-camera";

export default function CameraDemo() {
  const [results, setResults] = createSignal<string[]>([]);
  const [permissions, setPermissions] = createSignal<Camera.CameraPermissions | null>(null);
  const [cameras, setCameras] = createSignal<Camera.CameraInfo[]>([]);
  const [selectedCamera, setSelectedCamera] = createSignal<Camera.CameraInfo | null>(null);
  const [sessionActive, setSessionActive] = createSignal(false);
  const [previewActive, setPreviewActive] = createSignal(false);
  const [isTimeLapsing, setIsTimeLapsing] = createSignal(false);
  const [isSlowMotion, setIsSlowMotion] = createSignal(false);

  const addResult = (message: string) => {
    setResults([...results(), `${new Date().toLocaleTimeString()}: ${message}`]);
  };

  const checkPermissions = async () => {
    try {
      const perms = await Camera.checkPermissions();
      setPermissions(perms);
      addResult(`Permissions: Camera=${perms.camera}, Photos=${perms.photoLibrary}, Mic=${perms.microphone}`);
    } catch (e) {
      addResult(`Error checking permissions: ${e}`);
    }
  };

  const requestPermissions = async () => {
    try {
      const perms = await Camera.requestPermissions({
        camera: true,
        photoLibrary: true,
        microphone: true
      });
      setPermissions(perms);
      addResult(`Permissions updated: Camera=${perms.camera}, Photos=${perms.photoLibrary}, Mic=${perms.microphone}`);
    } catch (e) {
      addResult(`Error requesting permissions: ${e}`);
    }
  };

  const getCameraList = async () => {
    try {
      const cameraList = await Camera.getCameraInfo();
      setCameras(cameraList);
      addResult(`Found ${cameraList.length} cameras`);
      cameraList.forEach(cam => {
        addResult(`  - ${cam.name} (${cam.position}) - Zoom: ${cam.minZoom}-${cam.maxZoom}x`);
      });
    } catch (e) {
      addResult(`Error getting cameras: ${e}`);
    }
  };

  const takePhoto = async () => {
    try {
      const result = await Camera.takePhoto({
        cameraPosition: Camera.CameraPosition.Back,
        quality: Camera.ImageQuality.High,
        saveToGallery: true,
        flashMode: Camera.FlashMode.Auto
      });
      addResult(`Photo taken: ${result.path} (${result.width}x${result.height})`);
    } catch (e) {
      addResult(`Error taking photo: ${e}`);
    }
  };

  const recordVideo = async () => {
    try {
      const result = await Camera.recordVideo({
        cameraPosition: Camera.CameraPosition.Back,
        quality: Camera.VideoQuality.High,
        maxDuration: 30,
        saveToGallery: true
      });
      addResult(`Video recorded: ${result.path} (${result.duration}s, ${result.width}x${result.height})`);
    } catch (e) {
      addResult(`Error recording video: ${e}`);
    }
  };

  const pickImages = async () => {
    try {
      const result = await Camera.pickImage({
        allowMultiple: true,
        limit: 5
      });
      addResult(`Picked ${result.length} images`);
    } catch (e) {
      addResult(`Error picking images: ${e}`);
    }
  };

  const pickVideos = async () => {
    try {
      const result = await Camera.pickVideo({
        allowMultiple: true,
        limit: 3
      });
      addResult(`Picked ${result.length} videos`);
    } catch (e) {
      addResult(`Error picking videos: ${e}`);
    }
  };

  const pickMedia = async () => {
    try {
      const result = await Camera.pickMedia({
        allowMultiple: true,
        limit: 10
      });
      addResult(`Picked ${result.length} media items`);
    } catch (e) {
      addResult(`Error picking media: ${e}`);
    }
  };

  // Advanced features
  const startCameraSession = async () => {
    try {
      await Camera.startCameraSession({
        sessionPreset: Camera.SessionPreset.High,
        enableAudio: true,
        enableVideoStabilization: true,
        enableContinuousAutoFocus: true,
        enableContinuousAutoExposure: true
      });
      setSessionActive(true);
      addResult("Camera session started");
    } catch (e) {
      addResult(`Error starting session: ${e}`);
    }
  };

  const stopCameraSession = async () => {
    try {
      await Camera.stopCameraSession();
      setSessionActive(false);
      setPreviewActive(false);
      addResult("Camera session stopped");
    } catch (e) {
      addResult(`Error stopping session: ${e}`);
    }
  };

  const startPreview = async () => {
    try {
      await Camera.startPreview({
        cameraPosition: Camera.CameraPosition.Back,
        mirrorFrontCamera: true,
        orientation: Camera.PreviewOrientation.Portrait,
        zoomFactor: 1.0
      });
      setPreviewActive(true);
      addResult("Preview started");
    } catch (e) {
      addResult(`Error starting preview: ${e}`);
    }
  };

  const stopPreview = async () => {
    try {
      await Camera.stopPreview();
      setPreviewActive(false);
      addResult("Preview stopped");
    } catch (e) {
      addResult(`Error stopping preview: ${e}`);
    }
  };

  const setManualSettings = async () => {
    try {
      await Camera.setManualCameraSettings({
        iso: 200,
        exposureCompensation: 0.5,
        whiteBalance: {
          temperature: 5500,
          tint: 0
        },
        focusMode: Camera.FocusMode.ContinuousAutoFocus
      });
      addResult("Manual settings applied");
    } catch (e) {
      addResult(`Error setting manual settings: ${e}`);
    }
  };

  const takeAdvancedPhoto = async () => {
    try {
      const result = await Camera.takePhotoAdvanced({
        captureRaw: false,
        captureDepthData: true,
        capturePortraitEffects: true,
        enableLivePhoto: false,
        enableNightMode: false,
        enableSmartHdr: true,
        photoFormat: Camera.PhotoFormat.Heif
      });
      addResult(`Advanced photo: ${result.path} (${result.width}x${result.height})`);
    } catch (e) {
      addResult(`Error taking advanced photo: ${e}`);
    }
  };

  const startTimeLapse = async () => {
    try {
      await Camera.startTimeLapse(2.0); // 2 second intervals
      setIsTimeLapsing(true);
      addResult("Time-lapse started (2s intervals)");
    } catch (e) {
      addResult(`Error starting time-lapse: ${e}`);
    }
  };

  const stopTimeLapse = async () => {
    try {
      const result = await Camera.stopTimeLapse();
      setIsTimeLapsing(false);
      addResult(`Time-lapse saved: ${result.path} (${result.duration}s)`);
    } catch (e) {
      addResult(`Error stopping time-lapse: ${e}`);
    }
  };

  const startSlowMotion = async () => {
    try {
      await Camera.startSlowMotion(240); // 240 fps
      setIsSlowMotion(true);
      addResult("Slow-motion started (240 fps)");
    } catch (e) {
      addResult(`Error starting slow-motion: ${e}`);
    }
  };

  const stopSlowMotion = async () => {
    try {
      const result = await Camera.stopSlowMotion();
      setIsSlowMotion(false);
      addResult(`Slow-motion saved: ${result.path} (${result.duration}s)`);
    } catch (e) {
      addResult(`Error stopping slow-motion: ${e}`);
    }
  };

  const capturePanorama = async () => {
    try {
      const result = await Camera.capturePanorama();
      addResult(`Panorama captured: ${result.path} (${result.width}x${result.height})`);
    } catch (e) {
      addResult(`Error capturing panorama: ${e}`);
    }
  };

  const captureBurst = async () => {
    try {
      const results = await Camera.captureBurst(10, 0.1); // 10 photos, 0.1s interval
      addResult(`Burst captured: ${results.length} photos`);
    } catch (e) {
      addResult(`Error capturing burst: ${e}`);
    }
  };

  const setZoom = async (factor: number) => {
    try {
      await Camera.setZoom(factor);
      addResult(`Zoom set to ${factor}x`);
    } catch (e) {
      addResult(`Error setting zoom: ${e}`);
    }
  };

  const getCameraCapabilities = async () => {
    if (!selectedCamera()) {
      addResult("Please select a camera first");
      return;
    }
    try {
      const caps = await Camera.getCameraCapabilities(selectedCamera()!.id);
      addResult(`Camera capabilities for ${selectedCamera()!.name}:`);
      addResult(`  - Photo formats: ${caps.supportedPhotoFormats.join(", ")}`);
      addResult(`  - Video codecs: ${caps.supportedVideoCodecs.join(", ")}`);
      addResult(`  - Frame rates: ${caps.supportedFrameRates.join(", ")} fps`);
      addResult(`  - ISO range: ${caps.isoRange[0]}-${caps.isoRange[1]}`);
      addResult(`  - Supports RAW: ${caps.supportsRaw}`);
      addResult(`  - Supports ProRAW: ${caps.supportsProRaw}`);
      addResult(`  - Supports HDR: ${caps.supportsHdr}`);
      addResult(`  - Supports Night Mode: ${caps.supportsNightMode}`);
      addResult(`  - Supports Portrait: ${caps.supportsPortraitMode}`);
    } catch (e) {
      addResult(`Error getting capabilities: ${e}`);
    }
  };

  return (
    <div style={{ padding: "20px" }}>
      <h1>iOS Camera Plugin Demo</h1>
      
      <div style={{ "margin-bottom": "20px" }}>
        <h3>Permissions</h3>
        <button onClick={checkPermissions}>Check Permissions</button>
        <button onClick={requestPermissions}>Request Permissions</button>
        <Show when={permissions()}>
          <div>
            Camera: {permissions()!.camera}, 
            Photos: {permissions()!.photoLibrary}, 
            Microphone: {permissions()!.microphone}
          </div>
        </Show>
      </div>

      <div style={{ "margin-bottom": "20px" }}>
        <h3>Basic Camera Functions</h3>
        <button onClick={getCameraList}>Get Cameras</button>
        <button onClick={takePhoto}>Take Photo</button>
        <button onClick={recordVideo}>Record Video</button>
        <button onClick={pickImages}>Pick Images</button>
        <button onClick={pickVideos}>Pick Videos</button>
        <button onClick={pickMedia}>Pick Media</button>
      </div>

      <div style={{ "margin-bottom": "20px" }}>
        <h3>Camera Selection</h3>
        <select onChange={(e) => {
          const cam = cameras().find(c => c.id === e.currentTarget.value);
          setSelectedCamera(cam || null);
        }}>
          <option value="">Select a camera</option>
          <For each={cameras()}>
            {(camera) => <option value={camera.id}>{camera.name} ({camera.position})</option>}
          </For>
        </select>
        <button onClick={getCameraCapabilities} disabled={!selectedCamera()}>
          Get Capabilities
        </button>
      </div>

      <div style={{ "margin-bottom": "20px" }}>
        <h3>Advanced Camera Session</h3>
        <button onClick={startCameraSession} disabled={sessionActive()}>Start Session</button>
        <button onClick={stopCameraSession} disabled={!sessionActive()}>Stop Session</button>
        <button onClick={startPreview} disabled={!sessionActive() || previewActive()}>Start Preview</button>
        <button onClick={stopPreview} disabled={!previewActive()}>Stop Preview</button>
        <button onClick={setManualSettings} disabled={!sessionActive()}>Set Manual Settings</button>
        <button onClick={takeAdvancedPhoto} disabled={!sessionActive()}>Take Advanced Photo</button>
      </div>

      <div style={{ "margin-bottom": "20px" }}>
        <h3>Special Capture Modes</h3>
        <button onClick={captureBurst} disabled={!sessionActive()}>Capture Burst</button>
        <button onClick={capturePanorama} disabled={!sessionActive()}>Capture Panorama</button>
        <div>
          <button onClick={startTimeLapse} disabled={!sessionActive() || isTimeLapsing()}>
            Start Time-Lapse
          </button>
          <button onClick={stopTimeLapse} disabled={!isTimeLapsing()}>
            Stop Time-Lapse
          </button>
        </div>
        <div>
          <button onClick={startSlowMotion} disabled={!sessionActive() || isSlowMotion()}>
            Start Slow Motion
          </button>
          <button onClick={stopSlowMotion} disabled={!isSlowMotion()}>
            Stop Slow Motion
          </button>
        </div>
      </div>

      <div style={{ "margin-bottom": "20px" }}>
        <h3>Camera Controls</h3>
        <button onClick={() => setZoom(1.0)} disabled={!sessionActive()}>1x</button>
        <button onClick={() => setZoom(2.0)} disabled={!sessionActive()}>2x</button>
        <button onClick={() => setZoom(5.0)} disabled={!sessionActive()}>5x</button>
        <button onClick={() => Camera.switchCamera(Camera.CameraPosition.Front)} disabled={!sessionActive()}>
          Front Camera
        </button>
        <button onClick={() => Camera.switchCamera(Camera.CameraPosition.Back)} disabled={!sessionActive()}>
          Back Camera
        </button>
      </div>

      <div style={{ 
        "margin-top": "20px", 
        "padding": "10px", 
        "background": "#f0f0f0", 
        "border-radius": "5px",
        "max-height": "300px",
        "overflow-y": "auto"
      }}>
        <h3>Results</h3>
        <For each={results()}>
          {(result) => <div>{result}</div>}
        </For>
      </div>
    </div>
  );
}