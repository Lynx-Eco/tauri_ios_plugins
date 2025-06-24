const COMMANDS: &[&str] = &[
    "configure_audio_session",
    "report_incoming_call",
    "report_outgoing_call",
    "end_call",
    "set_held",
    "set_muted",
    "set_group",
    "set_on_hold",
    "start_call_audio",
    "answer_call",
    "report_call_update",
    "get_active_calls",
    "get_call_state",
    "request_transaction",
    "report_audio_route_change",
    "set_provider_configuration",
    "register_for_voip_notifications",
    "invalidate_push_token",
    "report_new_incoming_voip_push",
    "check_call_capability",
    "get_audio_routes",
    "set_audio_route",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}