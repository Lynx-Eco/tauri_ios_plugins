const COMMANDS: &[&str] = &[
    "check_permissions",
    "request_permissions",
    "get_current_location",
    "start_location_updates",
    "stop_location_updates",
    "start_significant_location_updates",
    "stop_significant_location_updates",
    "start_monitoring_region",
    "stop_monitoring_region",
    "get_monitored_regions",
    "start_heading_updates",
    "stop_heading_updates",
    "geocode_address",
    "reverse_geocode",
    "get_distance",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}