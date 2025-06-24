use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ProviderConfiguration {
    pub localized_name: String,
    pub ringtone_sound: Option<String>,
    pub icon_template_image: Option<String>, // base64
    pub maximum_call_groups: u32,
    pub maximum_calls_per_group: u32,
    pub supports_video: bool,
    pub include_calls_in_recents: bool,
    pub supported_handle_types: Vec<HandleType>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum HandleType {
    Generic,
    PhoneNumber,
    EmailAddress,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CallHandle {
    pub handle_type: HandleType,
    pub value: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct IncomingCallInfo {
    pub uuid: String,
    pub handle: CallHandle,
    pub has_video: bool,
    pub caller_name: Option<String>,
    pub supports_dtmf: bool,
    pub supports_holding: bool,
    pub supports_grouping: bool,
    pub supports_ungrouping: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct OutgoingCallInfo {
    pub uuid: String,
    pub handle: CallHandle,
    pub has_video: bool,
    pub contact_identifier: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CallUpdate {
    pub remote_handle: Option<CallHandle>,
    pub localized_caller_name: Option<String>,
    pub supports_dtmf: Option<bool>,
    pub supports_holding: Option<bool>,
    pub supports_grouping: Option<bool>,
    pub supports_ungrouping: Option<bool>,
    pub has_video: Option<bool>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Call {
    pub uuid: String,
    pub handle: CallHandle,
    pub outgoing: bool,
    pub has_connected: bool,
    pub has_ended: bool,
    pub on_hold: bool,
    pub is_muted: bool,
    pub start_time: Option<DateTime<Utc>>,
    pub end_time: Option<DateTime<Utc>>,
    pub failure_reason: Option<CallFailureReason>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum CallFailureReason {
    Failed,
    RemoteEnded,
    Unanswered,
    AnsweredElsewhere,
    DeclinedElsewhere,
    CallerFiltered,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum CallState {
    Idle,
    Dialing,
    Incoming,
    Connecting,
    Connected,
    Held,
    Disconnecting,
    Disconnected,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AudioRoute {
    pub name: String,
    pub route_type: AudioRouteType,
    pub is_selected: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum AudioRouteType {
    BuiltInReceiver,
    BuiltInSpeaker,
    Bluetooth,
    BluetoothHfp,
    BluetoothA2dp,
    BluetoothLe,
    CarAudio,
    Wired,
    AirPlay,
    Unknown,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Transaction {
    pub action: TransactionAction,
    pub call_uuid: String,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum TransactionAction {
    Start,
    Answer,
    End,
    SetHeld,
    SetMuted,
    SetGroup,
    PlayDtmf,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CallCapability {
    pub can_make_calls: bool,
    pub can_receive_calls: bool,
    pub supports_video: bool,
    pub supports_voip: bool,
    pub cellular_provider: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct VoipPushPayload {
    pub uuid: String,
    pub handle: String,
    pub has_video: bool,
    pub caller_name: Option<String>,
    pub custom_data: HashMap<String, String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AudioSessionConfiguration {
    pub category: AudioSessionCategory,
    pub mode: AudioSessionMode,
    pub options: Vec<AudioSessionOption>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum AudioSessionCategory {
    Ambient,
    SoloAmbient,
    Playback,
    Record,
    PlayAndRecord,
    MultiRoute,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum AudioSessionMode {
    Default,
    VoiceChat,
    VideoChat,
    GameChat,
    VideoRecording,
    Measurement,
    MoviePlayback,
    SpokenAudio,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum AudioSessionOption {
    MixWithOthers,
    DuckOthers,
    AllowBluetooth,
    DefaultToSpeaker,
    InterruptSpokenAudioAndMixWithOthers,
    AllowBluetoothA2dp,
    AllowAirPlay,
    OverrideMutedMicrophoneInterruption,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CallEvent {
    pub event_type: CallEventType,
    pub call_uuid: String,
    pub timestamp: DateTime<Utc>,
    pub data: Option<serde_json::Value>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum CallEventType {
    IncomingCall,
    OutgoingCall,
    CallAnswered,
    CallEnded,
    CallHeld,
    CallResumed,
    CallMuted,
    CallUnmuted,
    CallFailed,
    AudioRouteChanged,
    DtmfReceived,
}

impl Default for ProviderConfiguration {
    fn default() -> Self {
        Self {
            localized_name: "App".to_string(),
            ringtone_sound: None,
            icon_template_image: None,
            maximum_call_groups: 2,
            maximum_calls_per_group: 5,
            supports_video: true,
            include_calls_in_recents: true,
            supported_handle_types: vec![HandleType::PhoneNumber, HandleType::EmailAddress],
        }
    }
}

impl Default for AudioSessionConfiguration {
    fn default() -> Self {
        Self {
            category: AudioSessionCategory::PlayAndRecord,
            mode: AudioSessionMode::VoiceChat,
            options: vec![
                AudioSessionOption::AllowBluetooth,
                AudioSessionOption::DefaultToSpeaker,
            ],
        }
    }
}