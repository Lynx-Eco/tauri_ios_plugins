// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        // iOS Plugins
        .plugin(tauri_plugin_ios_healthkit::init())
        .plugin(tauri_plugin_ios_contacts::init())
        .plugin(tauri_plugin_ios_camera::init())
        .plugin(tauri_plugin_ios_microphone::init())
        .plugin(tauri_plugin_ios_location::init())
        .plugin(tauri_plugin_ios_photos::init())
        .plugin(tauri_plugin_ios_music::init())
        .plugin(tauri_plugin_ios_keychain::init())
        .plugin(tauri_plugin_ios_screentime::init())
        .plugin(tauri_plugin_ios_files::init())
        .plugin(tauri_plugin_ios_messages::init())
        .plugin(tauri_plugin_ios_callkit::init())
        .plugin(tauri_plugin_ios_bluetooth::init())
        .plugin(tauri_plugin_ios_shortcuts::init())
        .plugin(tauri_plugin_ios_widgets::init())
        .plugin(tauri_plugin_ios_motion::init())
        .plugin(tauri_plugin_ios_barometer::init())
        .plugin(tauri_plugin_ios_proximity::init())
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
