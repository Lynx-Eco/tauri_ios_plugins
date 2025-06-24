use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<CallKit<R>> {
    Ok(CallKit(app.clone()))
}

/// Access to the CallKit APIs on desktop (returns errors as not available).
pub struct CallKit<R: Runtime>(AppHandle<R>);

impl<R: Runtime> CallKit<R> {
    pub fn configure_audio_session(&self, _config: AudioSessionConfiguration) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn report_incoming_call(&self, _info: IncomingCallInfo) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn report_outgoing_call(&self, _info: OutgoingCallInfo) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn end_call(&self, _uuid: String, _reason: Option<CallFailureReason>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_held(&self, _uuid: String, _on_hold: bool) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_muted(&self, _uuid: String, _muted: bool) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_group(&self, _uuid: String, _group_uuid: Option<String>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_on_hold(&self, _uuid: String, _on_hold: bool) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_call_audio(&self, _uuid: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn answer_call(&self, _uuid: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn report_call_update(&self, _uuid: String, _update: CallUpdate) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_active_calls(&self) -> Result<Vec<Call>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_call_state(&self, _uuid: String) -> Result<CallState> {
        Err(Error::NotAvailable)
    }
    
    pub fn request_transaction(&self, _transaction: Transaction) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn report_audio_route_change(&self, _route: AudioRoute) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_provider_configuration(&self, _config: ProviderConfiguration) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn register_for_voip_notifications(&self) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn invalidate_push_token(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn report_new_incoming_voip_push(&self, _payload: VoipPushPayload) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn check_call_capability(&self) -> Result<CallCapability> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_audio_routes(&self) -> Result<Vec<AudioRoute>> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_audio_route(&self, _route_type: AudioRouteType) -> Result<()> {
        Err(Error::NotAvailable)
    }
}