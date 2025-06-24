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
use desktop::ScreenTime;
#[cfg(mobile)]
use mobile::ScreenTime;

pub trait ScreenTimeExt<R: Runtime> {
    fn screentime(&self) -> &ScreenTime<R>;
}

impl<R: Runtime, T: Manager<R>> ScreenTimeExt<R> for T {
    fn screentime(&self) -> &ScreenTime<R> {
        self.state::<ScreenTime<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-screentime")
        .invoke_handler(tauri::generate_handler![
            commands::request_authorization,
            commands::get_screen_time_summary,
            commands::get_app_usage,
            commands::get_category_usage,
            commands::get_web_usage,
            commands::get_device_activity,
            commands::get_notifications_summary,
            commands::get_pickups_summary,
            commands::set_app_limit,
            commands::get_app_limits,
            commands::remove_app_limit,
            commands::set_downtime_schedule,
            commands::get_downtime_schedule,
            commands::remove_downtime_schedule,
            commands::block_app,
            commands::unblock_app,
            commands::get_blocked_apps,
            commands::set_communication_safety,
            commands::get_communication_safety_settings,
            commands::get_screen_distance,
            commands::get_usage_trends,
            commands::export_usage_report,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let screentime = mobile::init(app, api)?;
            #[cfg(desktop)]
            let screentime = desktop::init(app, api)?;
            
            app.manage(screentime);
            Ok(())
        })
        .build()
}