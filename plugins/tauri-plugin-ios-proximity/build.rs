const COMMANDS: &[&str] = &[
    "start_proximity_monitoring",
    "stop_proximity_monitoring",
    "get_proximity_state",
    "is_proximity_available",
    "enable_proximity_monitoring",
    "disable_proximity_monitoring",
    "set_display_auto_lock",
    "get_display_auto_lock_state",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}