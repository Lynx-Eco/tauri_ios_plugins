# Tauri Plugin iOS Photos

Complete access to the iOS Photos framework for managing photos, videos, and albums.

## Features

- Full photo library access with read/write permissions
- Album management (create, delete, list)
- Asset querying with extensive filters
- Image and video export with format conversion
- Metadata extraction (EXIF, GPS, camera info)
- Live Photos support
- Burst photos handling
- Smart albums access
- Asset search capabilities
- Batch operations

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-photos = "0.1"
```

## iOS Configuration

Add to your app's `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photos to display and manage them</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save photos to your library</string>
```

## Usage

### Rust

```rust
use tauri_plugin_ios_photos::{PhotosExt, AccessLevel, AssetQuery, MediaType, SortOrder};

// Check and request permissions
#[tauri::command]
async fn setup_photos(app: tauri::AppHandle) -> Result<(), String> {
    let photos = app.photos();
    
    let permissions = photos.check_permissions()
        .map_err(|e| e.to_string())?;
    
    if permissions.read_write != PermissionState::Granted {
        photos.request_permissions(AccessLevel::ReadWrite)
            .map_err(|e| e.to_string())?;
    }
    
    Ok(())
}

// Get recent photos
#[tauri::command]
async fn get_recent_photos(app: tauri::AppHandle) -> Result<Vec<Asset>, String> {
    let query = AssetQuery {
        media_types: vec![MediaType::Image],
        sort_order: SortOrder::CreationDateDescending,
        limit: Some(50),
        ..Default::default()
    };
    
    app.photos()
        .get_assets(query)
        .map_err(|e| e.to_string())
}

// Create album and save photo
#[tauri::command]
async fn save_to_album(
    app: tauri::AppHandle,
    image_data: String,
    album_name: String
) -> Result<String, String> {
    let photos = app.photos();
    
    // Create album
    let album = photos.create_album(&album_name)
        .map_err(|e| e.to_string())?;
    
    // Save image to album
    let save_data = SaveImageData {
        image_data,
        to_album: Some(album.id),
        metadata: None,
    };
    
    photos.save_image(save_data)
        .map_err(|e| e.to_string())
}
```

### JavaScript/TypeScript

```typescript
import { 
  checkPermissions,
  requestPermissions,
  getAlbums,
  getAssets,
  createAlbum,
  saveImage,
  exportAsset,
  getAssetMetadata
} from 'tauri-plugin-ios-photos';

// Setup permissions
const permissions = await checkPermissions();
if (permissions.readWrite !== 'granted') {
  await requestPermissions({ accessLevel: 'readWrite' });
}

// Get all albums
const albums = await getAlbums({
  includeEmpty: false,
  includeHidden: false,
  includeSmartAlbums: true
});

albums.forEach(album => {
  console.log(`${album.title}: ${album.assetCount} items`);
});

// Query photos with filters
const photos = await getAssets({
  mediaTypes: ['image'],
  startDate: '2024-01-01T00:00:00Z',
  isFavorite: true,
  hasLocation: true,
  sortOrder: 'creationDateDescending',
  limit: 100
});

// Get detailed metadata
const metadata = await getAssetMetadata(photos[0].id);
console.log('Camera:', metadata.takenWith?.model);
console.log('Location:', metadata.gps);
console.log('EXIF:', metadata.exif);

// Export with resizing
const exportPath = await exportAsset(photos[0].id, {
  imageFormat: 'jpeg',
  quality: 0.8,
  maxWidth: 1920,
  maxHeight: 1080,
  preserveMetadata: true
});

// Save new image
const assetId = await saveImage({
  imageData: base64ImageData,
  toAlbum: album.id,
  metadata: {
    creationDate: new Date().toISOString(),
    location: {
      latitude: 37.7749,
      longitude: -122.4194
    }
  }
});

// Batch delete
await deleteAssets([assetId1, assetId2, assetId3]);
```

## API Reference

### Types

#### Asset
```typescript
interface Asset {
  id: string;
  mediaType: 'unknown' | 'image' | 'video' | 'audio';
  mediaSubtype: string[];
  creationDate: string;
  modificationDate: string;
  width: number;
  height: number;
  duration?: number;      // Video duration in seconds
  isFavorite: boolean;
  isHidden: boolean;
  location?: AssetLocation;
  burstIdentifier?: string;
  representsBurst: boolean;
}
```

#### Album
```typescript
interface Album {
  id: string;
  title: string;
  assetCount: number;
  startDate?: string;
  endDate?: string;
  albumType: AlbumType;
  canAddAssets: boolean;
  canRemoveAssets: boolean;
  canDelete: boolean;
  isSmartAlbum: boolean;
}
```

#### AssetQuery
```typescript
interface AssetQuery {
  albumId?: string;
  mediaTypes?: MediaType[];
  mediaSubtypes?: MediaSubtype[];
  startDate?: string;
  endDate?: string;
  isFavorite?: boolean;
  isHidden?: boolean;
  hasLocation?: boolean;
  burstOnly?: boolean;
  sortOrder?: SortOrder;
  limit?: number;
  offset?: number;
}
```

### Commands

#### `checkPermissions()`
Check photo library permissions.

#### `requestPermissions(accessLevel: AccessLevel)`
Request photo library access (readWrite or addOnly).

#### `getAlbums(options?: AlbumQuery)`
List all albums with filtering options.

#### `getAssets(query?: AssetQuery)`
Query assets with extensive filtering.

#### `createAlbum(title: string)`
Create a new album.

#### `deleteAlbum(id: string)`
Delete an album (if allowed).

#### `saveImage(data: SaveImageData)`
Save image to photo library.

#### `saveVideo(path: string, toAlbum?: string)`
Save video from file path.

#### `exportAsset(id: string, options?: ExportOptions)`
Export asset with format conversion.

#### `getAssetMetadata(id: string)`
Get detailed metadata including EXIF.

#### `deleteAssets(ids: string[])`
Batch delete assets.

## Media Subtypes

- `photoPanorama` - Panoramic photos
- `photoHDR` - HDR photos
- `photoScreenshot` - Screenshots
- `photoLive` - Live Photos
- `photoDepthEffect` - Portrait mode photos
- `videoStreamed` - Streamed videos
- `videoHighFrameRate` - High FPS videos
- `videoTimelapse` - Timelapse videos
- `videoCinematic` - Cinematic videos
- `videoSloMo` - Slow motion videos

## Smart Albums

The plugin provides access to system smart albums:
- Recently Added
- Favorites
- Panoramas
- Videos
- Slo-mo
- Bursts
- Screenshots
- Live Photos
- And more...

## Error Handling

- `AccessDenied` - Photo library permission denied
- `AlbumNotFound` - Album doesn't exist
- `AssetNotFound` - Asset doesn't exist
- `SystemAlbumReadOnly` - Cannot modify system album
- `AlbumNotEmpty` - Cannot delete non-empty album
- `InvalidImageData` - Invalid base64 image data

## License

MIT or Apache-2.0