use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_keychain);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Keychain<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_keychain)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.keychain", "KeychainPlugin")?;
    
    Ok(Keychain(handle))
}

/// Access to the keychain APIs on mobile.
pub struct Keychain<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Keychain<R> {
    pub fn set_item(&self, item: KeychainItem) -> Result<()> {
        self.0
            .run_mobile_plugin("setItem", item)
            .map_err(Into::into)
    }

    pub fn get_item(&self, query: KeychainQuery) -> Result<KeychainItem> {
        self.0
            .run_mobile_plugin("getItem", query)
            .map_err(Into::into)
    }

    pub fn delete_item(&self, query: KeychainQuery) -> Result<()> {
        self.0
            .run_mobile_plugin("deleteItem", query)
            .map_err(Into::into)
    }

    pub fn has_item(&self, query: KeychainQuery) -> Result<bool> {
        self.0
            .run_mobile_plugin("hasItem", query)
            .map_err(Into::into)
    }

    pub fn update_item(&self, query: KeychainQuery, updates: KeychainUpdate) -> Result<()> {
        #[derive(serde::Serialize)]
        struct UpdateArgs {
            query: KeychainQuery,
            updates: KeychainUpdate,
        }
        
        self.0
            .run_mobile_plugin("updateItem", UpdateArgs { query, updates })
            .map_err(Into::into)
    }

    pub fn get_all_keys(&self, service: Option<String>) -> Result<Vec<String>> {
        #[derive(serde::Serialize)]
        struct GetAllKeysArgs {
            service: Option<String>,
        }
        
        self.0
            .run_mobile_plugin("getAllKeys", GetAllKeysArgs { service })
            .map_err(Into::into)
    }

    pub fn delete_all(&self, service: Option<String>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct DeleteAllArgs {
            service: Option<String>,
        }
        
        self.0
            .run_mobile_plugin("deleteAll", DeleteAllArgs { service })
            .map_err(Into::into)
    }

    pub fn set_secure_item(&self, item: SecureKeychainItem) -> Result<()> {
        self.0
            .run_mobile_plugin("setSecureItem", item)
            .map_err(Into::into)
    }

    pub fn get_secure_item(&self, query: SecureKeychainQuery) -> Result<SecureKeychainItem> {
        self.0
            .run_mobile_plugin("getSecureItem", query)
            .map_err(Into::into)
    }

    pub fn set_internet_password(&self, item: InternetPasswordItem) -> Result<()> {
        self.0
            .run_mobile_plugin("setInternetPassword", item)
            .map_err(Into::into)
    }

    pub fn get_internet_password(&self, query: InternetPasswordQuery) -> Result<InternetPasswordItem> {
        self.0
            .run_mobile_plugin("getInternetPassword", query)
            .map_err(Into::into)
    }

    pub fn generate_password(&self, options: PasswordOptions) -> Result<String> {
        self.0
            .run_mobile_plugin("generatePassword", options)
            .map_err(Into::into)
    }

    pub fn get_access_group(&self) -> Result<Vec<String>> {
        self.0
            .run_mobile_plugin("getAccessGroup", ())
            .map_err(Into::into)
    }

    pub fn set_access_group(&self, access_group: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct SetAccessGroupArgs {
            access_group: String,
        }
        
        self.0
            .run_mobile_plugin("setAccessGroup", SetAccessGroupArgs { access_group })
            .map_err(Into::into)
    }
}