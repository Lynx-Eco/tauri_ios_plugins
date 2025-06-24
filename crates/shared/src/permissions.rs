use serde::{Deserialize, Serialize};

/// Standard permission states used across all iOS plugins
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum PermissionState {
    /// Permission has not been requested yet
    Prompt,
    /// Permission has been granted
    Granted,
    /// Permission has been denied
    Denied,
    /// Permission is restricted by system policies
    Restricted,
    /// Permission state cannot be determined
    Unknown,
}

impl Default for PermissionState {
    fn default() -> Self {
        Self::Prompt
    }
}

impl PermissionState {
    pub fn is_granted(&self) -> bool {
        matches!(self, Self::Granted)
    }
    
    pub fn is_denied(&self) -> bool {
        matches!(self, Self::Denied | Self::Restricted)
    }
    
    pub fn needs_request(&self) -> bool {
        matches!(self, Self::Prompt)
    }
}

/// Common structure for permission requests
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionRequest {
    /// Reason for requesting the permission (shown to user)
    pub reason: Option<String>,
    /// Whether to show rationale before requesting
    pub show_rationale: bool,
}

impl Default for PermissionRequest {
    fn default() -> Self {
        Self {
            reason: None,
            show_rationale: false,
        }
    }
}

/// Result of a permission request
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionResult {
    pub state: PermissionState,
    pub message: Option<String>,
}

impl PermissionResult {
    pub fn granted() -> Self {
        Self {
            state: PermissionState::Granted,
            message: None,
        }
    }
    
    pub fn denied(message: impl Into<String>) -> Self {
        Self {
            state: PermissionState::Denied,
            message: Some(message.into()),
        }
    }
}