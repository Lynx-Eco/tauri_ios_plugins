use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_files);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Files<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_files)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.files", "FilesPlugin")?;
    
    Ok(Files(handle))
}

/// Access to the Files APIs on mobile.
pub struct Files<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Files<R> {
    pub fn pick_file(&self, options: FilePickerOptions) -> Result<PickedFile> {
        self.0
            .run_mobile_plugin("pickFile", options)
            .map_err(Into::into)
    }
    
    pub fn pick_multiple_files(&self, options: FilePickerOptions) -> Result<Vec<PickedFile>> {
        self.0
            .run_mobile_plugin("pickMultipleFiles", options)
            .map_err(Into::into)
    }
    
    pub fn pick_folder(&self) -> Result<PickedFile> {
        self.0
            .run_mobile_plugin("pickFolder", ())
            .map_err(Into::into)
    }
    
    pub fn save_file(&self, options: SaveFileOptions) -> Result<String> {
        self.0
            .run_mobile_plugin("saveFile", options)
            .map_err(Into::into)
    }
    
    pub fn open_in_files(&self, url: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
        }
        
        self.0
            .run_mobile_plugin("openInFiles", Args { url })
            .map_err(Into::into)
    }
    
    pub fn import_from_files(&self, options: ImportOptions) -> Result<Vec<PickedFile>> {
        self.0
            .run_mobile_plugin("importFromFiles", options)
            .map_err(Into::into)
    }
    
    pub fn export_to_files(&self, options: ExportOptions) -> Result<()> {
        self.0
            .run_mobile_plugin("exportToFiles", options)
            .map_err(Into::into)
    }
    
    pub fn list_documents(&self, options: ListOptions) -> Result<Vec<DocumentInfo>> {
        self.0
            .run_mobile_plugin("listDocuments", options)
            .map_err(Into::into)
    }
    
    pub fn read_file(&self, url: String) -> Result<FileData> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
        }
        
        self.0
            .run_mobile_plugin("readFile", Args { url })
            .map_err(Into::into)
    }
    
    pub fn write_file(&self, url: String, data: FileData) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
            data: FileData,
        }
        
        self.0
            .run_mobile_plugin("writeFile", Args { url, data })
            .map_err(Into::into)
    }
    
    pub fn delete_file(&self, url: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
        }
        
        self.0
            .run_mobile_plugin("deleteFile", Args { url })
            .map_err(Into::into)
    }
    
    pub fn move_file(&self, operation: FileOperation) -> Result<String> {
        self.0
            .run_mobile_plugin("moveFile", operation)
            .map_err(Into::into)
    }
    
    pub fn copy_file(&self, operation: FileOperation) -> Result<String> {
        self.0
            .run_mobile_plugin("copyFile", operation)
            .map_err(Into::into)
    }
    
    pub fn create_folder(&self, url: String, name: String) -> Result<String> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
            name: String,
        }
        
        self.0
            .run_mobile_plugin("createFolder", Args { url, name })
            .map_err(Into::into)
    }
    
    pub fn get_file_info(&self, url: String) -> Result<DocumentInfo> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
        }
        
        self.0
            .run_mobile_plugin("getFileInfo", Args { url })
            .map_err(Into::into)
    }
    
    pub fn share_file(&self, options: ShareOptions) -> Result<()> {
        self.0
            .run_mobile_plugin("shareFile", options)
            .map_err(Into::into)
    }
    
    pub fn preview_file(&self, options: PreviewOptions) -> Result<()> {
        self.0
            .run_mobile_plugin("previewFile", options)
            .map_err(Into::into)
    }
    
    pub fn get_cloud_status(&self, url: String) -> Result<CloudStatus> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
        }
        
        self.0
            .run_mobile_plugin("getCloudStatus", Args { url })
            .map_err(Into::into)
    }
    
    pub fn download_from_cloud(&self, url: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
        }
        
        self.0
            .run_mobile_plugin("downloadFromCloud", Args { url })
            .map_err(Into::into)
    }
    
    pub fn evict_from_local(&self, url: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            url: String,
        }
        
        self.0
            .run_mobile_plugin("evictFromLocal", Args { url })
            .map_err(Into::into)
    }
    
    pub fn start_monitoring(&self, options: MonitoringOptions) -> Result<()> {
        self.0
            .run_mobile_plugin("startMonitoring", options)
            .map_err(Into::into)
    }
    
    pub fn stop_monitoring(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopMonitoring", ())
            .map_err(Into::into)
    }
}