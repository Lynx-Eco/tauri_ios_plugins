use tauri::{command, AppHandle, Runtime};
use std::collections::HashMap;

use crate::{ShortcutsExt, Interaction, Shortcut, UserActivity, ShortcutSuggestion, AppIntent, Result};

#[command]
pub(crate) async fn donate_interaction<R: Runtime>(
    app: AppHandle<R>,
    interaction: Interaction,
) -> Result<()> {
    app.shortcuts().donate_interaction(interaction)
}

#[command]
pub(crate) async fn donate_shortcut<R: Runtime>(
    app: AppHandle<R>,
    shortcut: Shortcut,
) -> Result<()> {
    app.shortcuts().donate_shortcut(shortcut)
}

#[command]
pub(crate) async fn get_all_shortcuts<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<Shortcut>> {
    app.shortcuts().get_all_shortcuts()
}

#[command]
pub(crate) async fn delete_shortcut<R: Runtime>(
    app: AppHandle<R>,
    identifier: String,
) -> Result<()> {
    app.shortcuts().delete_shortcut(identifier)
}

#[command]
pub(crate) async fn delete_all_shortcuts<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.shortcuts().delete_all_shortcuts()
}

#[command]
pub(crate) async fn get_voice_shortcuts<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<crate::VoiceShortcut>> {
    app.shortcuts().get_voice_shortcuts()
}

#[command]
pub(crate) async fn suggest_phrase<R: Runtime>(
    app: AppHandle<R>,
    shortcut_identifier: String,
) -> Result<String> {
    app.shortcuts().suggest_phrase(shortcut_identifier)
}

#[command]
pub(crate) async fn handle_user_activity<R: Runtime>(
    app: AppHandle<R>,
    activity: UserActivity,
) -> Result<()> {
    app.shortcuts().handle_user_activity(activity)
}

#[command]
pub(crate) async fn update_shortcut<R: Runtime>(
    app: AppHandle<R>,
    shortcut: Shortcut,
) -> Result<()> {
    app.shortcuts().update_shortcut(shortcut)
}

#[command]
pub(crate) async fn get_shortcut_suggestions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<ShortcutSuggestion>> {
    app.shortcuts().get_shortcut_suggestions()
}

#[command]
pub(crate) async fn set_shortcut_suggestions<R: Runtime>(
    app: AppHandle<R>,
    suggestions: Vec<ShortcutSuggestion>,
) -> Result<()> {
    app.shortcuts().set_shortcut_suggestions(suggestions)
}

#[command]
pub(crate) async fn create_app_intent<R: Runtime>(
    app: AppHandle<R>,
    intent: AppIntent,
) -> Result<String> {
    app.shortcuts().create_app_intent(intent)
}

#[command]
pub(crate) async fn register_app_intents<R: Runtime>(
    app: AppHandle<R>,
    intents: Vec<AppIntent>,
) -> Result<()> {
    app.shortcuts().register_app_intents(intents)
}

#[command]
pub(crate) async fn handle_intent<R: Runtime>(
    app: AppHandle<R>,
    intent_id: String,
    parameters: HashMap<String, serde_json::Value>,
) -> Result<crate::IntentResponse> {
    app.shortcuts().handle_intent(intent_id, parameters)
}

#[command]
pub(crate) async fn get_donated_intents<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<crate::DonatedIntent>> {
    app.shortcuts().get_donated_intents()
}

#[command]
pub(crate) async fn delete_donated_intents<R: Runtime>(
    app: AppHandle<R>,
    identifiers: Vec<String>,
) -> Result<()> {
    app.shortcuts().delete_donated_intents(identifiers)
}

#[command]
pub(crate) async fn set_eligible_for_prediction<R: Runtime>(
    app: AppHandle<R>,
    intent_ids: Vec<String>,
    eligible: bool,
) -> Result<()> {
    app.shortcuts().set_eligible_for_prediction(intent_ids, eligible)
}

#[command]
pub(crate) async fn get_predictions<R: Runtime>(
    app: AppHandle<R>,
    limit: Option<u32>,
) -> Result<Vec<crate::IntentPrediction>> {
    app.shortcuts().get_predictions(limit)
}