use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetConfiguration {
    pub kind: String,
    pub family: WidgetFamily,
    pub intent_configuration: Option<HashMap<String, serde_json::Value>>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum WidgetFamily {
    SystemSmall,
    SystemMedium,
    SystemLarge,
    SystemExtraLarge,
    AccessoryCircular,
    AccessoryRectangular,
    AccessoryInline,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetData {
    pub kind: String,
    pub family: Option<WidgetFamily>,
    pub content: WidgetContent,
    pub refresh_date: Option<DateTime<Utc>>,
    pub expiration_date: Option<DateTime<Utc>>,
    pub relevance: Option<WidgetRelevance>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetContent {
    pub title: Option<String>,
    pub subtitle: Option<String>,
    pub body: Option<String>,
    pub image: Option<String>, // base64 or URL
    pub background_image: Option<String>,
    pub tint_color: Option<String>, // hex color
    pub font: Option<WidgetFont>,
    pub custom_data: HashMap<String, serde_json::Value>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetFont {
    pub size: f32,
    pub weight: FontWeight,
    pub design: FontDesign,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum FontWeight {
    UltraLight,
    Thin,
    Light,
    Regular,
    Medium,
    Semibold,
    Bold,
    Heavy,
    Black,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum FontDesign {
    Default,
    Serif,
    Rounded,
    Monospaced,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetRelevance {
    pub score: f64,
    pub duration: i64, // seconds
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetInfo {
    pub bundle_identifier: String,
    pub display_name: String,
    pub description: String,
    pub supported_families: Vec<WidgetFamily>,
    pub configuration_display_name: Option<String>,
    pub custom_intents: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetUrl {
    pub scheme: String,
    pub host: Option<String>,
    pub path: Option<String>,
    pub query_parameters: HashMap<String, String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetPreview {
    pub family: WidgetFamily,
    pub display_name: String,
    pub description: String,
    pub preview_image: String, // base64
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetRefreshSchedule {
    pub widget_kind: String,
    pub refresh_intervals: Vec<RefreshInterval>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct RefreshInterval {
    pub start_date: DateTime<Utc>,
    pub interval_seconds: i64,
    pub repeat_count: Option<u32>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetTimeline {
    pub entries: Vec<WidgetEntry>,
    pub policy: TimelineReloadPolicy,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetEntry {
    pub date: DateTime<Utc>,
    pub content: WidgetContent,
    pub relevance: Option<WidgetRelevance>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub enum TimelineReloadPolicy {
    AtEnd,
    After(DateTime<Utc>),
    Never,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WidgetEvent {
    pub event_type: WidgetEventType,
    pub widget_kind: String,
    pub widget_family: Option<WidgetFamily>,
    pub timestamp: DateTime<Utc>,
    pub data: Option<serde_json::Value>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum WidgetEventType {
    Appeared,
    Disappeared,
    Tapped,
    TimelineReloaded,
    ConfigurationChanged,
    Error,
}

impl Default for WidgetFamily {
    fn default() -> Self {
        WidgetFamily::SystemMedium
    }
}

impl Default for FontWeight {
    fn default() -> Self {
        FontWeight::Regular
    }
}

impl Default for FontDesign {
    fn default() -> Self {
        FontDesign::Default
    }
}