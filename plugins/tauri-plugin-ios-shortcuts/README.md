# Tauri Plugin iOS Shortcuts

A Tauri plugin for iOS Shortcuts (Siri Shortcuts) integration, enabling voice commands and app shortcuts.

## Features

- Create and manage Siri Shortcuts
- Donate interactions to Siri
- Handle user activities
- Support for App Intents
- Voice shortcut management
- Shortcut predictions
- Intent handling and responses

## Installation

Add the plugin to your Tauri project:

```toml
[dependencies]
tauri-plugin-ios-shortcuts = { path = "../path/to/plugin" }
```

## Usage

```rust
use tauri_plugin_ios_shortcuts::{ShortcutsExt, Shortcut, Intent, IntentCategory};
use std::collections::HashMap;

#[tauri::command]
async fn create_shortcut<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    let shortcut = Shortcut {
        identifier: "open-favorite".to_string(),
        title: "Open Favorite Item".to_string(),
        suggested_invocation_phrase: Some("Open my favorite".to_string()),
        is_eligible_for_search: true,
        is_eligible_for_prediction: true,
        user_activity_type: "com.myapp.open-favorite".to_string(),
        user_info: HashMap::new(),
        persistent_identifier: Some("favorite-1".to_string()),
    };
    
    app.shortcuts()
        .donate_shortcut(shortcut)
        .map_err(|e| e.to_string())?;
    
    Ok(())
}

#[tauri::command]
async fn create_intent<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    use tauri_plugin_ios_shortcuts::{Intent, IntentParameter};
    
    let mut parameters = HashMap::new();
    parameters.insert("item".to_string(), IntentParameter {
        name: "item".to_string(),
        value: serde_json::json!("favorite"),
        display_name: "Item to open".to_string(),
        prompt: Some("Which item would you like to open?".to_string()),
    });
    
    let intent = Intent {
        identifier: "OpenItemIntent".to_string(),
        display_name: "Open Item".to_string(),
        category: IntentCategory::Search,
        parameters,
        suggested_invocation_phrase: Some("Open item".to_string()),
        image: None,
    };
    
    let interaction = Interaction {
        intent,
        donation_date: None,
        shortcut: None,
    };
    
    app.shortcuts()
        .donate_interaction(interaction)
        .map_err(|e| e.to_string())?;
    
    Ok(())
}
```

## Managing Voice Shortcuts

```rust
#[tauri::command]
async fn get_voice_shortcuts<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<Vec<VoiceShortcut>, String> {
    app.shortcuts()
        .get_voice_shortcuts()
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn suggest_shortcut_phrase<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    shortcut_id: String,
) -> Result<String, String> {
    app.shortcuts()
        .suggest_phrase(shortcut_id)
        .map_err(|e| e.to_string())
}
```

## User Activities

```rust
use tauri_plugin_ios_shortcuts::{UserActivity, ContentAttributes};

#[tauri::command]
async fn create_user_activity<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    let mut keywords = vec!["search".to_string(), "find".to_string()];
    
    let activity = UserActivity {
        activity_type: "com.myapp.search".to_string(),
        title: "Search Items".to_string(),
        user_info: HashMap::new(),
        keywords,
        persistent_identifier: Some("search-activity".to_string()),
        is_eligible_for_search: true,
        is_eligible_for_public_indexing: false,
        is_eligible_for_handoff: true,
        is_eligible_for_prediction: true,
        content_attributes: Some(ContentAttributes {
            title: Some("Search".to_string()),
            content_description: Some("Search for items in the app".to_string()),
            thumbnail_data: None,
            thumbnail_url: None,
            keywords: vec!["search".to_string()],
        }),
        required_user_info_keys: vec![],
    };
    
    app.shortcuts()
        .handle_user_activity(activity)
        .map_err(|e| e.to_string())
}
```

## App Intents

