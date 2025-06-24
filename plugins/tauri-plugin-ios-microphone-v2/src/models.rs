use serde::{Deserialize, Serialize};
use tauri::plugin::PermissionState;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionStatus {
    pub microphone: PermissionState,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RecordingOptions {
    pub format: AudioFormat,
    pub quality: AudioQuality,
    pub sample_rate: Option<f64>,
    pub channels: Option<u32>,
    pub bit_rate: Option<u32>,
    pub max_duration: Option<f64>, // seconds
    pub silence_detection: bool,
    pub noise_suppression: bool,
    pub echo_cancellation: bool,
}

impl Default for RecordingOptions {
    fn default() -> Self {
        Self {
            format: AudioFormat::M4A,
            quality: AudioQuality::High,
            sample_rate: None,
            channels: None,
            bit_rate: None,
            max_duration: None,
            silence_detection: false,
            noise_suppression: false,
            echo_cancellation: false,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RecordingSession {
    pub id: String,
    pub start_time: String,
    pub format: AudioFormat,
    pub sample_rate: f64,
    pub channels: u32,
    pub bit_rate: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RecordingResult {
    pub path: String,
    pub duration: f64, // seconds
    pub size: u64, // bytes
    pub format: AudioFormat,
    pub sample_rate: f64,
    pub channels: u32,
    pub bit_rate: u32,
    pub peak_level: f32,
    pub average_level: f32,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum RecordingState {
    Idle,
    Recording,
    Paused,
    Stopping,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AudioLevels {
    pub peak_level: f32, // 0.0 to 1.0
    pub average_level: f32, // 0.0 to 1.0
    pub is_clipping: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AudioInput {
    pub id: String,
    pub name: String,
    pub port_type: PortType,
    pub is_default: bool,
    pub channels: u32,
    pub sample_rate: f64,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum AudioFormat {
    M4A,
    WAV,
    CAF,
    AIFF,
    MP3,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum AudioQuality {
    Low,    // 64 kbps
    Medium, // 128 kbps
    High,   // 256 kbps
    Lossless,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum PortType {
    BuiltInMic,
    HeadsetMic,
    UsbAudio,
    BluetoothHFP,
    CarAudio,
    LineIn,
    Other,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AudioMetrics {
    pub duration: f64,
    pub peak_amplitude: f32,
    pub average_amplitude: f32,
    pub silence_ratio: f32,
    pub clipping_count: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RecordingEvent {
    pub event_type: RecordingEventType,
    pub timestamp: String,
    pub data: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum RecordingEventType {
    Started,
    Paused,
    Resumed,
    Stopped,
    LevelUpdate,
    SilenceDetected,
    Error,
    InputChanged,
}