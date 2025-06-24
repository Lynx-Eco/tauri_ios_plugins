use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AccelerometerData {
    pub x: f64,
    pub y: f64,
    pub z: f64,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct GyroscopeData {
    pub x: f64,
    pub y: f64,
    pub z: f64,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MagnetometerData {
    pub x: f64,
    pub y: f64,
    pub z: f64,
    pub accuracy: MagneticFieldAccuracy,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum MagneticFieldAccuracy {
    Uncalibrated,
    Low,
    Medium,
    High,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct DeviceMotionData {
    pub attitude: Attitude,
    pub rotation_rate: RotationRate,
    pub gravity: Vector3D,
    pub user_acceleration: Vector3D,
    pub magnetic_field: Option<CalibratedMagneticField>,
    pub heading: Option<f64>,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Attitude {
    pub roll: f64,
    pub pitch: f64,
    pub yaw: f64,
    pub rotation_matrix: RotationMatrix,
    pub quaternion: Quaternion,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct RotationRate {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Vector3D {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CalibratedMagneticField {
    pub field: Vector3D,
    pub accuracy: MagneticFieldAccuracy,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct RotationMatrix {
    pub m11: f64,
    pub m12: f64,
    pub m13: f64,
    pub m21: f64,
    pub m22: f64,
    pub m23: f64,
    pub m31: f64,
    pub m32: f64,
    pub m33: f64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Quaternion {
    pub x: f64,
    pub y: f64,
    pub z: f64,
    pub w: f64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MotionActivity {
    pub stationary: bool,
    pub walking: bool,
    pub running: bool,
    pub automotive: bool,
    pub cycling: bool,
    pub unknown: bool,
    pub start_date: DateTime<Utc>,
    pub confidence: ActivityConfidence,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum ActivityConfidence {
    Low,
    Medium,
    High,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PedometerData {
    pub start_date: DateTime<Utc>,
    pub end_date: DateTime<Utc>,
    pub number_of_steps: u32,
    pub distance: Option<f64>,
    pub floors_ascended: Option<u32>,
    pub floors_descended: Option<u32>,
    pub current_pace: Option<f64>,
    pub current_cadence: Option<f64>,
    pub average_active_pace: Option<f64>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AltimeterData {
    pub relative_altitude: f64,
    pub pressure: f64,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MotionUpdateInterval {
    pub accelerometer: Option<f64>,
    pub gyroscope: Option<f64>,
    pub magnetometer: Option<f64>,
    pub device_motion: Option<f64>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MotionAvailability {
    pub accelerometer: bool,
    pub gyroscope: bool,
    pub magnetometer: bool,
    pub device_motion: bool,
    pub activity: bool,
    pub pedometer: bool,
    pub step_counting: bool,
    pub distance: bool,
    pub floor_counting: bool,
    pub altimeter: bool,
    pub relative_altitude: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MotionEvent {
    pub event_type: MotionEventType,
    pub data: serde_json::Value,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum MotionEventType {
    AccelerometerUpdate,
    GyroscopeUpdate,
    MagnetometerUpdate,
    DeviceMotionUpdate,
    ActivityUpdate,
    PedometerUpdate,
    AltimeterUpdate,
    Error,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ActivityQuery {
    pub start_date: DateTime<Utc>,
    pub end_date: DateTime<Utc>,
}

impl Default for MagneticFieldAccuracy {
    fn default() -> Self {
        MagneticFieldAccuracy::Uncalibrated
    }
}

impl Default for ActivityConfidence {
    fn default() -> Self {
        ActivityConfidence::Low
    }
}