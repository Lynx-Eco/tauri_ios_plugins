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
use desktop::CallKit;
#[cfg(mobile)]
use mobile::CallKit;

pub trait CallKitExt<R: Runtime> {
    fn callkit(&self) -> &CallKit<R>;
}

impl<R: Runtime, T: Manager<R>> CallKitExt<R> for T {
    fn callkit(&self) -> &CallKit<R> {
        self.state::<CallKit<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-callkit")
        .invoke_handler(tauri::generate_handler![
            commands::configure_audio_session,
            commands::report_incoming_call,
            commands::report_outgoing_call,
            commands::end_call,
            commands::set_held,
            commands::set_muted,
            commands::set_group,
            commands::set_on_hold,
            commands::start_call_audio,
            commands::answer_call,
            commands::report_call_update,
            commands::get_active_calls,
            commands::get_call_state,
            commands::request_transaction,
            commands::report_audio_route_change,
            commands::set_provider_configuration,
            commands::register_for_voip_notifications,
            commands::invalidate_push_token,
            commands::report_new_incoming_voip_push,
            commands::check_call_capability,
            commands::get_audio_routes,
            commands::set_audio_route,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let callkit = mobile::init(app, api)?;
            #[cfg(desktop)]
            let callkit = desktop::init(app, api)?;
            
            app.manage(callkit);
            Ok(())
        })
        .build()
}