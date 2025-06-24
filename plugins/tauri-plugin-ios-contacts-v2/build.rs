const COMMANDS: &[&str] = &[
    "check_permissions",
    "request_permissions",
    "get_contacts",
    "get_contact",
    "create_contact",
    "update_contact",
    "delete_contact",
    "get_groups",
    "create_group",
    "add_contact_to_group",
    "remove_contact_from_group",
    "update_group",
    "delete_group",
];

fn main() {
  tauri_plugin::Builder::new(COMMANDS)
    .android_path("android")
    .ios_path("ios")
    .build();
}
