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
use desktop::Bluetooth;
#[cfg(mobile)]
use mobile::Bluetooth;

pub trait BluetoothExt<R: Runtime> {
    fn bluetooth(&self) -> &Bluetooth<R>;
}

impl<R: Runtime, T: Manager<R>> BluetoothExt<R> for T {
    fn bluetooth(&self) -> &Bluetooth<R> {
        self.state::<Bluetooth<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-bluetooth")
        .invoke_handler(tauri::generate_handler![
            commands::request_authorization,
            commands::get_authorization_status,
            commands::is_bluetooth_enabled,
            commands::start_central_scan,
            commands::stop_central_scan,
            commands::connect_peripheral,
            commands::disconnect_peripheral,
            commands::get_connected_peripherals,
            commands::get_discovered_peripherals,
            commands::discover_services,
            commands::discover_characteristics,
            commands::read_characteristic,
            commands::write_characteristic,
            commands::subscribe_to_characteristic,
            commands::unsubscribe_from_characteristic,
            commands::read_descriptor,
            commands::write_descriptor,
            commands::get_peripheral_rssi,
            commands::start_peripheral_advertising,
            commands::stop_peripheral_advertising,
            commands::add_service,
            commands::remove_service,
            commands::remove_all_services,
            commands::respond_to_request,
            commands::update_characteristic_value,
            commands::get_maximum_write_length,
            commands::set_notify_value,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let bluetooth = mobile::init(app, api)?;
            #[cfg(desktop)]
            let bluetooth = desktop::init(app, api)?;
            
            app.manage(bluetooth);
            Ok(())
        })
        .build()
}