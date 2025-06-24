#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;
mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
use desktop::Files;
#[cfg(mobile)]
use mobile::Files;

pub trait FilesExt<R: Runtime> {
    fn files(&self) -> &Files<R>;
}

impl<R: Runtime, T: Manager<R>> FilesExt<R> for T {
    fn files(&self) -> &Files<R> {
        self.state::<Files<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-files")
        .invoke_handler(tauri::generate_handler![
            commands::pick_file,
            commands::pick_multiple_files,
            commands::pick_folder,
            commands::save_file,
            commands::open_in_files,
            commands::import_from_files,
            commands::export_to_files,
            commands::list_documents,
            commands::read_file,
            commands::write_file,
            commands::delete_file,
            commands::move_file,
            commands::copy_file,
            commands::create_folder,
            commands::get_file_info,
            commands::share_file,
            commands::preview_file,
            commands::get_cloud_status,
            commands::download_from_cloud,
            commands::evict_from_local,
            commands::start_monitoring,
            commands::stop_monitoring,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let files = mobile::init(app, api)?;
            #[cfg(desktop)]
            let files = desktop::init(app, api)?;
            
            app.manage(files);
            Ok(())
        })
        .build()
}