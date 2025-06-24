use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Shortcut {
    pub identifier: String,
    pub title: String,
    pub suggested_invocation_phrase: Option<String>,
    pub is_eligible_for_search: bool,
    pub is_eligible_for_prediction: bool,
    pub user_activity_type: String,
    pub user_info: HashMap<String, serde_json::Value>,
    pub persistent_identifier: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Interaction {
    pub intent: Intent,
    pub donation_date: Option<String>, // ISO 8601
    pub shortcut: Option<Shortcut>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Intent {
    pub identifier: String,
    pub display_name: String,
    pub category: IntentCategory,
    pub parameters: HashMap<String, IntentParameter>,
    pub suggested_invocation_phrase: Option<String>,
    pub image: Option<IntentImage>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum IntentCategory {
    Information,
    Play,
    Order,
    Message,
    Call,
    Search,
    Create,
    Share,
    Toggle,
    Download,
    Custom(String),
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct IntentParameter {
    pub name: String,
    pub value: serde_json::Value,
    pub display_name: String,
    pub prompt: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct IntentImage {
    pub system_name: Option<String>,
    pub template_name: Option<String>,
    pub data: Option<String>, // base64
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct VoiceShortcut {
    pub identifier: String,
    pub invocation_phrase: String,
    pub shortcut: Shortcut,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct UserActivity {
    pub activity_type: String,
    pub title: String,
    pub user_info: HashMap<String, serde_json::Value>,
    pub keywords: Vec<String>,
    pub persistent_identifier: Option<String>,
    pub is_eligible_for_search: bool,
    pub is_eligible_for_public_indexing: bool,
    pub is_eligible_for_handoff: bool,
    pub is_eligible_for_prediction: bool,
    pub content_attributes: Option<ContentAttributes>,
    pub required_user_info_keys: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ContentAttributes {
    pub title: Option<String>,
    pub content_description: Option<String>,
    pub thumbnail_data: Option<String>, // base64
    pub thumbnail_url: Option<String>,
    pub keywords: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ShortcutSuggestion {
    pub intent: Intent,
    pub suggested_phrase: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AppIntent {
    pub identifier: String,
    pub display_name: String,
    pub description: String,
    pub category: IntentCategory,
    pub parameter_definitions: Vec<ParameterDefinition>,
    pub response_template: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ParameterDefinition {
    pub name: String,
    pub display_name: String,
    pub description: String,
    pub parameter_type: ParameterType,
    pub is_required: bool,
    pub default_value: Option<serde_json::Value>,
    pub options: Vec<ParameterOption>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum ParameterType {
    String,
    Number,
    Boolean,
    Date,
    Duration,
    Location,
    Person,
    File,
    Custom(String),
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ParameterOption {
    pub identifier: String,
    pub display_name: String,
    pub synonyms: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct IntentResponse {
    pub success: bool,
    pub user_activity: Option<UserActivity>,
    pub output: HashMap<String, serde_json::Value>,
    pub error: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct DonatedIntent {
    pub identifier: String,
    pub intent: Intent,
    pub donation_date: String, // ISO 8601
    pub interaction_count: u32,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct IntentPrediction {
    pub intent: Intent,
    pub confidence: f64,
    pub reason: PredictionReason,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum PredictionReason {
    TimeOfDay,
    Location,
    UserBehavior,
    RecentUsage,
    ContextualRelevance,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ShortcutEvent {
    pub event_type: ShortcutEventType,
    pub shortcut_identifier: String,
    pub timestamp: String, // ISO 8601
    pub user_info: HashMap<String, serde_json::Value>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum ShortcutEventType {
    Invoked,
    Added,
    Updated,
    Deleted,
    Failed,
}

impl Default for IntentCategory {
    fn default() -> Self {
        IntentCategory::Information
    }
}

impl Default for ParameterType {
    fn default() -> Self {
        ParameterType::String
    }
}