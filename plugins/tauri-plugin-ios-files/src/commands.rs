use tauri::{command, AppHandle, Runtime};

use crate::{FilesExt, FilePickerOptions, SaveFileOptions, ImportOptions, ExportOptions, ListOptions, FileData, FileOperation, ShareOptions, PreviewOptions, MonitoringOptions, Result};

#[command]
pub(crate) async fn pick_file<R: Runtime>(
    app: AppHandle<R>,
    options: FilePickerOptions,
) -> Result<crate::PickedFile> {
    app.files().pick_file(options)
}

#[command]
pub(crate) async fn pick_multiple_files<R: Runtime>(
    app: AppHandle<R>,
    options: FilePickerOptions,
) -> Result<Vec<crate::PickedFile>> {
    app.files().pick_multiple_files(options)
}

#[command]
pub(crate) async fn pick_folder<R: Runtime>(
    app: AppHandle<R>,
) -> Result<crate::PickedFile> {
    app.files().pick_folder()
}

#[command]
pub(crate) async fn save_file<R: Runtime>(
    app: AppHandle<R>,
    options: SaveFileOptions,
) -> Result<String> {
    app.files().save_file(options)
}

#[command]
pub(crate) async fn open_in_files<R: Runtime>(
    app: AppHandle<R>,
    url: String,
) -> Result<()> {
    app.files().open_in_files(url)
}

#[command]
pub(crate) async fn import_from_files<R: Runtime>(
    app: AppHandle<R>,
    options: ImportOptions,
) -> Result<Vec<crate::PickedFile>> {
    app.files().import_from_files(options)
}

#[command]
pub(crate) async fn export_to_files<R: Runtime>(
    app: AppHandle<R>,
    options: ExportOptions,
) -> Result<()> {
    app.files().export_to_files(options)
}

#[command]
pub(crate) async fn list_documents<R: Runtime>(
    app: AppHandle<R>,
    options: Option<ListOptions>,
) -> Result<Vec<crate::DocumentInfo>> {
    app.files().list_documents(options.unwrap_or_default())
}

#[command]
pub(crate) async fn read_file<R: Runtime>(
    app: AppHandle<R>,
    url: String,
) -> Result<FileData> {
    app.files().read_file(url)
}

#[command]
pub(crate) async fn write_file<R: Runtime>(
    app: AppHandle<R>,
    url: String,
    data: FileData,
) -> Result<()> {
    app.files().write_file(url, data)
}

#[command]
pub(crate) async fn delete_file<R: Runtime>(
    app: AppHandle<R>,
    url: String,
) -> Result<()> {
    app.files().delete_file(url)
}

#[command]
pub(crate) async fn move_file<R: Runtime>(
    app: AppHandle<R>,
    operation: FileOperation,
) -> Result<String> {
    app.files().move_file(operation)
}

#[command]
pub(crate) async fn copy_file<R: Runtime>(
    app: AppHandle<R>,
    operation: FileOperation,
) -> Result<String> {
    app.files().copy_file(operation)
}

#[command]
pub(crate) async fn create_folder<R: Runtime>(
    app: AppHandle<R>,
    url: String,
    name: String,
) -> Result<String> {
    app.files().create_folder(url, name)
}

#[command]
pub(crate) async fn get_file_info<R: Runtime>(
    app: AppHandle<R>,
    url: String,
) -> Result<crate::DocumentInfo> {
    app.files().get_file_info(url)
}

#[command]
pub(crate) async fn share_file<R: Runtime>(
    app: AppHandle<R>,
    options: ShareOptions,
) -> Result<()> {
    app.files().share_file(options)
}

#[command]
pub(crate) async fn preview_file<R: Runtime>(
    app: AppHandle<R>,
    options: PreviewOptions,
) -> Result<()> {
    app.files().preview_file(options)
}

#[command]
pub(crate) async fn get_cloud_status<R: Runtime>(
    app: AppHandle<R>,
    url: String,
) -> Result<crate::CloudStatus> {
    app.files().get_cloud_status(url)
}

#[command]
pub(crate) async fn download_from_cloud<R: Runtime>(
    app: AppHandle<R>,
    url: String,
) -> Result<()> {
    app.files().download_from_cloud(url)
}

#[command]
pub(crate) async fn evict_from_local<R: Runtime>(
    app: AppHandle<R>,
    url: String,
) -> Result<()> {
    app.files().evict_from_local(url)
}

#[command]
pub(crate) async fn start_monitoring<R: Runtime>(
    app: AppHandle<R>,
    options: MonitoringOptions,
) -> Result<()> {
    app.files().start_monitoring(options)
}

#[command]
pub(crate) async fn stop_monitoring<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.files().stop_monitoring()
}