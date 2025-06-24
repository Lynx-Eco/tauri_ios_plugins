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
use desktop::Barometer;
#[cfg(mobile)]
use mobile::Barometer;

pub trait BarometerExt<R: Runtime> {
    fn barometer(&self) -> &Barometer<R>;
}

impl<R: Runtime, T: Manager<R>> BarometerExt<R> for T {
    fn barometer(&self) -> &Barometer<R> {
        self.state::<Barometer<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-barometer")
        .invoke_handler(tauri::generate_handler![
            commands::start_pressure_updates,
            commands::stop_pressure_updates,
            commands::get_pressure_data,
            commands::is_barometer_available,
            commands::set_update_interval,
            commands::get_reference_pressure,
            commands::set_reference_pressure,
            commands::get_altitude_from_pressure,
            commands::start_altitude_updates,
            commands::stop_altitude_updates,
            commands::get_weather_data,
            commands::calibrate_barometer,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let barometer = mobile::init(app, api)?;
            #[cfg(desktop)]
            let barometer = desktop::init(app, api)?;
            
            app.manage(barometer);
            Ok(())
        })
        .build()
}