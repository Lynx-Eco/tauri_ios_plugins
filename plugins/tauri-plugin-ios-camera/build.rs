const COMMANDS: &[&str] = &[
    "check_permissions",
    "request_permissions",
    "take_photo",
    "record_video",
    "pick_image",
    "pick_video",
    "pick_media",
    "get_camera_info",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}