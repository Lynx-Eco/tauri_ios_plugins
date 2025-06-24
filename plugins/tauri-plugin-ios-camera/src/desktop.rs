use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Camera<R>> {
    Ok(Camera(app.clone()))
}

/// Access to the camera APIs on desktop (returns errors as not available).
pub struct Camera<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Camera<R> {
    pub fn check_permissions(&self) -> Result<CameraPermissions> {
        Err(Error::NotAvailable)
    }

    pub fn request_permissions(&self, _permissions: PermissionRequest) -> Result<CameraPermissions> {
        Err(Error::NotAvailable)
    }

    pub fn take_photo(&self, _options: PhotoOptions) -> Result<CaptureResult> {
        Err(Error::NotAvailable)
    }

    pub fn record_video(&self, _options: VideoOptions) -> Result<CaptureResult> {
        Err(Error::NotAvailable)
    }

    pub fn pick_image(&self, _options: PickerOptions) -> Result<Vec<MediaItem>> {
        Err(Error::NotAvailable)
    }

    pub fn pick_video(&self, _options: PickerOptions) -> Result<Vec<MediaItem>> {
        Err(Error::NotAvailable)
    }

    pub fn get_camera_info(&self) -> Result<Vec<CameraInfo>> {
        Err(Error::NotAvailable)
    }
}