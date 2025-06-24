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

/// Extensions to [`tauri::App`], [`tauri::AppHandle`], [`tauri::WebviewWindow`], [`tauri::Webview`] and [`tauri::Window`] to access the photos APIs.
pub trait PhotosExt<R: Runtime> {
    fn photos(&self) -> &Photos<R>;
}

impl<R: Runtime, T: Manager<R>> crate::PhotosExt<R> for T {
    fn photos(&self) -> &Photos<R> {
        self.state::<Photos<R>>().inner()
    }
}

/// Access to the photos APIs.
pub struct Photos<R: Runtime>(PhotosImpl<R>);

#[cfg(desktop)]
type PhotosImpl<R> = desktop::Photos<R>;
#[cfg(mobile)]
type PhotosImpl<R> = mobile::Photos<R>;

impl<R: Runtime> Photos<R> {
    pub fn check_permissions(&self) -> Result<PhotosPermissions> {
        self.0.check_permissions()
    }

    pub fn request_permissions(&self, access_level: AccessLevel) -> Result<PhotosPermissions> {
        self.0.request_permissions(access_level)
    }

    pub fn get_albums(&self, options: AlbumQuery) -> Result<Vec<Album>> {
        self.0.get_albums(options)
    }

    pub fn get_album(&self, id: &str) -> Result<Album> {
        self.0.get_album(id)
    }

    pub fn create_album(&self, title: &str) -> Result<Album> {
        self.0.create_album(title)
    }

    pub fn delete_album(&self, id: &str) -> Result<()> {
        self.0.delete_album(id)
    }

    pub fn get_assets(&self, query: AssetQuery) -> Result<Vec<Asset>> {
        self.0.get_assets(query)
    }

    pub fn get_asset(&self, id: &str) -> Result<Asset> {
        self.0.get_asset(id)
    }

    pub fn delete_assets(&self, ids: Vec<String>) -> Result<()> {
        self.0.delete_assets(ids)
    }

    pub fn save_image(&self, data: SaveImageData) -> Result<String> {
        self.0.save_image(data)
    }

    pub fn save_video(&self, path: &str, to_album: Option<String>) -> Result<String> {
        self.0.save_video(path, to_album)
    }

    pub fn export_asset(&self, id: &str, options: ExportOptions) -> Result<String> {
        self.0.export_asset(id, options)
    }

    pub fn get_asset_metadata(&self, id: &str) -> Result<AssetMetadata> {
        self.0.get_asset_metadata(id)
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-photos")
        .invoke_handler(tauri::generate_handler![
            commands::check_permissions,
            commands::request_permissions,
            commands::get_albums,
            commands::get_album,
            commands::create_album,
            commands::delete_album,
            commands::get_assets,
            commands::get_asset,
            commands::delete_assets,
            commands::save_image,
            commands::save_video,
            commands::export_asset,
            commands::get_asset_metadata,
            commands::search_assets,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let photos = mobile::init(app, api)?;
            #[cfg(desktop)]
            let photos = desktop::init(app, api)?;
            
            app.manage(Photos(photos));
            Ok(())
        })
        .build()
}