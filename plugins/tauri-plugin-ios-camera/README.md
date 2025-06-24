# Tauri Plugin iOS Camera

Access camera, photo library, and capture media in your Tauri iOS applications.

## Features

- Camera photo and video capture
- Photo library picker with multi-selection
- Camera switching (front/back)
- Flash control
- Image resizing and quality control
- Video quality and duration limits
- Metadata extraction
- Permission management

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-camera = "0.1"
```

## iOS Configuration

Add to your app's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and videos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select photos and videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record videos with audio</string>
```

## Usage

### Rust

```rust
use tauri_plugin_ios_camera::{CameraExt, PhotoOptions, CameraPosition, ImageQuality};

// Take a photo
#[tauri::command]
async fn capture_photo(app: tauri::AppHandle) -> Result<CaptureResult, String> {
    let camera = app.camera();
    
    // Check permissions
    let permissions = camera.check_permissions()
        .map_err(|e| e.to_string())?;
    
    if permissions.camera != PermissionState::Granted {
        camera.request_permissions(PermissionRequest {
            camera: true,
            photo_library: false,
            microphone: false,
        }).map_err(|e| e.to_string())?;
    }
    
    // Take photo with options
    let options = PhotoOptions {
        camera_position: CameraPosition::Back,
        quality: ImageQuality::High,
        allow_editing: true,
        save_to_gallery: true,
        flash_mode: FlashMode::Auto,
        max_width: Some(1920),
        max_height: Some(1080),
    };
    
    camera.take_photo(options)
        .map_err(|e| e.to_string())
}

// Pick images from gallery
#[tauri::command]
async fn pick_images(app: tauri::AppHandle) -> Result<Vec<MediaItem>, String> {
    let options = PickerOptions {
        allow_multiple: true,
        include_metadata: true,
        limit: Some(5),
        media_types: vec![MediaType::Image],
    };
    
    app.camera()
        .pick_image(options)
        .map_err(|e| e.to_string())
}
```

### JavaScript/TypeScript

```typescript
import { 
  checkPermissions,
  requestPermissions,
  takePhoto,
  recordVideo,
  pickImage,
  getCameraInfo
} from 'tauri-plugin-ios-camera';

// Check and request permissions
const permissions = await checkPermissions();
if (permissions.camera !== 'granted') {
  await requestPermissions({ 
    camera: true, 
    photoLibrary: true,
    microphone: true 
  });
}

// Take a photo
const photo = await takePhoto({
  cameraPosition: 'back',
  quality: 'high',
  allowEditing: true,
  saveToGallery: true,
  flashMode: 'auto',
  maxWidth: 1920,
  maxHeight: 1080
});

console.log(`Photo saved to: ${photo.path}`);
console.log(`Size: ${photo.width}x${photo.height}`);

// Record video
const video = await recordVideo({
  cameraPosition: 'front',
  quality: 'high',
  maxDuration: 30, // seconds
  saveToGallery: true
});

// Pick multiple images
const images = await pickImage({
  allowMultiple: true,
  includeMetadata: true,
  limit: 5
});

// Get available cameras
const cameras = await getCameraInfo();
cameras.forEach(camera => {
  console.log(`${camera.name} - ${camera.position}`);
  console.log(`Flash: ${camera.hasFlash}, Torch: ${camera.hasTorch}`);
});
```

## API Reference

### Types

#### CaptureResult
```typescript
interface CaptureResult {
  path: string;           // File path
  width: number;          // Width in pixels
  height: number;         // Height in pixels
  size: number;           // File size in bytes
  mimeType: string;       // MIME type
  duration?: number;      // Video duration in seconds
  metadata?: MediaMetadata;
}
```

#### PhotoOptions
```typescript
interface PhotoOptions {
  cameraPosition: 'front' | 'back';
  quality: 'low' | 'medium' | 'high' | 'original';
  allowEditing: boolean;
  saveToGallery: boolean;
  flashMode: 'off' | 'on' | 'auto' | 'torch';
  maxWidth?: number;
  maxHeight?: number;
}
```

#### VideoOptions
```typescript
interface VideoOptions {
  cameraPosition: 'front' | 'back';
  quality: 'low' | 'medium' | 'high' | 'ultra';
  maxDuration?: number;   // seconds
  saveToGallery: boolean;
  flashMode: 'off' | 'on' | 'auto';
}
```

### Commands

#### `checkPermissions()`
Check camera, photo library, and microphone permissions.

#### `requestPermissions(permissions: PermissionRequest)`
Request specific permissions.

#### `takePhoto(options?: PhotoOptions)`
Capture a photo using the camera.

#### `recordVideo(options?: VideoOptions)`
Record a video using the camera.

#### `pickImage(options?: PickerOptions)`
Select images from the photo library.

#### `pickVideo(options?: PickerOptions)`
Select videos from the photo library.

#### `getCameraInfo()`
Get information about available cameras.

## Quality Settings

### Image Quality
- `low`: 25% JPEG quality
- `medium`: 50% JPEG quality
- `high`: 85% JPEG quality (default)
- `original`: 100% JPEG quality

### Video Quality
- `low`: 480p
- `medium`: 720p
- `high`: 1080p (default)
- `ultra`: 4K

## Error Handling

The plugin provides detailed error types:

- `CameraAccessDenied` - Camera permission denied
- `PhotoLibraryAccessDenied` - Photo library permission denied
- `MicrophoneAccessDenied` - Microphone permission denied
- `CameraNotAvailable` - No camera available
- `CaptureFailed` - Failed to capture media
- `Cancelled` - User cancelled operation

## License

MIT or Apache-2.0