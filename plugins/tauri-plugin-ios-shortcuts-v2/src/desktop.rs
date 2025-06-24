use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};
use std::collections::HashMap;

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Shortcuts<R>> {
    Ok(Shortcuts(app.clone()))
}

/// Access to the Shortcuts APIs on desktop (returns errors as not available).
pub struct Shortcuts<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Shortcuts<R> {
    pub fn donate_interaction(&self, _interaction: Interaction) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn donate_shortcut(&self, _shortcut: Shortcut) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_all_shortcuts(&self) -> Result<Vec<Shortcut>> {
        Err(Error::NotAvailable)
    }
    
    pub fn delete_shortcut(&self, _identifier: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn delete_all_shortcuts(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_voice_shortcuts(&self) -> Result<Vec<VoiceShortcut>> {
        Err(Error::NotAvailable)
    }
    
    pub fn suggest_phrase(&self, _shortcut_identifier: String) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn handle_user_activity(&self, _activity: UserActivity) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn update_shortcut(&self, _shortcut: Shortcut) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_shortcut_suggestions(&self) -> Result<Vec<ShortcutSuggestion>> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_shortcut_suggestions(&self, _suggestions: Vec<ShortcutSuggestion>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn create_app_intent(&self, _intent: AppIntent) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn register_app_intents(&self, _intents: Vec<AppIntent>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn handle_intent(&self, _intent_id: String, _parameters: HashMap<String, serde_json::Value>) -> Result<IntentResponse> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_donated_intents(&self) -> Result<Vec<DonatedIntent>> {
        Err(Error::NotAvailable)
    }
    
    pub fn delete_donated_intents(&self, _identifiers: Vec<String>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_eligible_for_prediction(&self, _intent_ids: Vec<String>, _eligible: bool) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_predictions(&self, _limit: Option<u32>) -> Result<Vec<IntentPrediction>> {
        Err(Error::NotAvailable)
    }
}