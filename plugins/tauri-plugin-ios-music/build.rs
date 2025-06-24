const COMMANDS: &[&str] = &[
    "check_permissions",
    "request_permissions",
    "get_library_status",
    "get_playlists",
    "get_playlist",
    "create_playlist",
    "get_songs",
    "get_albums",
    "get_artists",
    "play_item",
    "pause",
    "resume",
    "get_playback_state",
    "get_now_playing",
    "search_catalog",
    "skip_to_next",
    "skip_to_previous",
    "set_playback_time",
    "set_repeat_mode",
    "set_shuffle_mode",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}