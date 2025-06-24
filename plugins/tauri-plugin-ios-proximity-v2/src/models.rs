use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ProximityState {
    pub is_close: bool,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ProximityConfiguration {
    pub enabled: bool,
    pub auto_lock_display: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ProximityEvent {
    pub event_type: ProximityEventType,
    pub state: ProximityState,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum ProximityEventType {
    ProximityDetected,
    ProximityCleared,
    MonitoringStarted,
    MonitoringStopped,
    Error,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ProximityStatistics {
    pub total_detections: u32,
    pub current_session_detections: u32,
    pub last_detection: Option<DateTime<Utc>>,
    pub average_proximity_duration: Option<f64>, // seconds
    pub monitoring_duration: f64, // seconds
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct DisplayAutoLockState {
    pub enabled: bool,
    pub proximity_monitoring_enabled: bool,
}

impl Default for ProximityConfiguration {
    fn default() -> Self {
        ProximityConfiguration {
            enabled: false,
            auto_lock_display: true,
        }
    }
}