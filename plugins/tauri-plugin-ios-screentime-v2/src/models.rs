use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ScreenTimeSummary {
    pub date: DateTime<Utc>,
    pub total_screen_time: i64, // seconds
    pub total_pickups: i32,
    pub first_pickup: Option<DateTime<Utc>>,
    pub most_used_app: Option<AppUsageInfo>,
    pub most_used_category: Option<CategoryUsageInfo>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AppUsageInfo {
    pub bundle_id: String,
    pub display_name: String,
    pub duration: i64, // seconds
    pub number_of_pickups: i32,
    pub number_of_notifications: i32,
    pub category: AppCategory,
    pub icon: Option<String>, // base64 encoded
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum AppCategory {
    Social,
    Entertainment,
    Productivity,
    Education,
    Games,
    Health,
    Finance,
    Shopping,
    News,
    Travel,
    Utilities,
    Other,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CategoryUsageInfo {
    pub category: AppCategory,
    pub duration: i64, // seconds
    pub number_of_apps: i32,
    pub apps: Vec<String>, // bundle IDs
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WebUsageInfo {
    pub domain: String,
    pub duration: i64, // seconds
    pub number_of_visits: i32,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct DeviceActivity {
    pub timestamp: DateTime<Utc>,
    pub event_type: DeviceEventType,
    pub associated_app: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum DeviceEventType {
    ScreenOn,
    ScreenOff,
    AppOpen,
    AppClose,
    NotificationReceived,
    NotificationInteracted,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct NotificationsSummary {
    pub total_notifications: i32,
    pub notifications_by_app: HashMap<String, i32>,
    pub notifications_by_hour: HashMap<i32, i32>, // hour (0-23) -> count
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PickupsSummary {
    pub total_pickups: i32,
    pub pickups_by_hour: HashMap<i32, i32>, // hour (0-23) -> count
    pub average_time_between_pickups: i64, // seconds
    pub longest_session: i64, // seconds
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AppLimit {
    pub id: String,
    pub bundle_ids: Vec<String>,
    pub time_limit: i64, // seconds per day
    pub days_of_week: Vec<DayOfWeek>,
    pub enabled: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum DayOfWeek {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct DowntimeSchedule {
    pub id: String,
    pub start_time: String, // HH:MM format
    pub end_time: String, // HH:MM format
    pub days_of_week: Vec<DayOfWeek>,
    pub allowed_apps: Vec<String>, // bundle IDs
    pub enabled: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CommunicationSafetySettings {
    pub check_photos_and_videos: bool,
    pub communication_safety_enabled: bool,
    pub notification_settings: CommunicationNotificationSettings,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CommunicationNotificationSettings {
    pub notify_child: bool,
    pub notify_parent: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ScreenDistance {
    pub current_distance: f64, // centimeters
    pub is_too_close: bool,
    pub recommended_distance: f64, // centimeters
    pub duration_too_close: i64, // seconds today
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct UsageTrend {
    pub period: TrendPeriod,
    pub screen_time_trend: TrendDirection,
    pub pickups_trend: TrendDirection,
    pub screen_time_change: f64, // percentage
    pub pickups_change: f64, // percentage
    pub data_points: Vec<UsageDataPoint>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum TrendPeriod {
    Week,
    Month,
    Year,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum TrendDirection {
    Up,
    Down,
    Stable,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct UsageDataPoint {
    pub date: DateTime<Utc>,
    pub screen_time: i64, // seconds
    pub pickups: i32,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct UsageReport {
    pub start_date: DateTime<Utc>,
    pub end_date: DateTime<Utc>,
    pub total_screen_time: i64,
    pub average_daily_screen_time: i64,
    pub total_pickups: i32,
    pub average_daily_pickups: i32,
    pub app_usage: Vec<AppUsageInfo>,
    pub category_usage: Vec<CategoryUsageInfo>,
    pub web_usage: Vec<WebUsageInfo>,
    pub daily_summaries: Vec<ScreenTimeSummary>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct TimeRange {
    pub start: DateTime<Utc>,
    pub end: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SetAppLimitRequest {
    pub bundle_ids: Vec<String>,
    pub time_limit: i64, // seconds per day
    pub days_of_week: Vec<DayOfWeek>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SetDowntimeRequest {
    pub start_time: String, // HH:MM format
    pub end_time: String, // HH:MM format
    pub days_of_week: Vec<DayOfWeek>,
    pub allowed_apps: Vec<String>, // bundle IDs
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ExportFormat {
    pub format: ReportFormat,
    pub include_charts: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum ReportFormat {
    Pdf,
    Csv,
    Json,
}