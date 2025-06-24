use serde::{Deserialize, Serialize};
use tauri::plugin::PermissionState;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MusicPermissions {
    pub media_library: PermissionState,
    pub apple_music: PermissionState,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LibraryStatus {
    pub is_cloud_enabled: bool,
    pub has_apple_music_subscription: bool,
    pub song_count: usize,
    pub album_count: usize,
    pub artist_count: usize,
    pub playlist_count: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Song {
    pub id: String,
    pub title: String,
    pub artist: String,
    pub album: String,
    pub album_artist: Option<String>,
    pub genre: Option<String>,
    pub composer: Option<String>,
    pub duration: f64, // seconds
    pub track_number: Option<u32>,
    pub disc_number: Option<u32>,
    pub year: Option<u32>,
    pub is_explicit: bool,
    pub is_cloud_item: bool,
    pub has_lyrics: bool,
    pub artwork_url: Option<String>,
    pub play_count: u32,
    pub skip_count: u32,
    pub rating: Option<f32>,
    pub last_played_date: Option<String>,
    pub date_added: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Album {
    pub id: String,
    pub title: String,
    pub artist: String,
    pub album_artist: Option<String>,
    pub genre: Option<String>,
    pub year: Option<u32>,
    pub track_count: u32,
    pub is_compilation: bool,
    pub is_explicit: bool,
    pub artwork_url: Option<String>,
    pub songs: Option<Vec<Song>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Artist {
    pub id: String,
    pub name: String,
    pub genre: Option<String>,
    pub album_count: u32,
    pub song_count: u32,
    pub artwork_url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Playlist {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub author: Option<String>,
    pub is_editable: bool,
    pub is_public: bool,
    pub song_count: u32,
    pub duration: f64,
    pub artwork_url: Option<String>,
    pub date_created: String,
    pub date_modified: String,
    pub songs: Option<Vec<Song>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Genre {
    pub id: String,
    pub name: String,
    pub song_count: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct SongQuery {
    pub artist_id: Option<String>,
    pub album_id: Option<String>,
    pub playlist_id: Option<String>,
    pub genre: Option<String>,
    pub search_text: Option<String>,
    pub is_cloud_item: Option<bool>,
    pub sort_order: Option<SortOrder>,
    pub limit: Option<usize>,
    pub offset: Option<usize>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct AlbumQuery {
    pub artist_id: Option<String>,
    pub genre: Option<String>,
    pub search_text: Option<String>,
    pub is_compilation: Option<bool>,
    pub sort_order: Option<SortOrder>,
    pub limit: Option<usize>,
    pub offset: Option<usize>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct ArtistQuery {
    pub genre: Option<String>,
    pub search_text: Option<String>,
    pub sort_order: Option<SortOrder>,
    pub limit: Option<usize>,
    pub offset: Option<usize>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct PlaylistQuery {
    pub is_editable: Option<bool>,
    pub author: Option<String>,
    pub sort_order: Option<SortOrder>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum SortOrder {
    Title,
    Artist,
    Album,
    DateAdded,
    PlayCount,
    RecentlyPlayed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CreatePlaylistData {
    pub name: String,
    pub description: Option<String>,
    pub song_ids: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePlaylistData {
    pub id: String,
    pub name: Option<String>,
    pub description: Option<String>,
    pub add_song_ids: Vec<String>,
    pub remove_song_ids: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum PlayableItem {
    Song { id: String },
    Album { id: String },
    Playlist { id: String },
    Artist { id: String },
    Queue { song_ids: Vec<String> },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PlaybackState {
    pub status: PlaybackStatus,
    pub current_time: f64,
    pub repeat_mode: RepeatMode,
    pub shuffle_mode: ShuffleMode,
    pub playback_rate: f32,
    pub volume: f32,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum PlaybackStatus {
    Stopped,
    Playing,
    Paused,
    Interrupted,
    SeekingForward,
    SeekingBackward,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum RepeatMode {
    None,
    One,
    All,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum ShuffleMode {
    Off,
    Songs,
    Albums,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct NowPlaying {
    pub item: Song,
    pub index: usize,
    pub queue_count: usize,
    pub elapsed_time: f64,
    pub remaining_time: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SearchQuery {
    pub term: String,
    pub types: Vec<SearchType>,
    pub limit: Option<usize>,
    pub storefront: Option<String>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum SearchType {
    Songs,
    Albums,
    Artists,
    Playlists,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SearchResults {
    pub songs: Vec<CatalogItem>,
    pub albums: Vec<CatalogItem>,
    pub artists: Vec<CatalogItem>,
    pub playlists: Vec<CatalogItem>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CatalogItem {
    pub id: String,
    pub name: String,
    pub artist_name: Option<String>,
    pub artwork_url: Option<String>,
    pub preview_url: Option<String>,
    pub is_explicit: bool,
}