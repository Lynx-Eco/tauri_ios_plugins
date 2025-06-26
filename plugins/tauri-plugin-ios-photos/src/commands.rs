use tauri::{command, AppHandle, Runtime};

use crate::{PhotosExt, PhotosPermissions, AccessLevel, Album, AlbumQuery, Asset, AssetQuery, SaveImageData, ExportOptions, AssetMetadata, SearchQuery, Result};

#[command]
pub(crate) async fn check_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<PhotosPermissions> {
    app.photos().check_permissions()
}

#[command]
pub(crate) async fn request_permissions<R: Runtime>(
    app: AppHandle<R>,
    access_level: AccessLevel,
) -> Result<PhotosPermissions> {
    app.photos().request_permissions(access_level)
}

#[command]
pub(crate) async fn get_albums<R: Runtime>(
    app: AppHandle<R>,
    options: Option<AlbumQuery>,
) -> Result<Vec<Album>> {
    app.photos().get_albums(options.unwrap_or_default())
}

#[command]
pub(crate) async fn get_album<R: Runtime>(
    app: AppHandle<R>,
    id: String,
) -> Result<Album> {
    app.photos().get_album(&id)
}

#[command]
pub(crate) async fn create_album<R: Runtime>(
    app: AppHandle<R>,
    title: String,
) -> Result<Album> {
    app.photos().create_album(&title)
}

#[command]
pub(crate) async fn delete_album<R: Runtime>(
    app: AppHandle<R>,
    id: String,
) -> Result<()> {
    app.photos().delete_album(&id)
}

#[command]
pub(crate) async fn get_assets<R: Runtime>(
    app: AppHandle<R>,
    query: Option<AssetQuery>,
) -> Result<Vec<Asset>> {
    app.photos().get_assets(query.unwrap_or_default())
}

#[command]
pub(crate) async fn get_asset<R: Runtime>(
    app: AppHandle<R>,
    id: String,
) -> Result<Asset> {
    app.photos().get_asset(&id)
}

#[command]
pub(crate) async fn delete_assets<R: Runtime>(
    app: AppHandle<R>,
    ids: Vec<String>,
) -> Result<()> {
    app.photos().delete_assets(ids)
}

#[command]
pub(crate) async fn save_image<R: Runtime>(
    app: AppHandle<R>,
    data: SaveImageData,
) -> Result<String> {
    app.photos().save_image(data)
}

#[command]
pub(crate) async fn save_video<R: Runtime>(
    app: AppHandle<R>,
    path: String,
    to_album: Option<String>,
) -> Result<String> {
    app.photos().save_video(&path, to_album)
}

#[command]
pub(crate) async fn export_asset<R: Runtime>(
    app: AppHandle<R>,
    id: String,
    options: Option<ExportOptions>,
) -> Result<String> {
    app.photos().export_asset(&id, options.unwrap_or_default())
}

#[command]
pub(crate) async fn get_asset_metadata<R: Runtime>(
    app: AppHandle<R>,
    id: String,
) -> Result<AssetMetadata> {
    app.photos().get_asset_metadata(&id)
}

#[command]
pub(crate) async fn search_assets<R: Runtime>(
    _app: AppHandle<R>,
    _query: SearchQuery,
) -> Result<Vec<Asset>> {
    // This would need implementation
    Ok(vec![])
}