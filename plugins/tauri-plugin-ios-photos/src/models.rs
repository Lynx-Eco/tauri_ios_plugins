use serde::{Deserialize, Serialize};
use tauri::plugin::PermissionState;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PhotosPermissions {
    pub read_write: PermissionState,
    pub add_only: PermissionState,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum AccessLevel {
    ReadWrite,
    AddOnly,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Album {
    pub id: String,
    pub title: String,
    pub asset_count: usize,
    pub start_date: Option<String>,
    pub end_date: Option<String>,
    pub album_type: AlbumType,
    pub can_add_assets: bool,
    pub can_remove_assets: bool,
    pub can_delete: bool,
    pub is_smart_album: bool,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum AlbumType {
    Regular,
    SmartAlbum,
    Shared,
    CloudShared,
    Faces,
    Moments,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct AlbumQuery {
    pub album_types: Vec<AlbumType>,
    pub include_empty: bool,
    pub include_hidden: bool,
    pub include_smart_albums: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Asset {
    pub id: String,
    pub media_type: MediaType,
    pub media_subtype: Vec<MediaSubtype>,
    pub creation_date: String,
    pub modification_date: String,
    pub width: u32,
    pub height: u32,
    pub duration: Option<f64>, // seconds for video
    pub is_favorite: bool,
    pub is_hidden: bool,
    pub location: Option<AssetLocation>,
    pub burst_identifier: Option<String>,
    pub represents_burst: bool,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum MediaType {
    Unknown,
    Image,
    Video,
    Audio,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum MediaSubtype {
    PhotoPanorama,
    PhotoHDR,
    PhotoScreenshot,
    PhotoLive,
    PhotoDepthEffect,
    VideoStreamed,
    VideoHighFrameRate,
    VideoTimelapse,
    VideoCinematic,
    VideoSloMo,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AssetLocation {
    pub latitude: f64,
    pub longitude: f64,
    pub altitude: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AssetQuery {
    pub album_id: Option<String>,
    pub media_types: Vec<MediaType>,
    pub media_subtypes: Vec<MediaSubtype>,
    pub start_date: Option<String>,
    pub end_date: Option<String>,
    pub is_favorite: Option<bool>,
    pub is_hidden: Option<bool>,
    pub has_location: Option<bool>,
    pub burst_only: Option<bool>,
    pub sort_order: SortOrder,
    pub limit: Option<usize>,
    pub offset: Option<usize>,
}

impl Default for AssetQuery {
    fn default() -> Self {
        Self {
            album_id: None,
            media_types: vec![],
            media_subtypes: vec![],
            start_date: None,
            end_date: None,
            is_favorite: None,
            is_hidden: None,
            has_location: None,
            burst_only: None,
            sort_order: SortOrder::CreationDateDescending,
            limit: None,
            offset: None,
        }
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum SortOrder {
    CreationDateAscending,
    CreationDateDescending,
    ModificationDateAscending,
    ModificationDateDescending,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SaveImageData {
    pub image_data: String, // Base64 encoded
    pub to_album: Option<String>,
    pub metadata: Option<ImageMetadata>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ImageMetadata {
    pub creation_date: Option<String>,
    pub location: Option<AssetLocation>,
    pub exif: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ExportOptions {
    pub image_format: Option<ImageFormat>,
    pub video_format: Option<VideoFormat>,
    pub quality: Option<f32>, // 0.0 to 1.0
    pub max_width: Option<u32>,
    pub max_height: Option<u32>,
    pub preserve_metadata: bool,
}

impl Default for ExportOptions {
    fn default() -> Self {
        Self {
            image_format: None,
            video_format: None,
            quality: None,
            max_width: None,
            max_height: None,
            preserve_metadata: true,
        }
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum ImageFormat {
    JPEG,
    PNG,
    HEIF,
    TIFF,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum VideoFormat {
    MOV,
    MP4,
    M4V,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AssetMetadata {
    pub exif: Option<serde_json::Value>,
    pub gps: Option<AssetLocation>,
    pub creation_date: String,
    pub modification_date: String,
    pub taken_with: Option<CameraInfo>,
    pub dimensions: Dimensions,
    pub file_size: u64,
    pub codec: Option<String>,
    pub bit_rate: Option<u32>,
    pub frame_rate: Option<f32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CameraInfo {
    pub make: Option<String>,
    pub model: Option<String>,
    pub lens_make: Option<String>,
    pub lens_model: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Dimensions {
    pub width: u32,
    pub height: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SearchQuery {
    pub text: Option<String>,
    pub album_ids: Vec<String>,
    pub media_types: Vec<MediaType>,
    pub date_range: Option<DateRange>,
    pub location_radius: Option<LocationRadius>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DateRange {
    pub start_date: String,
    pub end_date: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LocationRadius {
    pub latitude: f64,
    pub longitude: f64,
    pub radius_meters: f64,
}