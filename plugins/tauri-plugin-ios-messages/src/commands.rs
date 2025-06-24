use tauri::{command, AppHandle, Runtime};

use crate::{MessagesExt, ComposeMessageRequest, SendSmsRequest, ConversationFilter, SearchQuery, Result};

#[command]
pub(crate) async fn compose_message<R: Runtime>(
    app: AppHandle<R>,
    request: ComposeMessageRequest,
) -> Result<crate::ComposeResult> {
    app.messages().compose_message(request)
}

#[command]
pub(crate) async fn compose_imessage<R: Runtime>(
    app: AppHandle<R>,
    request: ComposeMessageRequest,
) -> Result<crate::ComposeResult> {
    app.messages().compose_imessage(request)
}

#[command]
pub(crate) async fn send_sms<R: Runtime>(
    app: AppHandle<R>,
    request: SendSmsRequest,
) -> Result<String> {
    app.messages().send_sms(request)
}

#[command]
pub(crate) async fn can_send_text<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.messages().can_send_text()
}

#[command]
pub(crate) async fn can_send_subject<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.messages().can_send_subject()
}

#[command]
pub(crate) async fn can_send_attachments<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.messages().can_send_attachments()
}

#[command]
pub(crate) async fn get_conversation_list<R: Runtime>(
    app: AppHandle<R>,
    filter: Option<ConversationFilter>,
) -> Result<Vec<crate::Conversation>> {
    app.messages().get_conversation_list(filter)
}

#[command]
pub(crate) async fn get_conversation<R: Runtime>(
    app: AppHandle<R>,
    conversation_id: String,
) -> Result<crate::Conversation> {
    app.messages().get_conversation(conversation_id)
}

#[command]
pub(crate) async fn get_messages<R: Runtime>(
    app: AppHandle<R>,
    conversation_id: String,
    limit: Option<u32>,
    before: Option<String>,
) -> Result<Vec<crate::Message>> {
    app.messages().get_messages(conversation_id, limit, before)
}

#[command]
pub(crate) async fn mark_as_read<R: Runtime>(
    app: AppHandle<R>,
    message_ids: Vec<String>,
) -> Result<()> {
    app.messages().mark_as_read(message_ids)
}

#[command]
pub(crate) async fn delete_message<R: Runtime>(
    app: AppHandle<R>,
    message_id: String,
) -> Result<()> {
    app.messages().delete_message(message_id)
}

#[command]
pub(crate) async fn search_messages<R: Runtime>(
    app: AppHandle<R>,
    query: SearchQuery,
) -> Result<Vec<crate::SearchResult>> {
    app.messages().search_messages(query)
}

#[command]
pub(crate) async fn get_attachments<R: Runtime>(
    app: AppHandle<R>,
    message_id: String,
) -> Result<Vec<crate::MessageAttachmentInfo>> {
    app.messages().get_attachments(message_id)
}

#[command]
pub(crate) async fn save_attachment<R: Runtime>(
    app: AppHandle<R>,
    attachment_id: String,
    destination: String,
) -> Result<String> {
    app.messages().save_attachment(attachment_id, destination)
}

#[command]
pub(crate) async fn get_message_status<R: Runtime>(
    app: AppHandle<R>,
    message_id: String,
) -> Result<crate::MessageStatus> {
    app.messages().get_message_status(message_id)
}

#[command]
pub(crate) async fn register_for_notifications<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.messages().register_for_notifications()
}

#[command]
pub(crate) async fn unregister_notifications<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.messages().unregister_notifications()
}

#[command]
pub(crate) async fn check_imessage_availability<R: Runtime>(
    app: AppHandle<R>,
) -> Result<crate::ImessageCapabilities> {
    app.messages().check_imessage_availability()
}

#[command]
pub(crate) async fn get_blocked_contacts<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<crate::BlockedContact>> {
    app.messages().get_blocked_contacts()
}

#[command]
pub(crate) async fn block_contact<R: Runtime>(
    app: AppHandle<R>,
    contact_id: String,
    reason: Option<String>,
) -> Result<()> {
    app.messages().block_contact(contact_id, reason)
}

#[command]
pub(crate) async fn unblock_contact<R: Runtime>(
    app: AppHandle<R>,
    contact_id: String,
) -> Result<()> {
    app.messages().unblock_contact(contact_id)
}