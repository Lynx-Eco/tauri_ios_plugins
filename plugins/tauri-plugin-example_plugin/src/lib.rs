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
use desktop::ExamplePlugin;
#[cfg(mobile)]
use mobile::ExamplePlugin;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`] and [`tauri::Window`] to access the example-plugin APIs.
pub trait ExamplePluginExt<R: Runtime> {
  fn example_plugin(&self) -> &ExamplePlugin<R>;
}

impl<R: Runtime, T: Manager<R>> crate::ExamplePluginExt<R> for T {
  fn example_plugin(&self) -> &ExamplePlugin<R> {
    self.state::<ExamplePlugin<R>>().inner()
  }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
  Builder::new("example-plugin")
    .invoke_handler(tauri::generate_handler![commands::ping])
    .setup(|app, api| {
      #[cfg(mobile)]
      let example_plugin = mobile::init(app, api)?;
      #[cfg(desktop)]
      let example_plugin = desktop::init(app, api)?;
      app.manage(example_plugin);
      Ok(())
    })
    .build()
}
