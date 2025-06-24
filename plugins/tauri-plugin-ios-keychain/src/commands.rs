use tauri::{command, AppHandle, Runtime};

use crate::{KeychainExt, KeychainItem, KeychainQuery, KeychainUpdate, SecureKeychainItem, SecureKeychainQuery, InternetPasswordItem, InternetPasswordQuery, PasswordOptions, AuthenticationResult, Result};

#[command]
pub(crate) async fn set_item<R: Runtime>(
    app: AppHandle<R>,
    item: KeychainItem,
) -> Result<()> {
    app.keychain().set_item(item)
}

#[command]
pub(crate) async fn get_item<R: Runtime>(
    app: AppHandle<R>,
    query: KeychainQuery,
) -> Result<KeychainItem> {
    app.keychain().get_item(query)
}

#[command]
pub(crate) async fn delete_item<R: Runtime>(
    app: AppHandle<R>,
    query: KeychainQuery,
) -> Result<()> {
    app.keychain().delete_item(query)
}

#[command]
pub(crate) async fn has_item<R: Runtime>(
    app: AppHandle<R>,
    query: KeychainQuery,
) -> Result<bool> {
    app.keychain().has_item(query)
}

#[command]
pub(crate) async fn update_item<R: Runtime>(
    app: AppHandle<R>,
    query: KeychainQuery,
    updates: KeychainUpdate,
) -> Result<()> {
    app.keychain().update_item(query, updates)
}

#[command]
pub(crate) async fn get_all_keys<R: Runtime>(
    app: AppHandle<R>,
    service: Option<String>,
) -> Result<Vec<String>> {
    app.keychain().get_all_keys(service)
}

#[command]
pub(crate) async fn delete_all<R: Runtime>(
    app: AppHandle<R>,
    service: Option<String>,
) -> Result<()> {
    app.keychain().delete_all(service)
}

#[command]
pub(crate) async fn set_access_group<R: Runtime>(
    _app: AppHandle<R>,
    _group: String,
) -> Result<()> {
    // This would be implemented in mobile module
    Ok(())
}

#[command]
pub(crate) async fn get_access_group<R: Runtime>(
    _app: AppHandle<R>,
) -> Result<Option<String>> {
    // This would be implemented in mobile module
    Ok(None)
}

#[command]
pub(crate) async fn set_secure_item<R: Runtime>(
    app: AppHandle<R>,
    item: SecureKeychainItem,
) -> Result<()> {
    app.keychain().set_secure_item(item)
}

#[command]
pub(crate) async fn get_secure_item<R: Runtime>(
    app: AppHandle<R>,
    query: SecureKeychainQuery,
) -> Result<SecureKeychainItem> {
    app.keychain().get_secure_item(query)
}

#[command]
pub(crate) async fn generate_password<R: Runtime>(
    app: AppHandle<R>,
    options: Option<PasswordOptions>,
) -> Result<String> {
    app.keychain().generate_password(options.unwrap_or_default())
}

#[command]
pub(crate) async fn check_authentication<R: Runtime>(
    _app: AppHandle<R>,
    _reason: String,
) -> Result<AuthenticationResult> {
    // This would be implemented in mobile module
    Ok(AuthenticationResult {
        success: false,
        biometry_type: None,
        error: Some("Not implemented".to_string()),
    })
}

#[command]
pub(crate) async fn set_internet_password<R: Runtime>(
    app: AppHandle<R>,
    item: InternetPasswordItem,
) -> Result<()> {
    app.keychain().set_internet_password(item)
}

#[command]
pub(crate) async fn get_internet_password<R: Runtime>(
    app: AppHandle<R>,
    query: InternetPasswordQuery,
) -> Result<InternetPasswordItem> {
    app.keychain().get_internet_password(query)
}