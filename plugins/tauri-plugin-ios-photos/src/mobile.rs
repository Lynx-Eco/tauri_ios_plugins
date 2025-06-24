use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_photos);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Photos<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_photos)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.photos", "PhotosPlugin")?;
    
    Ok(Photos(handle))
}

/// Access to the photos APIs on mobile.
pub struct Photos<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Photos<R> {
    pub fn check_permissions(&self) -> Result<PhotosPermissions> {
        self.0
            .run_mobile_plugin("checkPermissions", ())
            .map_err(Into::into)
    }

    pub fn request_permissions(&self, access_level: AccessLevel) -> Result<PhotosPermissions> {
        #[derive(serde::Serialize)]
        struct PermissionArgs {
            access_level: AccessLevel,
        }
        
        self.0
            .run_mobile_plugin("requestPermissions", PermissionArgs { access_level })
            .map_err(Into::into)
    }

    pub fn get_albums(&self, options: AlbumQuery) -> Result<Vec<Album>> {
        self.0
            .run_mobile_plugin("getAlbums", options)
            .map_err(Into::into)
    }

    pub fn get_album(&self, id: &str) -> Result<Album> {
        #[derive(serde::Serialize)]
        struct GetAlbumArgs<'a> {
            id: &'a str,
        }
        
        self.0
            .run_mobile_plugin("getAlbum", GetAlbumArgs { id })
            .map_err(Into::into)
    }

    pub fn create_album(&self, title: &str) -> Result<Album> {
        #[derive(serde::Serialize)]
        struct CreateAlbumArgs<'a> {
            title: &'a str,
        }
        
        self.0
            .run_mobile_plugin("createAlbum", CreateAlbumArgs { title })
            .map_err(Into::into)
    }

    pub fn delete_album(&self, id: &str) -> Result<()> {
        #[derive(serde::Serialize)]
        struct DeleteAlbumArgs<'a> {
            id: &'a str,
        }
        
        self.0
            .run_mobile_plugin("deleteAlbum", DeleteAlbumArgs { id })
            .map_err(Into::into)
    }

    pub fn get_assets(&self, query: AssetQuery) -> Result<Vec<Asset>> {
        self.0
            .run_mobile_plugin("getAssets", query)
            .map_err(Into::into)
    }

    pub fn get_asset(&self, id: &str) -> Result<Asset> {
        #[derive(serde::Serialize)]
        struct GetAssetArgs<'a> {
            id: &'a str,
        }
        
        self.0
            .run_mobile_plugin("getAsset", GetAssetArgs { id })
            .map_err(Into::into)
    }

    pub fn delete_assets(&self, ids: Vec<String>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct DeleteAssetsArgs {
            ids: Vec<String>,
        }
        
        self.0
            .run_mobile_plugin("deleteAssets", DeleteAssetsArgs { ids })
            .map_err(Into::into)
    }

    pub fn save_image(&self, data: SaveImageData) -> Result<String> {
        self.0
            .run_mobile_plugin("saveImage", data)
            .map_err(Into::into)
    }

    pub fn save_video(&self, path: &str, to_album: Option<String>) -> Result<String> {
        #[derive(serde::Serialize)]
        struct SaveVideoArgs<'a> {
            path: &'a str,
            to_album: Option<String>,
        }
        
        self.0
            .run_mobile_plugin("saveVideo", SaveVideoArgs { path, to_album })
            .map_err(Into::into)
    }

    pub fn export_asset(&self, id: &str, options: ExportOptions) -> Result<String> {
        #[derive(serde::Serialize)]
        struct ExportArgs<'a> {
            id: &'a str,
            options: ExportOptions,
        }
        
        self.0
            .run_mobile_plugin("exportAsset", ExportArgs { id, options })
            .map_err(Into::into)
    }

    pub fn get_asset_metadata(&self, id: &str) -> Result<AssetMetadata> {
        #[derive(serde::Serialize)]
        struct GetMetadataArgs<'a> {
            id: &'a str,
        }
        
        self.0
            .run_mobile_plugin("getAssetMetadata", GetMetadataArgs { id })
            .map_err(Into::into)
    }
}