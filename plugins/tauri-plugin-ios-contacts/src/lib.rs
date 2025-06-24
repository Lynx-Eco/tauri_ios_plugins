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

/// Extensions to [`tauri::App`], [`tauri::AppHandle`], [`tauri::WebviewWindow`], [`tauri::Webview`] and [`tauri::Window`] to access the contacts APIs.
pub trait ContactsExt<R: Runtime> {
    fn contacts(&self) -> &Contacts<R>;
}

impl<R: Runtime, T: Manager<R>> crate::ContactsExt<R> for T {
    fn contacts(&self) -> &Contacts<R> {
        self.state::<Contacts<R>>().inner()
    }
}

/// Access to the contacts APIs.
pub struct Contacts<R: Runtime>(ContactsImpl<R>);

#[cfg(desktop)]
type ContactsImpl<R> = desktop::Contacts<R>;
#[cfg(mobile)]
type ContactsImpl<R> = mobile::Contacts<R>;

impl<R: Runtime> Contacts<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        self.0.check_permissions()
    }

    pub fn request_permissions(&self) -> Result<PermissionStatus> {
        self.0.request_permissions()
    }

    pub fn get_contacts(&self, query: Option<ContactQuery>) -> Result<Vec<Contact>> {
        self.0.get_contacts(query)
    }

    pub fn get_contact(&self, id: &str) -> Result<Contact> {
        self.0.get_contact(id)
    }

    pub fn create_contact(&self, contact: NewContact) -> Result<Contact> {
        self.0.create_contact(contact)
    }

    pub fn update_contact(&self, contact: Contact) -> Result<Contact> {
        self.0.update_contact(contact)
    }

    pub fn delete_contact(&self, id: &str) -> Result<()> {
        self.0.delete_contact(id)
    }

    pub fn get_groups(&self) -> Result<Vec<ContactGroup>> {
        self.0.get_groups()
    }

    pub fn create_group(&self, name: &str) -> Result<ContactGroup> {
        self.0.create_group(name)
    }

    pub fn update_group(&self, group_id: &str, name: &str) -> Result<ContactGroup> {
        self.0.update_group(group_id, name)
    }

    pub fn delete_group(&self, group_id: &str) -> Result<()> {
        self.0.delete_group(group_id)
    }

    pub fn add_contact_to_group(&self, contact_id: &str, group_id: &str) -> Result<()> {
        self.0.add_contact_to_group(contact_id, group_id)
    }

    pub fn remove_contact_from_group(&self, contact_id: &str, group_id: &str) -> Result<()> {
        self.0.remove_contact_from_group(contact_id, group_id)
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-contacts")
        .invoke_handler(tauri::generate_handler![
            commands::check_permissions,
            commands::request_permissions,
            commands::get_contacts,
            commands::get_contact,
            commands::create_contact,
            commands::update_contact,
            commands::delete_contact,
            commands::get_groups,
            commands::create_group,
            commands::update_group,
            commands::delete_group,
            commands::add_contact_to_group,
            commands::remove_contact_from_group,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let contacts = mobile::init(app, api)?;
            #[cfg(desktop)]
            let contacts = desktop::init(app, api)?;
            
            app.manage(Contacts(contacts));
            Ok(())
        })
        .build()
}