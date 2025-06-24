use tauri::{command, AppHandle, Runtime};

use crate::{CallKitExt, AudioSessionConfiguration, IncomingCallInfo, OutgoingCallInfo, CallUpdate, CallFailureReason, Transaction, AudioRoute, ProviderConfiguration, VoipPushPayload, AudioRouteType, Result};

#[command]
pub(crate) async fn configure_audio_session<R: Runtime>(
    app: AppHandle<R>,
    config: AudioSessionConfiguration,
) -> Result<()> {
    app.callkit().configure_audio_session(config)
}

#[command]
pub(crate) async fn report_incoming_call<R: Runtime>(
    app: AppHandle<R>,
    info: IncomingCallInfo,
) -> Result<()> {
    app.callkit().report_incoming_call(info)
}

#[command]
pub(crate) async fn report_outgoing_call<R: Runtime>(
    app: AppHandle<R>,
    info: OutgoingCallInfo,
) -> Result<()> {
    app.callkit().report_outgoing_call(info)
}

#[command]
pub(crate) async fn end_call<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
    reason: Option<CallFailureReason>,
) -> Result<()> {
    app.callkit().end_call(uuid, reason)
}

#[command]
pub(crate) async fn set_held<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
    on_hold: bool,
) -> Result<()> {
    app.callkit().set_held(uuid, on_hold)
}

#[command]
pub(crate) async fn set_muted<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
    muted: bool,
) -> Result<()> {
    app.callkit().set_muted(uuid, muted)
}

#[command]
pub(crate) async fn set_group<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
    group_uuid: Option<String>,
) -> Result<()> {
    app.callkit().set_group(uuid, group_uuid)
}

#[command]
pub(crate) async fn set_on_hold<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
    on_hold: bool,
) -> Result<()> {
    app.callkit().set_on_hold(uuid, on_hold)
}

#[command]
pub(crate) async fn start_call_audio<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
) -> Result<()> {
    app.callkit().start_call_audio(uuid)
}

#[command]
pub(crate) async fn answer_call<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
) -> Result<()> {
    app.callkit().answer_call(uuid)
}

#[command]
pub(crate) async fn report_call_update<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
    update: CallUpdate,
) -> Result<()> {
    app.callkit().report_call_update(uuid, update)
}

#[command]
pub(crate) async fn get_active_calls<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<crate::Call>> {
    app.callkit().get_active_calls()
}

#[command]
pub(crate) async fn get_call_state<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
) -> Result<crate::CallState> {
    app.callkit().get_call_state(uuid)
}

#[command]
pub(crate) async fn request_transaction<R: Runtime>(
    app: AppHandle<R>,
    transaction: Transaction,
) -> Result<()> {
    app.callkit().request_transaction(transaction)
}

#[command]
pub(crate) async fn report_audio_route_change<R: Runtime>(
    app: AppHandle<R>,
    route: AudioRoute,
) -> Result<()> {
    app.callkit().report_audio_route_change(route)
}

#[command]
pub(crate) async fn set_provider_configuration<R: Runtime>(
    app: AppHandle<R>,
    config: ProviderConfiguration,
) -> Result<()> {
    app.callkit().set_provider_configuration(config)
}

#[command]
pub(crate) async fn register_for_voip_notifications<R: Runtime>(
    app: AppHandle<R>,
) -> Result<String> {
    app.callkit().register_for_voip_notifications()
}

#[command]
pub(crate) async fn invalidate_push_token<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.callkit().invalidate_push_token()
}

#[command]
pub(crate) async fn report_new_incoming_voip_push<R: Runtime>(
    app: AppHandle<R>,
    payload: VoipPushPayload,
) -> Result<()> {
    app.callkit().report_new_incoming_voip_push(payload)
}

#[command]
pub(crate) async fn check_call_capability<R: Runtime>(
    app: AppHandle<R>,
) -> Result<crate::CallCapability> {
    app.callkit().check_call_capability()
}

#[command]
pub(crate) async fn get_audio_routes<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<AudioRoute>> {
    app.callkit().get_audio_routes()
}

#[command]
pub(crate) async fn set_audio_route<R: Runtime>(
    app: AppHandle<R>,
    route_type: AudioRouteType,
) -> Result<()> {
    app.callkit().set_audio_route(route_type)
}