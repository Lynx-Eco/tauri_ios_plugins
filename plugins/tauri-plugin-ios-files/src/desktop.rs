use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Files<R>> {
    Ok(Files(app.clone()))
}

/// Access to the Files APIs on desktop (returns errors as not available).
pub struct Files<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Files<R> {
    pub fn pick_file(&self, _options: FilePickerOptions) -> Result<PickedFile> {
        Err(Error::NotAvailable)
    }
    
    pub fn pick_multiple_files(&self, _options: FilePickerOptions) -> Result<Vec<PickedFile>> {
        Err(Error::NotAvailable)
    }
    
    pub fn pick_folder(&self) -> Result<PickedFile> {
        Err(Error::NotAvailable)
    }
    
    pub fn save_file(&self, _options: SaveFileOptions) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn open_in_files(&self, _url: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn import_from_files(&self, _options: ImportOptions) -> Result<Vec<PickedFile>> {
        Err(Error::NotAvailable)
    }
    
    pub fn export_to_files(&self, _options: ExportOptions) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn list_documents(&self, _options: ListOptions) -> Result<Vec<DocumentInfo>> {
        Err(Error::NotAvailable)
    }
    
    pub fn read_file(&self, _url: String) -> Result<FileData> {
        Err(Error::NotAvailable)
    }
    
    pub fn write_file(&self, _url: String, _data: FileData) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn delete_file(&self, _url: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn move_file(&self, _operation: FileOperation) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn copy_file(&self, _operation: FileOperation) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn create_folder(&self, _url: String, _name: String) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_file_info(&self, _url: String) -> Result<DocumentInfo> {
        Err(Error::NotAvailable)
    }
    
    pub fn share_file(&self, _options: ShareOptions) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn preview_file(&self, _options: PreviewOptions) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_cloud_status(&self, _url: String) -> Result<CloudStatus> {
        Err(Error::NotAvailable)
    }
    
    pub fn download_from_cloud(&self, _url: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn evict_from_local(&self, _url: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_monitoring(&self, _options: MonitoringOptions) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_monitoring(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
}