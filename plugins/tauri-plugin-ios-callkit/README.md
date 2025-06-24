# Tauri Plugin iOS CallKit

A Tauri plugin for iOS CallKit integration, enabling VoIP calling and call management features.

## Features

- Native iOS call UI integration
- Incoming and outgoing call handling
- Call state management (hold, mute, etc.)
- Audio session configuration
- VoIP push notification support
- Multiple call handling and grouping
- Audio route management
- Call history integration

## Installation

Add the plugin to your Tauri project:

```toml
[dependencies]
tauri-plugin-ios-callkit = { path = "../path/to/plugin" }
```

## Usage

```rust
use tauri_plugin_ios_callkit::{CallKitExt, ProviderConfiguration, IncomingCallInfo, CallHandle, HandleType};
use uuid::Uuid;

#[tauri::command]
async fn setup_callkit<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    // Configure the provider
    let config = ProviderConfiguration {
        localized_name: "My VoIP App".to_string(),
        ringtone_sound: Some("ringtone.caf".to_string()),
        icon_template_image: None,
        maximum_call_groups: 2,
        maximum_calls_per_group: 5,
        supports_video: true,
        include_calls_in_recents: true,
        supported_handle_types: vec![HandleType::PhoneNumber, HandleType::EmailAddress],
    };
    
    app.callkit()
        .set_provider_configuration(config)
        .map_err(|e| e.to_string())?;
    
    // Configure audio session
    use tauri_plugin_ios_callkit::{AudioSessionConfiguration, AudioSessionCategory, AudioSessionMode, AudioSessionOption};
    
    let audio_config = AudioSessionConfiguration {
        category: AudioSessionCategory::PlayAndRecord,
        mode: AudioSessionMode::VoiceChat,
        options: vec![
            AudioSessionOption::AllowBluetooth,
            AudioSessionOption::DefaultToSpeaker,
        ],
    };
    
    app.callkit()
        .configure_audio_session(audio_config)
        .map_err(|e| e.to_string())?;
    
    Ok(())
}

#[tauri::command]
async fn report_incoming_call<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    caller_number: String,
    caller_name: Option<String>,
) -> Result<String, String> {
    let call_uuid = Uuid::new_v4().to_string();
    
    let info = IncomingCallInfo {
        uuid: call_uuid.clone(),
        handle: CallHandle {
            handle_type: HandleType::PhoneNumber,
            value: caller_number,
        },
        has_video: false,
        caller_name,
        supports_dtmf: true,
        supports_holding: true,
        supports_grouping: true,
        supports_ungrouping: true,
    };
    
    app.callkit()
        .report_incoming_call(info)
        .map_err(|e| e.to_string())?;
    
    Ok(call_uuid)
}
```

## Events

The plugin emits various events to track call state:

```rust
// Listen for call events
app.listen_global("callStarted", |event| {
    println!("Call started: {:?}", event.payload());
});

app.listen_global("callAnswered", |event| {
    println!("Call answered: {:?}", event.payload());
});

app.listen_global("callEnded", |event| {
    println!("Call ended: {:?}", event.payload());
});

app.listen_global("callHeld", |event| {
    println!("Call held state changed: {:?}", event.payload());
});

app.listen_global("callMuted", |event| {
    println!("Call mute state changed: {:?}", event.payload());
});
```

## VoIP Push Notifications

To receive calls when the app is not running:

```rust
#[tauri::command]
async fn setup_voip_push<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<String, String> {
    // Register for VoIP push notifications
    let token = app.callkit()
        .register_for_voip_notifications()
        .map_err(|e| e.to_string())?;
    
    // Send this token to your server
    println!("VoIP push token: {}", token);
    
    Ok(token)
}

// Handle incoming VoIP push
#[tauri::command]
async fn handle_voip_push<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    payload: VoipPushPayload,
) -> Result<(), String> {
    app.callkit()
        .report_new_incoming_voip_push(payload)
        .map_err(|e| e.to_string())
}
```

## Call Management

