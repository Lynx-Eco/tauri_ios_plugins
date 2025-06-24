use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Messages<R>> {
    Ok(Messages(app.clone()))
}

/// Access to the Messages APIs on desktop (returns errors as not available).
pub struct Messages<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Messages<R> {
    pub fn compose_message(&self, _request: ComposeMessageRequest) -> Result<ComposeResult> {
        Err(Error::NotAvailable)
    }
    
    pub fn compose_imessage(&self, _request: ComposeMessageRequest) -> Result<ComposeResult> {
        Err(Error::NotAvailable)
    }
    
    pub fn send_sms(&self, _request: SendSmsRequest) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn can_send_text(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn can_send_subject(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn can_send_attachments(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn get_conversation_list(&self, _filter: Option<ConversationFilter>) -> Result<Vec<Conversation>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_conversation(&self, _conversation_id: String) -> Result<Conversation> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_messages(&self, _conversation_id: String, _limit: Option<u32>, _before: Option<String>) -> Result<Vec<Message>> {
        Err(Error::NotAvailable)
    }
    
    pub fn mark_as_read(&self, _message_ids: Vec<String>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn delete_message(&self, _message_id: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn search_messages(&self, _query: SearchQuery) -> Result<Vec<SearchResult>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_attachments(&self, _message_id: String) -> Result<Vec<MessageAttachmentInfo>> {
        Err(Error::NotAvailable)
    }
    
    pub fn save_attachment(&self, _attachment_id: String, _destination: String) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_message_status(&self, _message_id: String) -> Result<MessageStatus> {
        Err(Error::NotAvailable)
    }
    
    pub fn register_for_notifications(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn unregister_notifications(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn check_imessage_availability(&self) -> Result<ImessageCapabilities> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_blocked_contacts(&self) -> Result<Vec<BlockedContact>> {
        Err(Error::NotAvailable)
    }
    
    pub fn block_contact(&self, _contact_id: String, _reason: Option<String>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn unblock_contact(&self, _contact_id: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
}