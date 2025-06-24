# Tauri Plugin iOS Messages

A Tauri plugin for iOS Messages app integration and SMS/iMessage functionality.

## Features

- Compose and send SMS/iMessage messages
- Support for message attachments
- Check messaging capabilities
- Message composer with pre-filled recipients and content
- iMessage availability detection

## Limitations

Due to iOS privacy and security restrictions, this plugin has limited functionality compared to other platforms:

- **No message history access**: iOS doesn't allow apps to read existing messages
- **No direct message sending**: Messages must be sent through the system UI
- **No conversation management**: Cannot access or modify conversations
- **No contact blocking**: Cannot programmatically block/unblock contacts
- **User interaction required**: All messaging requires user confirmation

## Installation

Add the plugin to your Tauri project:

```toml
[dependencies]
tauri-plugin-ios-messages = { path = "../path/to/plugin" }
```

## Usage

```rust
use tauri_plugin_ios_messages::{MessagesExt, ComposeMessageRequest, MessageAttachment, AttachmentData};

#[tauri::command]
async fn send_message<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<ComposeResult, String> {
    let request = ComposeMessageRequest {
        recipients: vec!["+1234567890".to_string()],
        body: Some("Hello from Tauri!".to_string()),
        subject: None,
        attachments: vec![],
    };
    
    app.messages()
        .compose_message(request)
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn send_with_image<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    image_base64: String,
) -> Result<ComposeResult, String> {
    let request = ComposeMessageRequest {
        recipients: vec!["+1234567890".to_string()],
        body: Some("Check out this image!".to_string()),
        subject: None,
        attachments: vec![
            MessageAttachment {
                data: AttachmentData::Base64(image_base64),
                filename: "image.jpg".to_string(),
                mime_type: "image/jpeg".to_string(),
            }
        ],
    };
    
    app.messages()
        .compose_message(request)
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn check_messaging<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    let messages = app.messages();
    
    // Check capabilities
    let can_send = messages.can_send_text().unwrap_or(false);
    let can_send_subject = messages.can_send_subject().unwrap_or(false);
    let can_send_attachments = messages.can_send_attachments().unwrap_or(false);
    
    println!("Can send text: {}", can_send);
    println!("Can send subject: {}", can_send_subject);
    println!("Can send attachments: {}", can_send_attachments);
    
    // Check iMessage
    let imessage = messages.check_imessage_availability()
        .map_err(|e| e.to_string())?;
    
    println!("iMessage available: {}", imessage.is_available);
    
    Ok(())
}
```

## API Methods

### Composing Messages
- `compose_message(request)` - Open message composer
- `compose_imessage(request)` - Same as compose_message (iOS decides SMS vs iMessage)
- `send_sms(request)` - Compose SMS (cannot send directly)

### Capabilities
- `can_send_text()` - Check if device can send text messages
- `can_send_subject()` - Check if subjects are supported
- `can_send_attachments()` - Check if attachments are supported
- `check_imessage_availability()` - Get iMessage capabilities

### Unsupported Methods

These methods exist for API compatibility but return errors on iOS:
- `get_conversation_list()` - No access to conversations
- `get_conversation()` - No access to conversations
- `get_messages()` - No access to message history
- `mark_as_read()` - Cannot modify messages
- `delete_message()` - Cannot delete messages
- `search_messages()` - No message search access
- `get_attachments()` - No attachment access
- `save_attachment()` - Cannot save attachments
- `get_message_status()` - No status access
- `get_blocked_contacts()` - No blocked list access
- `block_contact()` - Cannot block contacts
- `unblock_contact()` - Cannot unblock contacts

## Attachment Support

Attachments can be added to messages in two formats:

```rust
pub enum AttachmentData {
    Base64(String),  // Base64 encoded data
    Url(String),     // URL to local file
}
```

Supported attachment types depend on the recipient and message type.

## Compose Result

The compose result indicates the outcome:

```rust
pub struct ComposeResult {
    pub sent: bool,       // True if user sent the message
    pub cancelled: bool,  // True if user cancelled
    pub error: Option<String>, // Error message if failed
}
```

## Example: Message Composer

```rust
use tauri_plugin_ios_messages::{MessagesExt, ComposeMessageRequest};

#[tauri::command]
async fn share_via_message<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    content: String,
) -> Result<bool, String> {
    // Check if messaging is available
    if !app.messages().can_send_text().unwrap_or(false) {
        return Err("Messaging not available".to_string());
    }
    
    let request = ComposeMessageRequest {
        recipients: vec![], // Let user choose
        body: Some(content),
        subject: None,
        attachments: vec![],
    };
    
    let result = app.messages()
        .compose_message(request)
        .map_err(|e| e.to_string())?;
    
    Ok(result.sent)
}
```

## Platform Support

This plugin only supports iOS. Desktop platforms will return `NotSupported` errors.

## Privacy Considerations

iOS has strict privacy controls around messaging:
- Apps cannot access message content or history
- All messaging requires explicit user interaction
- No background message sending is allowed
- Contact information is protected

These restrictions are by design for user privacy and security.