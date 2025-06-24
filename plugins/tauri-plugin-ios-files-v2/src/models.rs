use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FilePickerOptions {
    pub types: Vec<FileType>,
    pub allow_multiple: bool,
    pub starting_directory: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub enum FileType {
    Image,
    Video,
    Audio,
    Pdf,
    Text,
    Spreadsheet,
    Presentation,
    Archive,
    Custom(Vec<String>), // UTI types
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PickedFile {
    pub url: String,
    pub name: String,
    pub size: u64,
    pub mime_type: Option<String>,
    pub uti_type: String,
    pub is_directory: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SaveFileOptions {
    pub suggested_name: String,
    pub types: Vec<FileType>,
    pub data: FileData,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub enum FileData {
    Base64(String),
    Text(String),
    Url(String),
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct DocumentInfo {
    pub url: String,
    pub name: String,
    pub size: u64,
    pub created_date: DateTime<Utc>,
    pub modified_date: DateTime<Utc>,
    pub accessed_date: Option<DateTime<Utc>>,
    pub mime_type: Option<String>,
    pub uti_type: String,
    pub is_directory: bool,
    pub is_package: bool,
    pub is_hidden: bool,
    pub is_alias: bool,
    pub cloud_status: CloudStatus,
    pub tags: Vec<String>,
    pub attributes: HashMap<String, String>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum CloudStatus {
    Current,
    Downloading,
    Downloaded,
    NotDownloaded,
    NotInCloud,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ImportOptions {
    pub types: Vec<FileType>,
    pub allow_multiple: bool,
    pub copy_to_app: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ExportOptions {
    pub file_urls: Vec<String>,
    pub destination_name: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ListOptions {
    pub directory_url: Option<String>,
    pub include_hidden: bool,
    pub include_packages: bool,
    pub sort_by: SortOption,
    pub filter: Option<FileFilter>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum SortOption {
    Name,
    Date,
    Size,
    Type,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FileFilter {
    pub types: Option<Vec<FileType>>,
    pub name_pattern: Option<String>,
    pub min_size: Option<u64>,
    pub max_size: Option<u64>,
    pub modified_after: Option<DateTime<Utc>>,
    pub modified_before: Option<DateTime<Utc>>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FileOperation {
    pub source_url: String,
    pub destination_url: String,
    pub overwrite: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ShareOptions {
    pub file_urls: Vec<String>,
    pub exclude_activity_types: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PreviewOptions {
    pub file_url: String,
    pub can_edit: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CloudDownloadProgress {
    pub file_url: String,
    pub progress: f64,
    pub downloaded_bytes: u64,
    pub total_bytes: u64,
    pub status: CloudDownloadStatus,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum CloudDownloadStatus {
    Starting,
    Downloading,
    Completed,
    Failed,
    Cancelled,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MonitoringOptions {
    pub directory_urls: Vec<String>,
    pub recursive: bool,
    pub events: Vec<MonitoringEvent>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum MonitoringEvent {
    Created,
    Modified,
    Deleted,
    Renamed,
    AttributesChanged,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FileChange {
    pub file_url: String,
    pub event_type: MonitoringEvent,
    pub old_url: Option<String>, // For rename events
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SecurityScopedResource {
    pub url: String,
    pub bookmark_data: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FilePermissions {
    pub readable: bool,
    pub writable: bool,
    pub deletable: bool,
    pub executable: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SpaceInfo {
    pub total_space: u64,
    pub available_space: u64,
    pub used_space: u64,
    pub important_space: u64,
    pub opportunistic_space: u64,
}

impl Default for FilePickerOptions {
    fn default() -> Self {
        Self {
            types: vec![],
            allow_multiple: false,
            starting_directory: None,
        }
    }
}

impl Default for ListOptions {
    fn default() -> Self {
        Self {
            directory_url: None,
            include_hidden: false,
            include_packages: false,
            sort_by: SortOption::Name,
            filter: None,
        }
    }
}