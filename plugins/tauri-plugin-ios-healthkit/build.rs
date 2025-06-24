const COMMANDS: &[&str] = &[
    "check_permissions",
    "request_permissions",
    "query_quantity_samples",
    "query_category_samples",
    "query_workout_samples",
    "write_quantity_sample",
    "write_category_sample",
    "write_workout",
    "get_biological_sex",
    "get_date_of_birth",
    "get_blood_type",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}