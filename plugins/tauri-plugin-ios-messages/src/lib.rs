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
use desktop::Messages;
#[cfg(mobile)]
use mobile::Messages;

pub trait MessagesExt<R: Runtime> {
    fn messages(&self) -> &Messages<R>;
}

impl<R: Runtime, T: Manager<R>> MessagesExt<R> for T {
    fn messages(&self) -> &Messages<R> {
        self.state::<Messages<R>>().inner()
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-messages")
        .invoke_handler(tauri::generate_handler![
            commands::compose_message,
            commands::compose_imessage,
            commands::send_sms,
            commands::can_send_text,
            commands::can_send_subject,
            commands::can_send_attachments,
            commands::get_conversation_list,
            commands::get_conversation,
            commands::get_messages,
            commands::mark_as_read,
            commands::delete_message,
            commands::search_messages,
            commands::get_attachments,
            commands::save_attachment,
            commands::get_message_status,
            commands::register_for_notifications,
            commands::unregister_notifications,
            commands::check_imessage_availability,
            commands::get_blocked_contacts,
            commands::block_contact,
            commands::unblock_contact,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let messages = mobile::init(app, api)?;
            #[cfg(desktop)]
            let messages = desktop::init(app, api)?;
            
            app.manage(messages);
            Ok(())
        })
        .build()
}