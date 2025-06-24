use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_contacts);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Contacts<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_contacts)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.contacts", "ContactsPlugin")?;
    
    Ok(Contacts(handle))
}

/// Access to the contacts APIs on mobile.
pub struct Contacts<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Contacts<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        self.0
            .run_mobile_plugin("checkPermissions", ())
            .map_err(Into::into)
    }

    pub fn request_permissions(&self) -> Result<PermissionStatus> {
        self.0
            .run_mobile_plugin("requestPermissions", ())
            .map_err(Into::into)
    }

    pub fn get_contacts(&self, query: Option<ContactQuery>) -> Result<Vec<Contact>> {
        self.0
            .run_mobile_plugin("getContacts", query)
            .map_err(Into::into)
    }

    pub fn get_contact(&self, id: &str) -> Result<Contact> {
        #[derive(serde::Serialize)]
        struct GetContactArgs<'a> {
            id: &'a str,
        }
        
        self.0
            .run_mobile_plugin("getContact", GetContactArgs { id })
            .map_err(Into::into)
    }

    pub fn create_contact(&self, contact: NewContact) -> Result<Contact> {
        self.0
            .run_mobile_plugin("createContact", contact)
            .map_err(Into::into)
    }

    pub fn update_contact(&self, contact: Contact) -> Result<Contact> {
        self.0
            .run_mobile_plugin("updateContact", contact)
            .map_err(Into::into)
    }

    pub fn delete_contact(&self, id: &str) -> Result<()> {
        #[derive(serde::Serialize)]
        struct DeleteContactArgs<'a> {
            id: &'a str,
        }
        
        self.0
            .run_mobile_plugin("deleteContact", DeleteContactArgs { id })
            .map_err(Into::into)
    }

    pub fn get_groups(&self) -> Result<Vec<ContactGroup>> {
        self.0
            .run_mobile_plugin("getGroups", ())
            .map_err(Into::into)
    }

    pub fn create_group(&self, name: &str) -> Result<ContactGroup> {
        #[derive(serde::Serialize)]
        struct CreateGroupArgs<'a> {
            name: &'a str,
        }
        
        self.0
            .run_mobile_plugin("createGroup", CreateGroupArgs { name })
            .map_err(Into::into)
    }
}