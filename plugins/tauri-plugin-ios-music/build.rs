const COMMANDS: &[&str] = &[
    "check_permissions",
    "request_permissions",
    "get_library_status",
    "get_playlists",
    "get_playlist",
    "create_playlist",
    "update_playlist",
    "delete_playlist",
    "get_songs",
    "get_song",
    "get_albums",
    "get_album",
    "get_artists",
    "get_artist",
    "get_genres",
    "play_item",
    "pause",
    "resume",
    "stop",
    "skip_to_next",
    "skip_to_previous",
    "get_playback_state",
    "set_playback_time",
    "set_repeat_mode",
    "set_shuffle_mode",
    "get_now_playing",
    "add_to_library",
    "search_catalog",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}