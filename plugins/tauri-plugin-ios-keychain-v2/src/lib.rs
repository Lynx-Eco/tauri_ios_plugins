use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`], [`tauri::WebviewWindow`], [`tauri::Webview`] and [`tauri::Window`] to access the keychain APIs.
pub trait KeychainExt<R: Runtime> {
    fn keychain(&self) -> &Keychain<R>;
}

impl<R: Runtime, T: Manager<R>> crate::KeychainExt<R> for T {
    fn keychain(&self) -> &Keychain<R> {
        self.state::<Keychain<R>>().inner()
    }
}

/// Access to the keychain APIs.
pub struct Keychain<R: Runtime>(KeychainImpl<R>);

#[cfg(desktop)]
type KeychainImpl<R> = desktop::Keychain<R>;
#[cfg(mobile)]
type KeychainImpl<R> = mobile::Keychain<R>;

impl<R: Runtime> Keychain<R> {
    pub fn set_item(&self, item: KeychainItem) -> Result<()> {
        self.0.set_item(item)
    }

    pub fn get_item(&self, query: KeychainQuery) -> Result<KeychainItem> {
        self.0.get_item(query)
    }

    pub fn delete_item(&self, query: KeychainQuery) -> Result<()> {
        self.0.delete_item(query)
    }

    pub fn has_item(&self, query: KeychainQuery) -> Result<bool> {
        self.0.has_item(query)
    }

    pub fn update_item(&self, query: KeychainQuery, updates: KeychainUpdate) -> Result<()> {
        self.0.update_item(query, updates)
    }

    pub fn get_all_keys(&self, service: Option<String>) -> Result<Vec<String>> {
        self.0.get_all_keys(service)
    }

    pub fn delete_all(&self, service: Option<String>) -> Result<()> {
        self.0.delete_all(service)
    }

    pub fn set_secure_item(&self, item: SecureKeychainItem) -> Result<()> {
        self.0.set_secure_item(item)
    }

    pub fn get_secure_item(&self, query: SecureKeychainQuery) -> Result<SecureKeychainItem> {
        self.0.get_secure_item(query)
    }

    pub fn set_internet_password(&self, item: InternetPasswordItem) -> Result<()> {
        self.0.set_internet_password(item)
    }

    pub fn get_internet_password(&self, query: InternetPasswordQuery) -> Result<InternetPasswordItem> {
        self.0.get_internet_password(query)
    }

    pub fn generate_password(&self, options: PasswordOptions) -> Result<String> {
        self.0.generate_password(options)
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-keychain")
        .invoke_handler(tauri::generate_handler![
            commands::set_item,
            commands::get_item,
            commands::delete_item,
            commands::has_item,
            commands::update_item,
            commands::get_all_keys,
            commands::delete_all,
            commands::set_access_group,
            commands::get_access_group,
            commands::set_secure_item,
            commands::get_secure_item,
            commands::generate_password,
            commands::check_authentication,
            commands::set_internet_password,
            commands::get_internet_password,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let keychain = mobile::init(app, api)?;
            #[cfg(desktop)]
            let keychain = desktop::init(app, api)?;
            
            app.manage(Keychain(keychain));
            Ok(())
        })
        .build()
}