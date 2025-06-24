use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_callkit);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<CallKit<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_callkit)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.callkit", "CallKitPlugin")?;
    
    Ok(CallKit(handle))
}

/// Access to the CallKit APIs on mobile.
pub struct CallKit<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> CallKit<R> {
    pub fn configure_audio_session(&self, config: AudioSessionConfiguration) -> Result<()> {
        self.0
            .run_mobile_plugin("configureAudioSession", config)
            .map_err(Into::into)
    }
    
    pub fn report_incoming_call(&self, info: IncomingCallInfo) -> Result<()> {
        self.0
            .run_mobile_plugin("reportIncomingCall", info)
            .map_err(Into::into)
    }
    
    pub fn report_outgoing_call(&self, info: OutgoingCallInfo) -> Result<()> {
        self.0
            .run_mobile_plugin("reportOutgoingCall", info)
            .map_err(Into::into)
    }
    
    pub fn end_call(&self, uuid: String, reason: Option<CallFailureReason>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
            reason: Option<CallFailureReason>,
        }
        
        self.0
            .run_mobile_plugin("endCall", Args { uuid, reason })
            .map_err(Into::into)
    }
    
    pub fn set_held(&self, uuid: String, on_hold: bool) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
            on_hold: bool,
        }
        
        self.0
            .run_mobile_plugin("setHeld", Args { uuid, on_hold })
            .map_err(Into::into)
    }
    
    pub fn set_muted(&self, uuid: String, muted: bool) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
            muted: bool,
        }
        
        self.0
            .run_mobile_plugin("setMuted", Args { uuid, muted })
            .map_err(Into::into)
    }
    
    pub fn set_group(&self, uuid: String, group_uuid: Option<String>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
            group_uuid: Option<String>,
        }
        
        self.0
            .run_mobile_plugin("setGroup", Args { uuid, group_uuid })
            .map_err(Into::into)
    }
    
    pub fn set_on_hold(&self, uuid: String, on_hold: bool) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
            on_hold: bool,
        }
        
        self.0
            .run_mobile_plugin("setOnHold", Args { uuid, on_hold })
            .map_err(Into::into)
    }
    
    pub fn start_call_audio(&self, uuid: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
        }
        
        self.0
            .run_mobile_plugin("startCallAudio", Args { uuid })
            .map_err(Into::into)
    }
    
    pub fn answer_call(&self, uuid: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
        }
        
        self.0
            .run_mobile_plugin("answerCall", Args { uuid })
            .map_err(Into::into)
    }
    
    pub fn report_call_update(&self, uuid: String, update: CallUpdate) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
            update: CallUpdate,
        }
        
        self.0
            .run_mobile_plugin("reportCallUpdate", Args { uuid, update })
            .map_err(Into::into)
    }
    
    pub fn get_active_calls(&self) -> Result<Vec<Call>> {
        self.0
            .run_mobile_plugin("getActiveCalls", ())
            .map_err(Into::into)
    }
    
    pub fn get_call_state(&self, uuid: String) -> Result<CallState> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
        }
        
        self.0
            .run_mobile_plugin("getCallState", Args { uuid })
            .map_err(Into::into)
    }
    
    pub fn request_transaction(&self, transaction: Transaction) -> Result<()> {
        self.0
            .run_mobile_plugin("requestTransaction", transaction)
            .map_err(Into::into)
    }
    
    pub fn report_audio_route_change(&self, route: AudioRoute) -> Result<()> {
        self.0
            .run_mobile_plugin("reportAudioRouteChange", route)
            .map_err(Into::into)
    }
    
    pub fn set_provider_configuration(&self, config: ProviderConfiguration) -> Result<()> {
        self.0
            .run_mobile_plugin("setProviderConfiguration", config)
            .map_err(Into::into)
    }
    
    pub fn register_for_voip_notifications(&self) -> Result<String> {
        self.0
            .run_mobile_plugin("registerForVoipNotifications", ())
            .map_err(Into::into)
    }
    
    pub fn invalidate_push_token(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("invalidatePushToken", ())
            .map_err(Into::into)
    }
    
    pub fn report_new_incoming_voip_push(&self, payload: VoipPushPayload) -> Result<()> {
        self.0
            .run_mobile_plugin("reportNewIncomingVoipPush", payload)
            .map_err(Into::into)
    }
    
    pub fn check_call_capability(&self) -> Result<CallCapability> {
        self.0
            .run_mobile_plugin("checkCallCapability", ())
            .map_err(Into::into)
    }
    
    pub fn get_audio_routes(&self) -> Result<Vec<AudioRoute>> {
        self.0
            .run_mobile_plugin("getAudioRoutes", ())
            .map_err(Into::into)
    }
    
    pub fn set_audio_route(&self, route_type: AudioRouteType) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            route_type: AudioRouteType,
        }
        
        self.0
            .run_mobile_plugin("setAudioRoute", Args { route_type })
            .map_err(Into::into)
    }
}