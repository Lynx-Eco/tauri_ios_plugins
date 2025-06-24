use tauri::{command, AppHandle, Runtime};

use crate::{ContactsExt, PermissionStatus, Contact, NewContact, ContactQuery, ContactGroup, Result};

#[command]
pub(crate) async fn check_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<PermissionStatus> {
    app.contacts().check_permissions()
}

#[command]
pub(crate) async fn request_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<PermissionStatus> {
    app.contacts().request_permissions()
}

#[command]
pub(crate) async fn get_contacts<R: Runtime>(
    app: AppHandle<R>,
    query: Option<ContactQuery>,
) -> Result<Vec<Contact>> {
    app.contacts().get_contacts(query)
}

#[command]
pub(crate) async fn get_contact<R: Runtime>(
    app: AppHandle<R>,
    id: String,
) -> Result<Contact> {
    app.contacts().get_contact(&id)
}

#[command]
pub(crate) async fn create_contact<R: Runtime>(
    app: AppHandle<R>,
    contact: NewContact,
) -> Result<Contact> {
    app.contacts().create_contact(contact)
}

#[command]
pub(crate) async fn update_contact<R: Runtime>(
    app: AppHandle<R>,
    contact: Contact,
) -> Result<Contact> {
    app.contacts().update_contact(contact)
}

#[command]
pub(crate) async fn delete_contact<R: Runtime>(
    app: AppHandle<R>,
    id: String,
) -> Result<()> {
    app.contacts().delete_contact(&id)
}

#[command]
pub(crate) async fn get_groups<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<ContactGroup>> {
    app.contacts().get_groups()
}

#[command]
pub(crate) async fn create_group<R: Runtime>(
    app: AppHandle<R>,
    name: String,
) -> Result<ContactGroup> {
    app.contacts().create_group(&name)
}

#[command]
pub(crate) async fn update_group<R: Runtime>(
    app: AppHandle<R>,
    group_id: String,
    name: String,
) -> Result<ContactGroup> {
    app.contacts().update_group(&group_id, &name)
}

#[command]
pub(crate) async fn delete_group<R: Runtime>(
    app: AppHandle<R>,
    group_id: String,
) -> Result<()> {
    app.contacts().delete_group(&group_id)
}

#[command]
pub(crate) async fn add_contact_to_group<R: Runtime>(
    app: AppHandle<R>,
    contact_id: String,
    group_id: String,
) -> Result<()> {
    app.contacts().add_contact_to_group(&contact_id, &group_id)
}

#[command]
pub(crate) async fn remove_contact_from_group<R: Runtime>(
    app: AppHandle<R>,
    contact_id: String,
    group_id: String,
) -> Result<()> {
    app.contacts().remove_contact_from_group(&contact_id, &group_id)
}