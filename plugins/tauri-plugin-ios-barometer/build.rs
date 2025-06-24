const COMMANDS: &[&str] = &[
    "start_pressure_updates",
    "stop_pressure_updates",
    "get_pressure_data",
    "is_barometer_available",
    "set_update_interval",
    "get_reference_pressure",
    "set_reference_pressure",
    "get_altitude_from_pressure",
    "start_altitude_updates",
    "stop_altitude_updates",
    "get_weather_data",
    "calibrate_barometer",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}