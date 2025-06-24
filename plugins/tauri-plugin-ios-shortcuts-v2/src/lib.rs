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
use desktop::Shortcuts;
#[cfg(mobile)]
use mobile::Shortcuts;

pub trait ShortcutsExt<R: Runtime> {
    fn shortcuts(&self) -> &Shortcuts<R>;
}

impl<R: Runtime, T: Manager<R>> ShortcutsExt<R> for T {
    fn shortcuts(&self) -> &Shortcuts<R> {
        self.state::<Shortcuts<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-shortcuts")
        .invoke_handler(tauri::generate_handler![
            commands::donate_interaction,
            commands::donate_shortcut,
            commands::get_all_shortcuts,
            commands::delete_shortcut,
            commands::delete_all_shortcuts,
            commands::get_voice_shortcuts,
            commands::suggest_phrase,
            commands::handle_user_activity,
            commands::update_shortcut,
            commands::get_shortcut_suggestions,
            commands::set_shortcut_suggestions,
            commands::create_app_intent,
            commands::register_app_intents,
            commands::handle_intent,
            commands::get_donated_intents,
            commands::delete_donated_intents,
            commands::set_eligible_for_prediction,
            commands::get_predictions,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let shortcuts = mobile::init(app, api)?;
            #[cfg(desktop)]
            let shortcuts = desktop::init(app, api)?;
            
            app.manage(shortcuts);
            Ok(())
        })
        .build()
}