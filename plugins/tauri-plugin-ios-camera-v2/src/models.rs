use serde::{Deserialize, Serialize};
use tauri::plugin::PermissionState;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CameraPermissions {
    pub camera: PermissionState,
    pub photo_library: PermissionState,
    pub microphone: PermissionState,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionRequest {
    pub camera: bool,
    pub photo_library: bool,
    pub microphone: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PhotoOptions {
    pub camera_position: CameraPosition,
    pub quality: ImageQuality,
    pub allow_editing: bool,
    pub save_to_gallery: bool,
    pub flash_mode: FlashMode,
    pub max_width: Option<u32>,
    pub max_height: Option<u32>,
}

impl Default for PhotoOptions {
    fn default() -> Self {
        Self {
            camera_position: CameraPosition::Back,
            quality: ImageQuality::High,
            allow_editing: false,
            save_to_gallery: true,
            flash_mode: FlashMode::Auto,
            max_width: None,
            max_height: None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct VideoOptions {
    pub camera_position: CameraPosition,
    pub quality: VideoQuality,
    pub max_duration: Option<u32>, // seconds
    pub save_to_gallery: bool,
    pub flash_mode: FlashMode,
}

impl Default for VideoOptions {
    fn default() -> Self {
        Self {
            camera_position: CameraPosition::Back,
            quality: VideoQuality::High,
            max_duration: None,
            save_to_gallery: true,
            flash_mode: FlashMode::Auto,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PickerOptions {
    pub allow_multiple: bool,
    pub include_metadata: bool,
    pub limit: Option<u32>,
    pub media_types: Vec<MediaType>,
}

impl Default for PickerOptions {
    fn default() -> Self {
        Self {
            allow_multiple: false,
            include_metadata: false,
            limit: None,
            media_types: vec![MediaType::Image],
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CaptureResult {
    pub path: String,
    pub width: u32,
    pub height: u32,
    pub size: u64, // bytes
    pub mime_type: String,
    pub duration: Option<f64>, // seconds for video
    pub metadata: Option<MediaMetadata>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MediaItem {
    pub id: String,
    pub path: String,
    pub width: u32,
    pub height: u32,
    pub size: u64,
    pub mime_type: String,
    pub creation_date: Option<String>,
    pub modification_date: Option<String>,
    pub duration: Option<f64>,
    pub location: Option<Location>,
    pub metadata: Option<MediaMetadata>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MediaMetadata {
    pub make: Option<String>,
    pub model: Option<String>,
    pub orientation: Option<u32>,
    pub date_time_original: Option<String>,
    pub f_number: Option<f64>,
    pub exposure_time: Option<String>,
    pub iso_speed: Option<u32>,
    pub gps_latitude: Option<f64>,
    pub gps_longitude: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Location {
    pub latitude: f64,
    pub longitude: f64,
    pub altitude: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CameraInfo {
    pub id: String,
    pub position: CameraPosition,
    pub name: String,
    pub has_flash: bool,
    pub has_torch: bool,
    pub max_zoom: f32,
    pub min_zoom: f32,
    pub supports_video: bool,
    pub supports_photo: bool,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum CameraPosition {
    Front,
    Back,
    External,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum ImageQuality {
    Low,
    Medium,
    High,
    Original,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum VideoQuality {
    Low,    // 480p
    Medium, // 720p
    High,   // 1080p
    Ultra,  // 4K
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum FlashMode {
    Off,
    On,
    Auto,
    Torch,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum MediaType {
    Image,
    Video,
    Any,
}