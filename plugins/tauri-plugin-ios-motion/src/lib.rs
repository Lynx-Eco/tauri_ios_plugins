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
use desktop::Motion;
#[cfg(mobile)]
use mobile::Motion;

pub trait MotionExt<R: Runtime> {
    fn motion(&self) -> &Motion<R>;
}

impl<R: Runtime, T: Manager<R>> MotionExt<R> for T {
    fn motion(&self) -> &Motion<R> {
        self.state::<Motion<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-motion")
        .invoke_handler(tauri::generate_handler![
            commands::start_accelerometer_updates,
            commands::stop_accelerometer_updates,
            commands::get_accelerometer_data,
            commands::start_gyroscope_updates,
            commands::stop_gyroscope_updates,
            commands::get_gyroscope_data,
            commands::start_magnetometer_updates,
            commands::stop_magnetometer_updates,
            commands::get_magnetometer_data,
            commands::start_device_motion_updates,
            commands::stop_device_motion_updates,
            commands::get_device_motion_data,
            commands::set_update_interval,
            commands::is_accelerometer_available,
            commands::is_gyroscope_available,
            commands::is_magnetometer_available,
            commands::is_device_motion_available,
            commands::get_motion_activity,
            commands::start_activity_updates,
            commands::stop_activity_updates,
            commands::query_activity_history,
            commands::start_pedometer_updates,
            commands::stop_pedometer_updates,
            commands::get_pedometer_data,
            commands::is_pedometer_available,
            commands::is_step_counting_available,
            commands::is_distance_available,
            commands::is_floor_counting_available,
            commands::get_altimeter_data,
            commands::start_altimeter_updates,
            commands::stop_altimeter_updates,
            commands::is_relative_altitude_available,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let motion = mobile::init(app, api)?;
            #[cfg(desktop)]
            let motion = desktop::init(app, api)?;
            
            app.manage(motion);
            Ok(())
        })
        .build()
}