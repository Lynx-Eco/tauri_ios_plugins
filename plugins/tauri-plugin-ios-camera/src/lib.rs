use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`], [`tauri::WebviewWindow`], [`tauri::Webview`] and [`tauri::Window`] to access the camera APIs.
pub trait CameraExt<R: Runtime> {
    fn camera(&self) -> &Camera<R>;
}

impl<R: Runtime, T: Manager<R>> crate::CameraExt<R> for T {
    fn camera(&self) -> &Camera<R> {
        self.state::<Camera<R>>().inner()
    }
}

/// Access to the camera APIs.
pub struct Camera<R: Runtime>(CameraImpl<R>);

#[cfg(desktop)]
type CameraImpl<R> = desktop::Camera<R>;
#[cfg(mobile)]
type CameraImpl<R> = mobile::Camera<R>;

impl<R: Runtime> Camera<R> {
    pub fn check_permissions(&self) -> Result<CameraPermissions> {
        self.0.check_permissions()
    }

    pub fn request_permissions(&self, permissions: PermissionRequest) -> Result<CameraPermissions> {
        self.0.request_permissions(permissions)
    }

    pub fn take_photo(&self, options: PhotoOptions) -> Result<CaptureResult> {
        self.0.take_photo(options)
    }

    pub fn record_video(&self, options: VideoOptions) -> Result<CaptureResult> {
        self.0.record_video(options)
    }

    pub fn pick_image(&self, options: PickerOptions) -> Result<Vec<MediaItem>> {
        self.0.pick_image(options)
    }

    pub fn pick_video(&self, options: PickerOptions) -> Result<Vec<MediaItem>> {
        self.0.pick_video(options)
    }

    pub fn get_camera_info(&self) -> Result<Vec<CameraInfo>> {
        self.0.get_camera_info()
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-camera")
        .invoke_handler(tauri::generate_handler![
            commands::check_permissions,
            commands::request_permissions,
            commands::take_photo,
            commands::record_video,
            commands::pick_image,
            commands::pick_video,
            commands::pick_media,
            commands::get_camera_info,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let camera = mobile::init(app, api)?;
            #[cfg(desktop)]
            let camera = desktop::init(app, api)?;
            
            app.manage(Camera(camera));
            Ok(())
        })
        .build()
}