```rust
use tauri_plugin_ios_shortcuts::{AppIntent, ParameterDefinition, ParameterType, ParameterOption};

#[tauri::command]
async fn register_app_intents<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    let intent = AppIntent {
        identifier: "PlayMusicIntent".to_string(),
        display_name: "Play Music".to_string(),
        description: "Play a specific song or playlist".to_string(),
        category: IntentCategory::Play,
        parameter_definitions: vec![
            ParameterDefinition {
                name: "song".to_string(),
                display_name: "Song".to_string(),
                description: "The song to play".to_string(),
                parameter_type: ParameterType::String,
                is_required: false,
                default_value: None,
                options: vec![
                    ParameterOption {
                        identifier: "favorite".to_string(),
                        display_name: "Favorite Song".to_string(),
                        synonyms: vec!["fav".to_string(), "best".to_string()],
                    }
                ],
            }
        ],
        response_template: Some("Playing {song}".to_string()),
    };
    
    app.shortcuts()
        .register_app_intents(vec![intent])
        .map_err(|e| e.to_string())
}
```

## Handling Intents

```rust
#[tauri::command]
async fn handle_intent<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    intent_id: String,
    parameters: HashMap<String, serde_json::Value>,
) -> Result<IntentResponse, String> {
    let response = app.shortcuts()
        .handle_intent(intent_id, parameters)
        .map_err(|e| e.to_string())?;
    
    Ok(response)
}
```

## Platform Support

This plugin only supports iOS. Desktop platforms will return `NotSupported` errors.

## Permissions

### iOS

Add to your `Info.plist`:

```xml
<key>NSUserActivityTypes</key>
<array>
    <string>com.yourapp.activity1</string>
    <string>com.yourapp.activity2</string>
</array>
```

For Siri integration:
```xml
<key>NSSiriUsageDescription</key>
<string>This app uses Siri to create voice shortcuts</string>
```

## Intent Categories

- `Information` - General information queries
- `Play` - Media playback
- `Order` - Ordering actions
- `Message` - Messaging
- `Call` - Phone calls
- `Search` - Search actions
- `Create` - Creating content
- `Share` - Sharing content
- `Toggle` - On/off actions
- `Download` - Download actions
- `Custom(String)` - Custom categories

## Best Practices

1. **Donate shortcuts regularly** - When users perform actions they might want to repeat
2. **Use clear phrases** - Suggested invocation phrases should be natural
3. **Provide good descriptions** - Help users understand what shortcuts do
4. **Update shortcuts** - Keep shortcuts current with user preferences
5. **Handle failures gracefully** - Shortcuts may fail if the app state changes
6. **Test with Siri** - Ensure voice commands work as expected

## Example: Music Player Shortcuts

```rust
pub struct MusicShortcuts;

impl MusicShortcuts {
    pub async fn donate_play_playlist<R: Runtime>(
        app: &AppHandle<R>,
        playlist_name: String,
        playlist_id: String,
    ) -> Result<(), String> {
        let mut user_info = HashMap::new();
        user_info.insert("playlist_id".to_string(), serde_json::json!(playlist_id));
        user_info.insert("playlist_name".to_string(), serde_json::json!(playlist_name));
        
        let shortcut = Shortcut {
            identifier: format!("play-playlist-{}", playlist_id),
            title: format!("Play {}", playlist_name),
            suggested_invocation_phrase: Some(format!("Play my {} playlist", playlist_name)),
            is_eligible_for_search: true,
            is_eligible_for_prediction: true,
            user_activity_type: "com.myapp.play-playlist".to_string(),
            user_info,
            persistent_identifier: Some(playlist_id.clone()),
        };
        
        app.shortcuts()
            .donate_shortcut(shortcut)
            .map_err(|e| e.to_string())
    }
    
    pub async fn donate_recent_playback<R: Runtime>(
        app: &AppHandle<R>,
        song_name: String,
        artist: String,
    ) -> Result<(), String> {
        let intent = Intent {
            identifier: "PlaySongIntent".to_string(),
            display_name: format!("Play {} by {}", song_name, artist),
            category: IntentCategory::Play,
            parameters: HashMap::new(),
            suggested_invocation_phrase: Some(format!("Play {}", song_name)),
            image: None,
        };
        
        let interaction = Interaction {
            intent,
            donation_date: None,
            shortcut: None,
        };
        
        app.shortcuts()
            .donate_interaction(interaction)
            .map_err(|e| e.to_string())
    }
}
```