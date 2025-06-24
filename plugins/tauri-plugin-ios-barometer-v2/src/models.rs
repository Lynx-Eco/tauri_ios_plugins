use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PressureData {
    pub pressure: f64, // kilopascals (kPa)
    pub relative_altitude: Option<f64>, // meters
    pub temperature: Option<f64>, // celsius
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AltitudeData {
    pub altitude: f64, // meters
    pub pressure: f64, // kilopascals
    pub reference_pressure: f64, // kilopascals
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WeatherData {
    pub pressure: f64, // kilopascals
    pub pressure_trend: PressureTrend,
    pub altitude: Option<f64>, // meters
    pub temperature: Option<f64>, // celsius
    pub humidity: Option<f64>, // percentage
    pub weather_condition: WeatherCondition,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum PressureTrend {
    Rising,
    Falling,
    Steady,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum WeatherCondition {
    Fair,
    Changing,
    Stormy,
    Unknown,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct BarometerCalibration {
    pub reference_pressure: f64, // kilopascals
    pub reference_altitude: f64, // meters
    pub calibration_date: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct BarometerConfiguration {
    pub update_interval: f64, // seconds
    pub use_calibration: bool,
    pub enable_weather_prediction: bool,
    pub altitude_smoothing: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct BarometerEvent {
    pub event_type: BarometerEventType,
    pub data: serde_json::Value,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum BarometerEventType {
    PressureUpdate,
    AltitudeUpdate,
    WeatherChange,
    CalibrationComplete,
    Error,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PressureHistory {
    pub entries: Vec<PressureEntry>,
    pub duration_hours: u32,
    pub average_pressure: f64,
    pub min_pressure: f64,
    pub max_pressure: f64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PressureEntry {
    pub pressure: f64,
    pub timestamp: DateTime<Utc>,
}

impl Default for PressureTrend {
    fn default() -> Self {
        PressureTrend::Steady
    }
}

impl Default for WeatherCondition {
    fn default() -> Self {
        WeatherCondition::Unknown
    }
}

impl Default for BarometerConfiguration {
    fn default() -> Self {
        BarometerConfiguration {
            update_interval: 1.0,
            use_calibration: true,
            enable_weather_prediction: true,
            altitude_smoothing: true,
        }
    }
}