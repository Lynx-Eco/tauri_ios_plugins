use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Music<R>> {
    Ok(Music(app.clone()))
}

/// Access to the music APIs on desktop (returns errors as not available).
pub struct Music<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Music<R> {
    pub fn check_permissions(&self) -> Result<MusicPermissions> {
        Err(Error::PermissionDenied)
    }

    pub fn request_permissions(&self) -> Result<MusicPermissions> {
        Err(Error::PermissionDenied)
    }

    pub fn get_library_status(&self) -> Result<LibraryStatus> {
        Err(Error::PermissionDenied)
    }

    pub fn get_playlists(&self, _query: PlaylistQuery) -> Result<Vec<Playlist>> {
        Err(Error::PermissionDenied)
    }

    pub fn get_playlist(&self, _id: &str) -> Result<Playlist> {
        Err(Error::OperationFailed("Item not found".to_string()))
    }

    pub fn create_playlist(&self, _data: CreatePlaylistData) -> Result<Playlist> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn get_songs(&self, _query: SongQuery) -> Result<Vec<Song>> {
        Err(Error::PermissionDenied)
    }

    pub fn get_albums(&self, _query: AlbumQuery) -> Result<Vec<Album>> {
        Err(Error::PermissionDenied)
    }

    pub fn get_artists(&self, _query: ArtistQuery) -> Result<Vec<Artist>> {
        Err(Error::PermissionDenied)
    }

    pub fn play_item(&self, _item: PlayableItem) -> Result<()> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn pause(&self) -> Result<()> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn resume(&self) -> Result<()> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn get_playback_state(&self) -> Result<PlaybackState> {
        Ok(PlaybackState {
            status: PlaybackStatus::Stopped,
            current_time: 0.0,
            repeat_mode: RepeatMode::None,
            shuffle_mode: ShuffleMode::Off,
            playback_rate: 1.0,
            volume: 1.0,
        })
    }

    pub fn get_now_playing(&self) -> Result<Option<NowPlaying>> {
        Ok(None)
    }

    pub fn search_catalog(&self, _query: SearchQuery) -> Result<SearchResults> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }
}