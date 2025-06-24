use serde::{Deserialize, Serialize};
use tauri::plugin::PermissionState;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionStatus {
    pub read: HealthKitPermissions,
    pub write: HealthKitPermissions,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct HealthKitPermissions {
    pub steps: PermissionState,
    pub heart_rate: PermissionState,
    pub active_energy_burned: PermissionState,
    pub distance_walking_running: PermissionState,
    pub flights_climbed: PermissionState,
    pub height: PermissionState,
    pub weight: PermissionState,
    pub body_mass_index: PermissionState,
    pub body_fat_percentage: PermissionState,
    pub sleep_analysis: PermissionState,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionRequest {
    pub read: Vec<HealthKitDataType>,
    pub write: Vec<HealthKitDataType>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum HealthKitDataType {
    Steps,
    HeartRate,
    ActiveEnergyBurned,
    DistanceWalkingRunning,
    FlightsClimbed,
    Height,
    Weight,
    BodyMassIndex,
    BodyFatPercentage,
    SleepAnalysis,
    BiologicalSex,
    DateOfBirth,
    BloodType,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct QuantityQuery {
    pub data_type: HealthKitDataType,
    pub start_date: String,
    pub end_date: String,
    pub limit: Option<u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct QuantitySample {
    pub data_type: HealthKitDataType,
    pub value: f64,
    pub unit: String,
    pub start_date: String,
    pub end_date: String,
    pub metadata: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CategorySample {
    pub data_type: HealthKitDataType,
    pub value: i32,
    pub start_date: String,
    pub end_date: String,
    pub metadata: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct WorkoutSample {
    pub activity_type: WorkoutActivityType,
    pub start_date: String,
    pub end_date: String,
    pub duration: f64,
    pub total_energy_burned: Option<f64>,
    pub total_distance: Option<f64>,
    pub metadata: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum WorkoutActivityType {
    Running,
    Walking,
    Cycling,
    Swimming,
    Yoga,
    Strength,
    Other,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum BiologicalSex {
    NotSet,
    Female,
    Male,
    Other,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum BloodType {
    NotSet,
    APositive,
    ANegative,
    BPositive,
    BNegative,
    ABPositive,
    ABNegative,
    OPositive,
    ONegative,
}