use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum AuthorizationStatus {
    NotDetermined,
    Restricted,
    Denied,
    Authorized,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum BluetoothState {
    Unknown,
    Resetting,
    Unsupported,
    Unauthorized,
    PoweredOff,
    PoweredOn,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ScanOptions {
    pub service_uuids: Vec<String>,
    pub allow_duplicates: bool,
    pub scan_mode: ScanMode,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum ScanMode {
    LowPower,
    Balanced,
    LowLatency,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Peripheral {
    pub uuid: String,
    pub name: Option<String>,
    pub rssi: i32,
    pub is_connectable: bool,
    pub state: PeripheralState,
    pub services: Vec<String>, // Service UUIDs
    pub manufacturer_data: Option<HashMap<u16, Vec<u8>>>,
    pub service_data: Option<HashMap<String, Vec<u8>>>,
    pub tx_power_level: Option<i32>,
    pub solicited_service_uuids: Vec<String>,
    pub overflow_service_uuids: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum PeripheralState {
    Disconnected,
    Connecting,
    Connected,
    Disconnecting,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Service {
    pub uuid: String,
    pub is_primary: bool,
    pub characteristics: Vec<String>, // Characteristic UUIDs
    pub included_services: Vec<String>, // Service UUIDs
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Characteristic {
    pub uuid: String,
    pub service_uuid: String,
    pub properties: CharacteristicProperties,
    pub value: Option<Vec<u8>>,
    pub descriptors: Vec<String>, // Descriptor UUIDs
    pub is_notifying: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CharacteristicProperties {
    pub broadcast: bool,
    pub read: bool,
    pub write_without_response: bool,
    pub write: bool,
    pub notify: bool,
    pub indicate: bool,
    pub authenticated_signed_writes: bool,
    pub extended_properties: bool,
    pub notify_encryption_required: bool,
    pub indicate_encryption_required: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Descriptor {
    pub uuid: String,
    pub characteristic_uuid: String,
    pub value: Option<Vec<u8>>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WriteOptions {
    pub with_response: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum WriteType {
    WithResponse,
    WithoutResponse,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ConnectionOptions {
    pub auto_connect: bool,
    pub timeout_ms: Option<u32>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AdvertisingData {
    pub local_name: Option<String>,
    pub service_uuids: Vec<String>,
    pub manufacturer_data: Option<HashMap<u16, Vec<u8>>>,
    pub service_data: Option<HashMap<String, Vec<u8>>>,
    pub tx_power_level: Option<i32>,
    pub is_connectable: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PeripheralService {
    pub uuid: String,
    pub is_primary: bool,
    pub characteristics: Vec<PeripheralCharacteristic>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PeripheralCharacteristic {
    pub uuid: String,
    pub properties: CharacteristicProperties,
    pub permissions: CharacteristicPermissions,
    pub value: Option<Vec<u8>>,
    pub descriptors: Vec<PeripheralDescriptor>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CharacteristicPermissions {
    pub readable: bool,
    pub writeable: bool,
    pub read_encryption_required: bool,
    pub write_encryption_required: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PeripheralDescriptor {
    pub uuid: String,
    pub value: Option<Vec<u8>>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ReadRequest {
    pub central_uuid: String,
    pub characteristic_uuid: String,
    pub offset: usize,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WriteRequest {
    pub central_uuid: String,
    pub characteristic_uuid: String,
    pub value: Vec<u8>,
    pub offset: usize,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct RequestResponse {
    pub request_id: String,
    pub result: RequestResult,
    pub value: Option<Vec<u8>>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum RequestResult {
    Success,
    InvalidHandle,
    ReadNotPermitted,
    WriteNotPermitted,
    InvalidPdu,
    InsufficientAuthentication,
    RequestNotSupported,
    InvalidOffset,
    InsufficientAuthorization,
    PrepareQueueFull,
    AttributeNotFound,
    AttributeNotLong,
    InsufficientEncryptionKeySize,
    InvalidAttributeValueLength,
    UnlikelyError,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct BluetoothEvent {
    pub event_type: BluetoothEventType,
    pub timestamp: DateTime<Utc>,
    pub data: serde_json::Value,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum BluetoothEventType {
    StateChanged,
    PeripheralDiscovered,
    PeripheralConnected,
    PeripheralDisconnected,
    ServiceDiscovered,
    CharacteristicDiscovered,
    CharacteristicValueUpdated,
    CharacteristicSubscriptionChanged,
    DescriptorValueUpdated,
    CentralSubscribed,
    CentralUnsubscribed,
    ReadRequestReceived,
    WriteRequestReceived,
}

impl Default for ScanOptions {
    fn default() -> Self {
        Self {
            service_uuids: vec![],
            allow_duplicates: false,
            scan_mode: ScanMode::Balanced,
        }
    }
}

impl Default for ConnectionOptions {
    fn default() -> Self {
        Self {
            auto_connect: false,
            timeout_ms: Some(30000), // 30 seconds
        }
    }
}

impl Default for WriteOptions {
    fn default() -> Self {
        Self {
            with_response: true,
        }
    }
}

impl Default for CharacteristicProperties {
    fn default() -> Self {
        Self {
            broadcast: false,
            read: false,
            write_without_response: false,
            write: false,
            notify: false,
            indicate: false,
            authenticated_signed_writes: false,
            extended_properties: false,
            notify_encryption_required: false,
            indicate_encryption_required: false,
        }
    }
}

impl Default for CharacteristicPermissions {
    fn default() -> Self {
        Self {
            readable: false,
            writeable: false,
            read_encryption_required: false,
            write_encryption_required: false,
        }
    }
}