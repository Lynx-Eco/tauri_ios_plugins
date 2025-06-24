# Tauri Plugin iOS Microphone

High-quality audio recording with real-time monitoring for Tauri iOS applications.

## Features

- Audio recording with multiple formats (M4A, WAV, CAF, AIFF, MP3)
- Real-time audio level monitoring
- Recording pause/resume functionality
- Multiple audio input selection
- Audio quality presets and custom bit rates
- Silence detection
- Noise suppression and echo cancellation
- Maximum duration limits
- Event-based updates

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-microphone = "0.1"
```

## iOS Configuration

Add to your app's `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio</string>
```

## Usage

### Rust

```rust
use tauri_plugin_ios_microphone::{MicrophoneExt, RecordingOptions, AudioFormat, AudioQuality};

// Start recording
#[tauri::command]
async fn start_audio_recording(app: tauri::AppHandle) -> Result<RecordingSession, String> {
    let microphone = app.microphone();
    
    // Check permissions
    let status = microphone.check_permissions()
        .map_err(|e| e.to_string())?;
    
    if status.microphone != PermissionState::Granted {
        microphone.request_permissions()
            .map_err(|e| e.to_string())?;
    }
    
    // Configure recording
    let options = RecordingOptions {
        format: AudioFormat::M4A,
        quality: AudioQuality::High,
        sample_rate: Some(44100.0),
        channels: Some(2),
        bit_rate: None, // Use quality preset
        max_duration: Some(300.0), // 5 minutes
        silence_detection: true,
        noise_suppression: true,
        echo_cancellation: false,
    };
    
    microphone.start_recording(options)
        .map_err(|e| e.to_string())
}

// Monitor audio levels
#[tauri::command]
async fn get_levels(app: tauri::AppHandle) -> Result<AudioLevels, String> {
    app.microphone()
        .get_audio_levels()
        .map_err(|e| e.to_string())
}

// Stop and save recording
#[tauri::command]
async fn stop_recording(app: tauri::AppHandle) -> Result<RecordingResult, String> {
    app.microphone()
        .stop_recording()
        .map_err(|e| e.to_string())
}
```

### JavaScript/TypeScript

```typescript
import { 
  checkPermissions,
  requestPermissions,
  startRecording,
  stopRecording,
  pauseRecording,
  resumeRecording,
  getAudioLevels,
  getAvailableInputs,
  addPluginListener
} from 'tauri-plugin-ios-microphone';

// Check and request permissions
const permissions = await checkPermissions();
if (permissions.microphone !== 'granted') {
  await requestPermissions();
}

// Start recording with options
const session = await startRecording({
  format: 'm4a',
  quality: 'high',
  sampleRate: 44100,
  channels: 2,
  maxDuration: 300, // 5 minutes
  silenceDetection: true,
  noiseSuppression: true,
  echoCancellation: false
});

console.log(`Recording started: ${session.id}`);

// Listen for audio level updates
const levelListener = await addPluginListener(
  'ios-microphone',
  'levelUpdate',
  (event) => {
    console.log(`Peak: ${event.peakLevel}, Average: ${event.averageLevel}`);
    if (event.isClipping) {
      console.warn('Audio is clipping!');
    }
  }
);

// Pause/resume recording
await pauseRecording();
// ... later
await resumeRecording();

// Stop and get result
const result = await stopRecording();
console.log(`Recording saved to: ${result.path}`);
console.log(`Duration: ${result.duration}s, Size: ${result.size} bytes`);

// Get available inputs
const inputs = await getAvailableInputs();
inputs.forEach(input => {
  console.log(`${input.name} (${input.portType})`);
});

// Clean up listener
levelListener.remove();
```

## API Reference

### Types

#### RecordingOptions
```typescript
interface RecordingOptions {
  format: 'm4a' | 'wav' | 'caf' | 'aiff' | 'mp3';
  quality: 'low' | 'medium' | 'high' | 'lossless';
  sampleRate?: number;      // Hz (e.g., 44100, 48000)
  channels?: number;         // 1 (mono) or 2 (stereo)
  bitRate?: number;          // Custom bit rate in bps
  maxDuration?: number;      // Maximum duration in seconds
  silenceDetection: boolean;
  noiseSuppression: boolean;
  echoCancellation: boolean;
}
```

#### RecordingResult
```typescript
interface RecordingResult {
  path: string;              // File path
  duration: number;          // Duration in seconds
  size: number;              // File size in bytes
  format: string;            // Audio format
  sampleRate: number;        // Sample rate in Hz
  channels: number;          // Number of channels
  bitRate: number;           // Bit rate in bps
  peakLevel: number;         // Peak amplitude (0.0-1.0)
  averageLevel: number;      // Average amplitude (0.0-1.0)
}
```

#### AudioInput
```typescript
interface AudioInput {
  id: string;
  name: string;
  portType: 'builtInMic' | 'headsetMic' | 'usbAudio' | 'bluetoothHFP' | 'carAudio' | 'lineIn' | 'other';
  isDefault: boolean;
  channels: number;
  sampleRate: number;
}
```

### Commands

#### `checkPermissions()`
Check microphone permission status.

#### `requestPermissions()`
Request microphone access permission.

#### `startRecording(options?: RecordingOptions)`
Start audio recording with specified options.

#### `stopRecording()`
Stop recording and save the audio file.

#### `pauseRecording()`
Pause the current recording.

#### `resumeRecording()`
Resume a paused recording.

#### `getRecordingState()`
Get current recording state: 'idle', 'recording', 'paused', or 'stopping'.

#### `getAudioLevels()`
Get real-time audio levels (peak and average).

#### `getAvailableInputs()`
List all available audio input devices.

#### `setAudioInput(inputId: string)`
Switch to a different audio input device.

#### `getRecordingDuration()`
Get the current recording duration in seconds.

## Events

The plugin emits the following events:

- `recordingStarted` - Recording has started
- `recordingPaused` - Recording was paused
- `recordingResumed` - Recording was resumed
- `recordingStopped` - Recording has stopped
- `levelUpdate` - Audio level update (emitted ~10 times per second)
- `maxDurationReached` - Maximum duration limit reached
- `silenceDetected` - Silence detected (if enabled)
- `recordingError` - An error occurred during recording
- `inputChanged` - Audio input device changed

## Audio Quality Presets

- `low`: 64 kbps
- `medium`: 128 kbps
- `high`: 256 kbps (default)
- `lossless`: 320 kbps

## Error Handling

The plugin provides detailed error types:

- `AccessDenied` - Microphone permission denied
- `NotRecording` - No recording in progress
- `AlreadyRecording` - Recording already active
- `RecordingFailed` - Failed to start/stop recording
- `InvalidFormat` - Unsupported audio format
- `InputNotFound` - Audio input device not found

## License

MIT or Apache-2.0