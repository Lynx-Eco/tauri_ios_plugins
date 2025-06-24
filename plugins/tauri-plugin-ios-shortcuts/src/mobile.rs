use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};
use std::collections::HashMap;

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_shortcuts);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Shortcuts<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_shortcuts)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.shortcuts", "ShortcutsPlugin")?;
    
    Ok(Shortcuts(handle))
}

/// Access to the Shortcuts APIs on mobile.
pub struct Shortcuts<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Shortcuts<R> {
    pub fn donate_interaction(&self, interaction: Interaction) -> Result<()> {
        self.0
            .run_mobile_plugin("donateInteraction", interaction)
            .map_err(Into::into)
    }
    
    pub fn donate_shortcut(&self, shortcut: Shortcut) -> Result<()> {
        self.0
            .run_mobile_plugin("donateShortcut", shortcut)
            .map_err(Into::into)
    }
    
    pub fn get_all_shortcuts(&self) -> Result<Vec<Shortcut>> {
        self.0
            .run_mobile_plugin("getAllShortcuts", ())
            .map_err(Into::into)
    }
    
    pub fn delete_shortcut(&self, identifier: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            identifier: String,
        }
        
        self.0
            .run_mobile_plugin("deleteShortcut", Args { identifier })
            .map_err(Into::into)
    }
    
    pub fn delete_all_shortcuts(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("deleteAllShortcuts", ())
            .map_err(Into::into)
    }
    
    pub fn get_voice_shortcuts(&self) -> Result<Vec<VoiceShortcut>> {
        self.0
            .run_mobile_plugin("getVoiceShortcuts", ())
            .map_err(Into::into)
    }
    
    pub fn suggest_phrase(&self, shortcut_identifier: String) -> Result<String> {
        #[derive(serde::Serialize)]
        struct Args {
            shortcut_identifier: String,
        }
        
        self.0
            .run_mobile_plugin("suggestPhrase", Args { shortcut_identifier })
            .map_err(Into::into)
    }
    
    pub fn handle_user_activity(&self, activity: UserActivity) -> Result<()> {
        self.0
            .run_mobile_plugin("handleUserActivity", activity)
            .map_err(Into::into)
    }
    
    pub fn update_shortcut(&self, shortcut: Shortcut) -> Result<()> {
        self.0
            .run_mobile_plugin("updateShortcut", shortcut)
            .map_err(Into::into)
    }
    
    pub fn get_shortcut_suggestions(&self) -> Result<Vec<ShortcutSuggestion>> {
        self.0
            .run_mobile_plugin("getShortcutSuggestions", ())
            .map_err(Into::into)
    }
    
    pub fn set_shortcut_suggestions(&self, suggestions: Vec<ShortcutSuggestion>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            suggestions: Vec<ShortcutSuggestion>,
        }
        
        self.0
            .run_mobile_plugin("setShortcutSuggestions", Args { suggestions })
            .map_err(Into::into)
    }
    
    pub fn create_app_intent(&self, intent: AppIntent) -> Result<String> {
        self.0
            .run_mobile_plugin("createAppIntent", intent)
            .map_err(Into::into)
    }
    
    pub fn register_app_intents(&self, intents: Vec<AppIntent>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            intents: Vec<AppIntent>,
        }
        
        self.0
            .run_mobile_plugin("registerAppIntents", Args { intents })
            .map_err(Into::into)
    }
    
    pub fn handle_intent(&self, intent_id: String, parameters: HashMap<String, serde_json::Value>) -> Result<IntentResponse> {
        #[derive(serde::Serialize)]
        struct Args {
            intent_id: String,
            parameters: HashMap<String, serde_json::Value>,
        }
        
        self.0
            .run_mobile_plugin("handleIntent", Args { intent_id, parameters })
            .map_err(Into::into)
    }
    
    pub fn get_donated_intents(&self) -> Result<Vec<DonatedIntent>> {
        self.0
            .run_mobile_plugin("getDonatedIntents", ())
            .map_err(Into::into)
    }
    
    pub fn delete_donated_intents(&self, identifiers: Vec<String>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            identifiers: Vec<String>,
        }
        
        self.0
            .run_mobile_plugin("deleteDonatedIntents", Args { identifiers })
            .map_err(Into::into)
    }
    
    pub fn set_eligible_for_prediction(&self, intent_ids: Vec<String>, eligible: bool) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            intent_ids: Vec<String>,
            eligible: bool,
        }
        
        self.0
            .run_mobile_plugin("setEligibleForPrediction", Args { intent_ids, eligible })
            .map_err(Into::into)
    }
    
    pub fn get_predictions(&self, limit: Option<u32>) -> Result<Vec<IntentPrediction>> {
        #[derive(serde::Serialize)]
        struct Args {
            limit: Option<u32>,
        }
        
        self.0
            .run_mobile_plugin("getPredictions", Args { limit })
            .map_err(Into::into)
    }
}