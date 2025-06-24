use serde::{Deserialize, Serialize};
use tauri::plugin::PermissionState;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LocationPermissions {
    pub when_in_use: PermissionState,
    pub always: PermissionState,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionRequest {
    pub accuracy: LocationAccuracy,
    pub background: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LocationOptions {
    pub accuracy: LocationAccuracy,
    pub distance_filter: Option<f64>, // meters
    pub timeout: Option<u32>, // milliseconds
    pub maximum_age: Option<u32>, // milliseconds
    pub enable_high_accuracy: bool,
    pub show_background_location_indicator: bool,
}

impl Default for LocationOptions {
    fn default() -> Self {
        Self {
            accuracy: LocationAccuracy::Best,
            distance_filter: None,
            timeout: Some(30000),
            maximum_age: Some(0),
            enable_high_accuracy: true,
            show_background_location_indicator: true,
        }
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum LocationAccuracy {
    Best,
    BestForNavigation,
    NearestTenMeters,
    HundredMeters,
    Kilometer,
    ThreeKilometers,
    Reduced,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LocationData {
    pub coordinates: Coordinates,
    pub altitude: Option<f64>,
    pub accuracy: f64,
    pub altitude_accuracy: Option<f64>,
    pub heading: Option<f64>,
    pub speed: Option<f64>,
    pub timestamp: String,
    pub floor: Option<Floor>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Coordinates {
    pub latitude: f64,
    pub longitude: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Floor {
    pub level: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Region {
    pub identifier: String,
    pub center: Coordinates,
    pub radius: f64, // meters
    pub notify_on_entry: bool,
    pub notify_on_exit: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Heading {
    pub magnetic_heading: f64,
    pub true_heading: f64,
    pub heading_accuracy: f64,
    pub timestamp: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GeocodingResult {
    pub coordinates: Coordinates,
    pub placemark: Placemark,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Placemark {
    pub name: Option<String>,
    pub thoroughfare: Option<String>,
    pub sub_thoroughfare: Option<String>,
    pub locality: Option<String>,
    pub sub_locality: Option<String>,
    pub administrative_area: Option<String>,
    pub sub_administrative_area: Option<String>,
    pub postal_code: Option<String>,
    pub iso_country_code: Option<String>,
    pub country: Option<String>,
    pub inland_water: Option<String>,
    pub ocean: Option<String>,
    pub areas_of_interest: Vec<String>,
    pub formatted_address: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LocationEvent {
    pub event_type: LocationEventType,
    pub data: serde_json::Value,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum LocationEventType {
    LocationUpdate,
    HeadingUpdate,
    RegionEntered,
    RegionExited,
    AuthorizationChanged,
    Error,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DistanceRequest {
    pub from: Coordinates,
    pub to: Coordinates,
}