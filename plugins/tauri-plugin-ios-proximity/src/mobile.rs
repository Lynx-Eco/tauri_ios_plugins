use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_proximity);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Proximity<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_proximity)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.proximity", "ProximityPlugin")?;
    
    Ok(Proximity(handle))
}

/// Access to the Proximity APIs on mobile.
pub struct Proximity<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Proximity<R> {
    pub fn start_proximity_monitoring(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startProximityMonitoring", ())
            .map_err(Into::into)
    }
    
    pub fn stop_proximity_monitoring(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopProximityMonitoring", ())
            .map_err(Into::into)
    }
    
    pub fn get_proximity_state(&self) -> Result<ProximityState> {
        self.0
            .run_mobile_plugin("getProximityState", ())
            .map_err(Into::into)
    }
    
    pub fn is_proximity_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isProximityAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn enable_proximity_monitoring(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("enableProximityMonitoring", ())
            .map_err(Into::into)
    }
    
    pub fn disable_proximity_monitoring(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("disableProximityMonitoring", ())
            .map_err(Into::into)
    }
    
    pub fn set_display_auto_lock(&self, enabled: bool) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            enabled: bool,
        }
        
        self.0
            .run_mobile_plugin("setDisplayAutoLock", Args { enabled })
            .map_err(Into::into)
    }
    
    pub fn get_display_auto_lock_state(&self) -> Result<DisplayAutoLockState> {
        self.0
            .run_mobile_plugin("getDisplayAutoLockState", ())
            .map_err(Into::into)
    }
}