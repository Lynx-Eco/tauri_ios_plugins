const COMMANDS: &[&str] = &[
    "check_permissions",
    "request_permissions",
    "start_recording",
    "stop_recording",
    "pause_recording",
    "resume_recording",
    "get_recording_state",
    "get_audio_levels",
    "get_available_inputs",
    "set_audio_input",
    "get_recording_duration",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}