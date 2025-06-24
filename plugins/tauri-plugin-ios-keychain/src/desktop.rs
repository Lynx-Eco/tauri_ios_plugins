use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Keychain<R>> {
    Ok(Keychain(app.clone()))
}

/// Access to the keychain APIs on desktop (returns errors as not available).
pub struct Keychain<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Keychain<R> {
    pub fn set_item(&self, _item: KeychainItem) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn get_item(&self, _query: KeychainQuery) -> Result<KeychainItem> {
        Err(Error::OperationFailed("Item not found".to_string()))
    }

    pub fn delete_item(&self, _query: KeychainQuery) -> Result<()> {
        Err(Error::OperationFailed("Item not found".to_string()))
    }

    pub fn has_item(&self, _query: KeychainQuery) -> Result<bool> {
        Ok(false)
    }

    pub fn update_item(&self, _query: KeychainQuery, _updates: KeychainUpdate) -> Result<()> {
        Err(Error::OperationFailed("Item not found".to_string()))
    }

    pub fn get_all_keys(&self, _service: Option<String>) -> Result<Vec<String>> {
        Ok(vec![])
    }

    pub fn delete_all(&self, _service: Option<String>) -> Result<()> {
        Ok(())
    }

    pub fn set_secure_item(&self, _item: SecureKeychainItem) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn get_secure_item(&self, _query: SecureKeychainQuery) -> Result<SecureKeychainItem> {
        Err(Error::OperationFailed("Item not found".to_string()))
    }

    pub fn set_internet_password(&self, _item: InternetPasswordItem) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn get_internet_password(&self, _query: InternetPasswordQuery) -> Result<InternetPasswordItem> {
        Err(Error::OperationFailed("Item not found".to_string()))
    }

    pub fn generate_password(&self, options: PasswordOptions) -> Result<String> {
        use rand::{thread_rng, Rng};
        
        let mut chars = String::new();
        
        if options.include_lowercase {
            chars.push_str("abcdefghijklmnopqrstuvwxyz");
        }
        if options.include_uppercase {
            chars.push_str("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        }
        if options.include_numbers {
            chars.push_str("0123456789");
        }
        if options.include_symbols {
            chars.push_str("!@#$%^&*()_+-=[]{}|;:,.<>?");
        }
        
        if options.exclude_ambiguous {
            chars = chars.replace("0", "").replace("O", "").replace("l", "").replace("1", "").replace("I", "");
        }
        
        if let Some(custom) = options.custom_characters {
            chars.push_str(&custom);
        }
        
        if chars.is_empty() {
            return Err(Error::OperationFailed("Password generation failed".to_string()));
        }
        
        let mut rng = thread_rng();
        let password: String = (0..options.length)
            .map(|_| {
                let idx = rng.gen_range(0..chars.len());
                chars.chars().nth(idx).unwrap()
            })
            .collect();
        
        Ok(password)
    }
}