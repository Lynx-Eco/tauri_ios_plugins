use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Proximity<R>> {
    Ok(Proximity(app.clone()))
}

/// Access to the Proximity APIs on desktop (returns errors as not available).
pub struct Proximity<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Proximity<R> {
    pub fn start_proximity_monitoring(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_proximity_monitoring(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_proximity_state(&self) -> Result<ProximityState> {
        Err(Error::NotAvailable)
    }
    
    pub fn is_proximity_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn enable_proximity_monitoring(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn disable_proximity_monitoring(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_display_auto_lock(&self, _enabled: bool) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_display_auto_lock_state(&self) -> Result<DisplayAutoLockState> {
        Err(Error::NotAvailable)
    }
}