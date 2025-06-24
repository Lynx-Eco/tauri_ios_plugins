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
use desktop::Widgets;
#[cfg(mobile)]
use mobile::Widgets;

pub trait WidgetsExt<R: Runtime> {
    fn widgets(&self) -> &Widgets<R>;
}

impl<R: Runtime, T: Manager<R>> WidgetsExt<R> for T {
    fn widgets(&self) -> &Widgets<R> {
        self.state::<Widgets<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-widgets")
        .invoke_handler(tauri::generate_handler![
            commands::reload_all_timelines,
            commands::reload_timelines,
            commands::get_current_configurations,
            commands::set_widget_data,
            commands::get_widget_data,
            commands::clear_widget_data,
            commands::request_widget_update,
            commands::get_widget_info,
            commands::set_widget_url,
            commands::get_widget_url,
            commands::preview_widget_data,
            commands::get_widget_families,
            commands::schedule_widget_refresh,
            commands::cancel_widget_refresh,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let widgets = mobile::init(app, api)?;
            #[cfg(desktop)]
            let widgets = desktop::init(app, api)?;
            
            app.manage(widgets);
            Ok(())
        })
        .build()
}