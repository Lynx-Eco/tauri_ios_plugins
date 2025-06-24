use serde::{ser::Serializer, Serialize};

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error(transparent)]
    Tauri(#[from] tauri::Error),
    
    #[error("Photos is not available on this device")]
    NotAvailable,
    
    #[error("Photos permission denied")]
    PermissionDenied,
    
    #[error("Invalid input: {0}")]
    InvalidInput(String),
    
    #[error("Operation failed: {0}")]
    OperationFailed(String),
    
    #[cfg(mobile)]
    #[error(transparent)]
    PluginInvoke(#[from] tauri::plugin::mobile::PluginInvokeError),
}

impl Serialize for Error {
    fn serialize<S>(&self, serializer: S) -> std::result::Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(self.to_string().as_ref())
    }
}
