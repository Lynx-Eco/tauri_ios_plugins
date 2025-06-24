use serde::{Deserialize, Serialize};
use tauri::plugin::PermissionState;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionStatus {
    pub contacts: PermissionState,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Contact {
    pub id: String,
    pub given_name: Option<String>,
    pub family_name: Option<String>,
    pub middle_name: Option<String>,
    pub nickname: Option<String>,
    pub prefix: Option<String>,
    pub suffix: Option<String>,
    pub organization: Option<String>,
    pub job_title: Option<String>,
    pub department: Option<String>,
    pub note: Option<String>,
    pub birthday: Option<String>,
    pub phone_numbers: Vec<PhoneNumber>,
    pub email_addresses: Vec<EmailAddress>,
    pub postal_addresses: Vec<PostalAddress>,
    pub url_addresses: Vec<UrlAddress>,
    pub social_profiles: Vec<SocialProfile>,
    pub instant_messages: Vec<InstantMessage>,
    pub image_data: Option<String>, // Base64 encoded
    pub thumbnail_image_data: Option<String>, // Base64 encoded
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct NewContact {
    pub given_name: Option<String>,
    pub family_name: Option<String>,
    pub middle_name: Option<String>,
    pub nickname: Option<String>,
    pub prefix: Option<String>,
    pub suffix: Option<String>,
    pub organization: Option<String>,
    pub job_title: Option<String>,
    pub department: Option<String>,
    pub note: Option<String>,
    pub birthday: Option<String>,
    pub phone_numbers: Vec<PhoneNumber>,
    pub email_addresses: Vec<EmailAddress>,
    pub postal_addresses: Vec<PostalAddress>,
    pub url_addresses: Vec<UrlAddress>,
    pub social_profiles: Vec<SocialProfile>,
    pub instant_messages: Vec<InstantMessage>,
    pub image_data: Option<String>, // Base64 encoded
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PhoneNumber {
    pub label: String,
    pub value: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct EmailAddress {
    pub label: String,
    pub value: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PostalAddress {
    pub label: String,
    pub street: Option<String>,
    pub city: Option<String>,
    pub state: Option<String>,
    pub postal_code: Option<String>,
    pub country: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UrlAddress {
    pub label: String,
    pub value: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SocialProfile {
    pub label: String,
    pub service: String,
    pub username: String,
    pub url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstantMessage {
    pub label: String,
    pub service: String,
    pub username: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ContactGroup {
    pub id: String,
    pub name: String,
    pub member_count: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct ContactQuery {
    pub search_text: Option<String>,
    pub group_id: Option<String>,
    pub sort_order: Option<ContactSortOrder>,
    pub include_images: bool,
    pub limit: Option<usize>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum ContactSortOrder {
    GivenName,
    FamilyName,
    None,
}