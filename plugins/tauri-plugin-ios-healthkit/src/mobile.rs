use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_healthkit);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<HealthKit<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_healthkit)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.healthkit", "HealthKitPlugin")?;
    
    Ok(HealthKit(handle))
}

/// Access to the healthkit APIs on mobile.
pub struct HealthKit<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> HealthKit<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        self.0
            .run_mobile_plugin("checkPermissions", ())
            .map_err(Into::into)
    }

    pub fn request_permissions(&self, permissions: PermissionRequest) -> Result<PermissionStatus> {
        self.0
            .run_mobile_plugin("requestPermissions", permissions)
            .map_err(Into::into)
    }

    pub fn query_quantity_samples(&self, query: QuantityQuery) -> Result<Vec<QuantitySample>> {
        self.0
            .run_mobile_plugin("queryQuantitySamples", query)
            .map_err(Into::into)
    }

    pub fn write_quantity_sample(&self, sample: QuantitySample) -> Result<()> {
        self.0
            .run_mobile_plugin("writeQuantitySample", sample)
            .map_err(Into::into)
    }
}