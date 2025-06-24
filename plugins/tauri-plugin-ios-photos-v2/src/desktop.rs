use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Photos<R>> {
    Ok(Photos(app.clone()))
}

/// Access to the photos APIs on desktop (returns errors as not available).
pub struct Photos<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Photos<R> {
    pub fn check_permissions(&self) -> Result<PhotosPermissions> {
        Err(Error::PermissionDenied)
    }

    pub fn request_permissions(&self, _access_level: AccessLevel) -> Result<PhotosPermissions> {
        Err(Error::PermissionDenied)
    }

    pub fn get_albums(&self, _options: AlbumQuery) -> Result<Vec<Album>> {
        Err(Error::PermissionDenied)
    }

    pub fn get_album(&self, _id: &str) -> Result<Album> {
        Err(Error::OperationFailed("Album not found".to_string()))
    }

    pub fn create_album(&self, _title: &str) -> Result<Album> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn delete_album(&self, _id: &str) -> Result<()> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn get_assets(&self, _query: AssetQuery) -> Result<Vec<Asset>> {
        Err(Error::PermissionDenied)
    }

    pub fn get_asset(&self, _id: &str) -> Result<Asset> {
        Err(Error::OperationFailed("Asset not found".to_string()))
    }

    pub fn delete_assets(&self, _ids: Vec<String>) -> Result<()> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn save_image(&self, _data: SaveImageData) -> Result<String> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn save_video(&self, _path: &str, _to_album: Option<String>) -> Result<String> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn export_asset(&self, _id: &str, _options: ExportOptions) -> Result<String> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn get_asset_metadata(&self, _id: &str) -> Result<AssetMetadata> {
        Err(Error::OperationFailed("Asset not found".to_string()))
    }
}