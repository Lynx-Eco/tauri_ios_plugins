const COMMANDS: &[&str] = &[
    "reload_all_timelines",
    "reload_timelines",
    "get_current_configurations",
    "set_widget_data",
    "get_widget_data",
    "clear_widget_data",
    "request_widget_update",
    "get_widget_info",
    "set_widget_url",
    "get_widget_url",
    "preview_widget_data",
    "get_widget_families",
    "schedule_widget_refresh",
    "cancel_widget_refresh",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}