```rust
use tauri_plugin_ios_callkit::CallFailureReason;

#[tauri::command]
async fn answer_call<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    call_uuid: String,
) -> Result<(), String> {
    app.callkit()
        .answer_call(call_uuid)
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn end_call<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    call_uuid: String,
) -> Result<(), String> {
    app.callkit()
        .end_call(call_uuid, Some(CallFailureReason::RemoteEnded))
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn toggle_mute<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    call_uuid: String,
    muted: bool,
) -> Result<(), String> {
    app.callkit()
        .set_muted(call_uuid, muted)
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn toggle_hold<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    call_uuid: String,
    on_hold: bool,
) -> Result<(), String> {
    app.callkit()
        .set_held(call_uuid, on_hold)
        .map_err(|e| e.to_string())
}
```

## Audio Route Management

```rust
use tauri_plugin_ios_callkit::AudioRouteType;

#[tauri::command]
async fn get_audio_routes<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<Vec<AudioRoute>, String> {
    app.callkit()
        .get_audio_routes()
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn set_speaker<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    enabled: bool,
) -> Result<(), String> {
    let route = if enabled {
        AudioRouteType::BuiltInSpeaker
    } else {
        AudioRouteType::BuiltInReceiver
    };
    
    app.callkit()
        .set_audio_route(route)
        .map_err(|e| e.to_string())
}
```

## Platform Support

This plugin only supports iOS. Desktop platforms will return `NotSupported` errors.

## Permissions

### iOS

Add to your `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
    <string>audio</string>
</array>
```

### Required Capabilities

Add to your app's entitlements:

```xml
<key>com.apple.developer.pushkit.unrestricted-voip</key>
<true/>
```

## Important Notes

1. **VoIP Certificate**: You need a VoIP Services certificate from Apple Developer Portal
2. **Push Notifications**: VoIP pushes must report an incoming call or the app will be terminated
3. **Background Execution**: CallKit provides special background execution privileges
4. **Audio Session**: The audio session is managed by CallKit during calls
5. **Call Directory**: For call blocking and identification, use the Call Directory Extension

## Example: Complete VoIP App

```rust
use tauri_plugin_ios_callkit::*;

pub struct CallManager {
    active_calls: HashMap<String, CallInfo>,
}

impl CallManager {
    pub async fn handle_incoming_call<R: Runtime>(
        &mut self,
        app: &AppHandle<R>,
        from: String,
        name: Option<String>,
    ) -> Result<String, String> {
        let uuid = Uuid::new_v4().to_string();
        
        // Report to CallKit
        let info = IncomingCallInfo {
            uuid: uuid.clone(),
            handle: CallHandle {
                handle_type: HandleType::PhoneNumber,
                value: from.clone(),
            },
            has_video: false,
            caller_name: name,
            supports_dtmf: true,
            supports_holding: true,
            supports_grouping: true,
            supports_ungrouping: true,
        };
        
        app.callkit()
            .report_incoming_call(info)
            .map_err(|e| e.to_string())?;
        
        // Store call info
        self.active_calls.insert(uuid.clone(), CallInfo {
            uuid: uuid.clone(),
            remote_number: from,
            incoming: true,
            start_time: None,
        });
        
        Ok(uuid)
    }
    
    pub async fn make_outgoing_call<R: Runtime>(
        &mut self,
        app: &AppHandle<R>,
        to: String,
    ) -> Result<String, String> {
        let uuid = Uuid::new_v4().to_string();
        
        // Report to CallKit
        let info = OutgoingCallInfo {
            uuid: uuid.clone(),
            handle: CallHandle {
                handle_type: HandleType::PhoneNumber,
                value: to.clone(),
            },
            has_video: false,
            contact_identifier: None,
        };
        
        app.callkit()
            .report_outgoing_call(info)
            .map_err(|e| e.to_string())?;
        
        // Store call info
        self.active_calls.insert(uuid.clone(), CallInfo {
            uuid: uuid.clone(),
            remote_number: to,
            incoming: false,
            start_time: None,
        });
        
        Ok(uuid)
    }
}
```