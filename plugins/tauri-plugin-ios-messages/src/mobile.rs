use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_messages);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Messages<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_messages)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.messages", "MessagesPlugin")?;
    
    Ok(Messages(handle))
}

/// Access to the Messages APIs on mobile.
pub struct Messages<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Messages<R> {
    pub fn compose_message(&self, request: ComposeMessageRequest) -> Result<ComposeResult> {
        self.0
            .run_mobile_plugin("composeMessage", request)
            .map_err(Into::into)
    }
    
    pub fn compose_imessage(&self, request: ComposeMessageRequest) -> Result<ComposeResult> {
        self.0
            .run_mobile_plugin("composeImessage", request)
            .map_err(Into::into)
    }
    
    pub fn send_sms(&self, request: SendSmsRequest) -> Result<String> {
        self.0
            .run_mobile_plugin("sendSms", request)
            .map_err(Into::into)
    }
    
    pub fn can_send_text(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("canSendText", ())
            .map_err(Into::into)
    }
    
    pub fn can_send_subject(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("canSendSubject", ())
            .map_err(Into::into)
    }
    
    pub fn can_send_attachments(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("canSendAttachments", ())
            .map_err(Into::into)
    }
    
    pub fn get_conversation_list(&self, filter: Option<ConversationFilter>) -> Result<Vec<Conversation>> {
        #[derive(serde::Serialize)]
        struct Args {
            filter: Option<ConversationFilter>,
        }
        
        self.0
            .run_mobile_plugin("getConversationList", Args { filter })
            .map_err(Into::into)
    }
    
    pub fn get_conversation(&self, conversation_id: String) -> Result<Conversation> {
        #[derive(serde::Serialize)]
        struct Args {
            conversation_id: String,
        }
        
        self.0
            .run_mobile_plugin("getConversation", Args { conversation_id })
            .map_err(Into::into)
    }
    
    pub fn get_messages(&self, conversation_id: String, limit: Option<u32>, before: Option<String>) -> Result<Vec<Message>> {
        #[derive(serde::Serialize)]
        struct Args {
            conversation_id: String,
            limit: Option<u32>,
            before: Option<String>,
        }
        
        self.0
            .run_mobile_plugin("getMessages", Args { conversation_id, limit, before })
            .map_err(Into::into)
    }
    
    pub fn mark_as_read(&self, message_ids: Vec<String>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            message_ids: Vec<String>,
        }
        
        self.0
            .run_mobile_plugin("markAsRead", Args { message_ids })
            .map_err(Into::into)
    }
    
    pub fn delete_message(&self, message_id: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            message_id: String,
        }
        
        self.0
            .run_mobile_plugin("deleteMessage", Args { message_id })
            .map_err(Into::into)
    }
    
    pub fn search_messages(&self, query: SearchQuery) -> Result<Vec<SearchResult>> {
        self.0
            .run_mobile_plugin("searchMessages", query)
            .map_err(Into::into)
    }
    
    pub fn get_attachments(&self, message_id: String) -> Result<Vec<MessageAttachmentInfo>> {
        #[derive(serde::Serialize)]
        struct Args {
            message_id: String,
        }
        
        self.0
            .run_mobile_plugin("getAttachments", Args { message_id })
            .map_err(Into::into)
    }
    
    pub fn save_attachment(&self, attachment_id: String, destination: String) -> Result<String> {
        #[derive(serde::Serialize)]
        struct Args {
            attachment_id: String,
            destination: String,
        }
        
        self.0
            .run_mobile_plugin("saveAttachment", Args { attachment_id, destination })
            .map_err(Into::into)
    }
    
    pub fn get_message_status(&self, message_id: String) -> Result<MessageStatus> {
        #[derive(serde::Serialize)]
        struct Args {
            message_id: String,
        }
        
        self.0
            .run_mobile_plugin("getMessageStatus", Args { message_id })
            .map_err(Into::into)
    }
    
    pub fn register_for_notifications(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("registerForNotifications", ())
            .map_err(Into::into)
    }
    
    pub fn unregister_notifications(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("unregisterNotifications", ())
            .map_err(Into::into)
    }
    
    pub fn check_imessage_availability(&self) -> Result<ImessageCapabilities> {
        self.0
            .run_mobile_plugin("checkImessageAvailability", ())
            .map_err(Into::into)
    }
    
    pub fn get_blocked_contacts(&self) -> Result<Vec<BlockedContact>> {
        self.0
            .run_mobile_plugin("getBlockedContacts", ())
            .map_err(Into::into)
    }
    
    pub fn block_contact(&self, contact_id: String, reason: Option<String>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            contact_id: String,
            reason: Option<String>,
        }
        
        self.0
            .run_mobile_plugin("blockContact", Args { contact_id, reason })
            .map_err(Into::into)
    }
    
    pub fn unblock_contact(&self, contact_id: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            contact_id: String,
        }
        
        self.0
            .run_mobile_plugin("unblockContact", Args { contact_id })
            .map_err(Into::into)
    }
}