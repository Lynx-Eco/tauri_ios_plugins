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
use desktop::Proximity;
#[cfg(mobile)]
use mobile::Proximity;

pub trait ProximityExt<R: Runtime> {
    fn proximity(&self) -> &Proximity<R>;
}

impl<R: Runtime, T: Manager<R>> ProximityExt<R> for T {
    fn proximity(&self) -> &Proximity<R> {
        self.state::<Proximity<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-proximity")
        .invoke_handler(tauri::generate_handler![
            commands::start_proximity_monitoring,
            commands::stop_proximity_monitoring,
            commands::get_proximity_state,
            commands::is_proximity_available,
            commands::enable_proximity_monitoring,
            commands::disable_proximity_monitoring,
            commands::set_display_auto_lock,
            commands::get_display_auto_lock_state,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let proximity = mobile::init(app, api)?;
            #[cfg(desktop)]
            let proximity = desktop::init(app, api)?;
            
            app.manage(proximity);
            Ok(())
        })
        .build()
}