pub mod date;
pub mod permissions;

use serde::{Deserialize, Serialize};

/// Common error types that can be used across all iOS plugins
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PluginError {
    pub code: String,
    pub message: String,
    pub details: Option<serde_json::Value>,
}

/// Common result type for plugin operations
pub type PluginResult<T> = Result<T, PluginError>;

/// Trait for converting iOS-specific errors to plugin errors
pub trait IntoPluginError {
    fn into_plugin_error(self) -> PluginError;
}

/// Common metadata structure used across different data types
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct Metadata {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub source: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub device: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub app_bundle_id: Option<String>,
    #[serde(flatten)]
    pub custom: serde_json::Map<String, serde_json::Value>,
}