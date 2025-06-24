use tauri::{command, AppHandle, Runtime};

use crate::{CameraExt, CameraPermissions, PermissionRequest, PhotoOptions, VideoOptions, PickerOptions, CaptureResult, MediaItem, CameraInfo, MediaType, Result};

#[command]
pub(crate) async fn check_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<CameraPermissions> {
    app.camera().check_permissions()
}

#[command]
pub(crate) async fn request_permissions<R: Runtime>(
    app: AppHandle<R>,
    permissions: PermissionRequest,
) -> Result<CameraPermissions> {
    app.camera().request_permissions(permissions)
}

#[command]
pub(crate) async fn take_photo<R: Runtime>(
    app: AppHandle<R>,
    options: Option<PhotoOptions>,
) -> Result<CaptureResult> {
    app.camera().take_photo(options.unwrap_or_default())
}

#[command]
pub(crate) async fn record_video<R: Runtime>(
    app: AppHandle<R>,
    options: Option<VideoOptions>,
) -> Result<CaptureResult> {
    app.camera().record_video(options.unwrap_or_default())
}

#[command]
pub(crate) async fn pick_image<R: Runtime>(
    app: AppHandle<R>,
    options: Option<PickerOptions>,
) -> Result<Vec<MediaItem>> {
    app.camera().pick_image(options.unwrap_or_default())
}

#[command]
pub(crate) async fn pick_video<R: Runtime>(
    app: AppHandle<R>,
    options: Option<PickerOptions>,
) -> Result<Vec<MediaItem>> {
    app.camera().pick_video(options.unwrap_or_default())
}

#[command]
pub(crate) async fn pick_media<R: Runtime>(
    app: AppHandle<R>,
    mut options: Option<PickerOptions>,
) -> Result<Vec<MediaItem>> {
    let mut opts = options.take().unwrap_or_default();
    opts.media_types = vec![MediaType::Any];
    app.camera().pick_image(opts)
}

#[command]
pub(crate) async fn get_camera_info<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<CameraInfo>> {
    app.camera().get_camera_info()
}