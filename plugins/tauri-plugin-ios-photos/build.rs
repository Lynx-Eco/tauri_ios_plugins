const COMMANDS: &[&str] = &[
    "check_permissions",
    "request_permissions",
    "get_albums",
    "get_album",
    "create_album",
    "delete_album",
    "get_assets",
    "get_asset",
    "delete_assets",
    "save_image",
    "save_video",
    "export_asset",
    "get_asset_metadata",
    "search_assets",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}