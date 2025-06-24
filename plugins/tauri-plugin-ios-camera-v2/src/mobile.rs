use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_camera);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Camera<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_camera)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.camera", "CameraPlugin")?;
    
    Ok(Camera(handle))
}

/// Access to the camera APIs on mobile.
pub struct Camera<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Camera<R> {
    pub fn check_permissions(&self) -> Result<CameraPermissions> {
        self.0
            .run_mobile_plugin("checkPermissions", ())
            .map_err(Into::into)
    }

    pub fn request_permissions(&self, permissions: PermissionRequest) -> Result<CameraPermissions> {
        self.0
            .run_mobile_plugin("requestPermissions", permissions)
            .map_err(Into::into)
    }

    pub fn take_photo(&self, options: PhotoOptions) -> Result<CaptureResult> {
        self.0
            .run_mobile_plugin("takePhoto", options)
            .map_err(Into::into)
    }

    pub fn record_video(&self, options: VideoOptions) -> Result<CaptureResult> {
        self.0
            .run_mobile_plugin("recordVideo", options)
            .map_err(Into::into)
    }

    pub fn pick_image(&self, options: PickerOptions) -> Result<Vec<MediaItem>> {
        self.0
            .run_mobile_plugin("pickImage", options)
            .map_err(Into::into)
    }

    pub fn pick_video(&self, options: PickerOptions) -> Result<Vec<MediaItem>> {
        self.0
            .run_mobile_plugin("pickVideo", options)
            .map_err(Into::into)
    }

    pub fn get_camera_info(&self) -> Result<Vec<CameraInfo>> {
        self.0
            .run_mobile_plugin("getCameraInfo", ())
            .map_err(Into::into)
    }
}