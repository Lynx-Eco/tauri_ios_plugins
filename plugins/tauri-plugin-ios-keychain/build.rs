const COMMANDS: &[&str] = &[
    "set_item",
    "get_item",
    "delete_item",
    "has_item",
    "update_item",
    "get_all_keys",
    "delete_all",
    "set_access_group",
    "get_access_group",
    "set_secure_item",
    "get_secure_item",
    "generate_password",
    "check_authentication",
    "set_internet_password",
    "get_internet_password",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}