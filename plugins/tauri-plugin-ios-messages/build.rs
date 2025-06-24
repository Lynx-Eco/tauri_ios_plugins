const COMMANDS: &[&str] = &[
    "compose_message",
    "compose_imessage",
    "send_sms",
    "can_send_text",
    "can_send_subject",
    "can_send_attachments",
    "get_conversation_list",
    "get_conversation",
    "get_messages",
    "mark_as_read",
    "delete_message",
    "search_messages",
    "get_attachments",
    "save_attachment",
    "get_message_status",
    "register_for_notifications",
    "unregister_notifications",
    "check_imessage_availability",
    "get_blocked_contacts",
    "block_contact",
    "unblock_contact",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}