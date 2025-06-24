use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct KeychainItem {
    pub key: String,
    pub value: String,
    pub service: Option<String>,
    pub account: Option<String>,
    pub access_group: Option<String>,
    pub accessible: Accessible,
    pub synchronizable: bool,
    pub label: Option<String>,
    pub comment: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct KeychainQuery {
    pub key: String,
    pub service: Option<String>,
    pub account: Option<String>,
    pub access_group: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct KeychainUpdate {
    pub value: Option<String>,
    pub accessible: Option<Accessible>,
    pub synchronizable: Option<bool>,
    pub label: Option<String>,
    pub comment: Option<String>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum Accessible {
    WhenUnlocked,
    AfterFirstUnlock,
    WhenUnlockedThisDeviceOnly,
    AfterFirstUnlockThisDeviceOnly,
    WhenPasscodeSetThisDeviceOnly,
}

impl Default for Accessible {
    fn default() -> Self {
        Self::WhenUnlocked
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SecureKeychainItem {
    pub key: String,
    pub value: SecureValue,
    pub service: Option<String>,
    pub access_group: Option<String>,
    pub authentication: AuthenticationPolicy,
    pub accessible: Accessible,
    pub validity_duration: Option<u32>, // seconds
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum SecureValue {
    Password(String),
    Data(String), // Base64 encoded
    Certificate(String), // Base64 encoded
    Key(String), // Base64 encoded
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SecureKeychainQuery {
    pub key: String,
    pub service: Option<String>,
    pub access_group: Option<String>,
    pub authentication_prompt: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthenticationPolicy {
    pub biometry_any: bool,
    pub biometry_current_set: bool,
    pub device_passcode: bool,
    pub user_presence: bool,
    pub application_password: Option<String>,
}

impl Default for AuthenticationPolicy {
    fn default() -> Self {
        Self {
            biometry_any: false,
            biometry_current_set: false,
            device_passcode: true,
            user_presence: true,
            application_password: None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InternetPasswordItem {
    pub server: String,
    pub account: String,
    pub password: String,
    pub port: Option<u16>,
    pub protocol: Option<InternetProtocol>,
    pub authentication_type: Option<AuthenticationType>,
    pub security_domain: Option<String>,
    pub accessible: Accessible,
    pub synchronizable: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InternetPasswordQuery {
    pub server: String,
    pub account: Option<String>,
    pub port: Option<u16>,
    pub protocol: Option<InternetProtocol>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum InternetProtocol {
    Http,
    Https,
    Ftp,
    Ftps,
    Smtp,
    Pop3,
    Imap,
    Ldap,
    Ssh,
    Telnet,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum AuthenticationType {
    Default,
    HttpBasic,
    HttpDigest,
    HtmlForm,
    Ntlm,
    Negotiate,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PasswordOptions {
    pub length: u32,
    pub include_uppercase: bool,
    pub include_lowercase: bool,
    pub include_numbers: bool,
    pub include_symbols: bool,
    pub exclude_ambiguous: bool,
    pub custom_characters: Option<String>,
}

impl Default for PasswordOptions {
    fn default() -> Self {
        Self {
            length: 16,
            include_uppercase: true,
            include_lowercase: true,
            include_numbers: true,
            include_symbols: true,
            exclude_ambiguous: true,
            custom_characters: None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthenticationResult {
    pub success: bool,
    pub biometry_type: Option<BiometryType>,
    pub error: Option<String>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum BiometryType {
    None,
    TouchId,
    FaceId,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct KeychainStatus {
    pub is_available: bool,
    pub is_locked: bool,
    pub biometry_available: bool,
    pub biometry_type: BiometryType,
    pub access_groups: Vec<String>,
}