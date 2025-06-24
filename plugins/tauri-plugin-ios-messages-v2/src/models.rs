use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ComposeMessageRequest {
    pub recipients: Vec<String>,
    pub body: Option<String>,
    pub subject: Option<String>,
    pub attachments: Vec<MessageAttachment>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MessageAttachment {
    pub data: AttachmentData,
    pub filename: String,
    pub mime_type: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub enum AttachmentData {
    Base64(String),
    Url(String),
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SendSmsRequest {
    pub to: String,
    pub body: String,
    pub send_immediately: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Conversation {
    pub id: String,
    pub participants: Vec<Participant>,
    pub last_message: Option<Message>,
    pub unread_count: u32,
    pub is_pinned: bool,
    pub is_muted: bool,
    pub has_attachments: bool,
    pub conversation_type: ConversationType,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Participant {
    pub id: String,
    pub phone_number: Option<String>,
    pub email: Option<String>,
    pub display_name: Option<String>,
    pub avatar: Option<String>, // base64 image
    pub is_me: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum ConversationType {
    Sms,
    Imessage,
    Group,
    Unknown,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Message {
    pub id: String,
    pub conversation_id: String,
    pub sender: Participant,
    pub body: Option<String>,
    pub timestamp: DateTime<Utc>,
    pub is_from_me: bool,
    pub is_read: bool,
    pub is_delivered: bool,
    pub is_sent: bool,
    pub message_type: MessageType,
    pub attachments: Vec<MessageAttachmentInfo>,
    pub reactions: Vec<MessageReaction>,
    pub thread_identifier: Option<String>,
    pub reply_to_message_id: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum MessageType {
    Text,
    Image,
    Video,
    Audio,
    Location,
    Contact,
    File,
    Sticker,
    Gif,
    Unknown,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MessageAttachmentInfo {
    pub id: String,
    pub filename: String,
    pub mime_type: String,
    pub size: u64,
    pub thumbnail: Option<String>, // base64
    pub url: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MessageReaction {
    pub sender: Participant,
    pub reaction: String, // emoji or reaction type
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MessageStatus {
    pub message_id: String,
    pub is_sent: bool,
    pub is_delivered: bool,
    pub is_read: bool,
    pub delivery_time: Option<DateTime<Utc>>,
    pub read_time: Option<DateTime<Utc>>,
    pub error: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SearchQuery {
    pub query: String,
    pub conversation_id: Option<String>,
    pub sender_id: Option<String>,
    pub date_from: Option<DateTime<Utc>>,
    pub date_to: Option<DateTime<Utc>>,
    pub has_attachments: Option<bool>,
    pub message_types: Vec<MessageType>,
    pub limit: Option<u32>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SearchResult {
    pub message: Message,
    pub snippet: String,
    pub match_ranges: Vec<(usize, usize)>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ConversationFilter {
    pub unread_only: bool,
    pub pinned_only: bool,
    pub conversation_types: Vec<ConversationType>,
    pub participant_ids: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MessageNotification {
    pub conversation_id: String,
    pub message: Message,
    pub notification_type: NotificationType,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum NotificationType {
    NewMessage,
    MessageRead,
    MessageDeleted,
    TypingStarted,
    TypingEnded,
    ReactionAdded,
    ReactionRemoved,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct BlockedContact {
    pub id: String,
    pub phone_number: Option<String>,
    pub email: Option<String>,
    pub display_name: Option<String>,
    pub blocked_date: DateTime<Utc>,
    pub reason: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ComposeResult {
    pub sent: bool,
    pub cancelled: bool,
    pub error: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ImessageCapabilities {
    pub is_available: bool,
    pub is_signed_in: bool,
    pub can_send_messages: bool,
    pub can_receive_messages: bool,
    pub supports_effects: bool,
    pub supports_stickers: bool,
    pub supports_tapback: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MessagingCapabilities {
    pub can_send_text: bool,
    pub can_send_subject: bool,
    pub can_send_attachments: bool,
    pub max_attachment_count: u32,
    pub supported_attachment_types: Vec<String>,
}

impl Default for ConversationFilter {
    fn default() -> Self {
        Self {
            unread_only: false,
            pinned_only: false,
            conversation_types: vec![],
            participant_ids: vec![],
        }
    }
}

impl Default for SearchQuery {
    fn default() -> Self {
        Self {
            query: String::new(),
            conversation_id: None,
            sender_id: None,
            date_from: None,
            date_to: None,
            has_attachments: None,
            message_types: vec![],
            limit: Some(50),
        }
    }
}