use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Contacts<R>> {
    Ok(Contacts(app.clone()))
}

/// Access to the contacts APIs on desktop (returns errors as not available).
pub struct Contacts<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Contacts<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        Err(Error::PermissionDenied)
    }

    pub fn request_permissions(&self) -> Result<PermissionStatus> {
        Err(Error::PermissionDenied)
    }

    pub fn get_contacts(&self, _query: Option<ContactQuery>) -> Result<Vec<Contact>> {
        Err(Error::PermissionDenied)
    }

    pub fn get_contact(&self, _id: &str) -> Result<Contact> {
        Err(Error::OperationFailed("Contact not found".to_string()))
    }

    pub fn create_contact(&self, _contact: NewContact) -> Result<Contact> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn update_contact(&self, _contact: Contact) -> Result<Contact> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn delete_contact(&self, _id: &str) -> Result<()> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn get_groups(&self) -> Result<Vec<ContactGroup>> {
        Err(Error::PermissionDenied)
    }

    pub fn create_group(&self, _name: &str) -> Result<ContactGroup> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }
}