use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_music);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Music<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_music)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.music", "MusicPlugin")?;
    
    Ok(Music(handle))
}

/// Access to the music APIs on mobile.
pub struct Music<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Music<R> {
    pub fn check_permissions(&self) -> Result<MusicPermissions> {
        self.0
            .run_mobile_plugin("checkPermissions", ())
            .map_err(Into::into)
    }

    pub fn request_permissions(&self) -> Result<MusicPermissions> {
        self.0
            .run_mobile_plugin("requestPermissions", ())
            .map_err(Into::into)
    }

    pub fn get_library_status(&self) -> Result<LibraryStatus> {
        self.0
            .run_mobile_plugin("getLibraryStatus", ())
            .map_err(Into::into)
    }

    pub fn get_playlists(&self, query: PlaylistQuery) -> Result<Vec<Playlist>> {
        self.0
            .run_mobile_plugin("getPlaylists", query)
            .map_err(Into::into)
    }

    pub fn get_playlist(&self, id: &str) -> Result<Playlist> {
        #[derive(serde::Serialize)]
        struct GetPlaylistArgs<'a> {
            id: &'a str,
        }
        
        self.0
            .run_mobile_plugin("getPlaylist", GetPlaylistArgs { id })
            .map_err(Into::into)
    }

    pub fn create_playlist(&self, data: CreatePlaylistData) -> Result<Playlist> {
        self.0
            .run_mobile_plugin("createPlaylist", data)
            .map_err(Into::into)
    }

    pub fn get_songs(&self, query: SongQuery) -> Result<Vec<Song>> {
        self.0
            .run_mobile_plugin("getSongs", query)
            .map_err(Into::into)
    }

    pub fn get_albums(&self, query: AlbumQuery) -> Result<Vec<Album>> {
        self.0
            .run_mobile_plugin("getAlbums", query)
            .map_err(Into::into)
    }

    pub fn get_artists(&self, query: ArtistQuery) -> Result<Vec<Artist>> {
        self.0
            .run_mobile_plugin("getArtists", query)
            .map_err(Into::into)
    }

    pub fn play_item(&self, item: PlayableItem) -> Result<()> {
        self.0
            .run_mobile_plugin("playItem", item)
            .map_err(Into::into)
    }

    pub fn pause(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("pause", ())
            .map_err(Into::into)
    }

    pub fn resume(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("resume", ())
            .map_err(Into::into)
    }

    pub fn get_playback_state(&self) -> Result<PlaybackState> {
        self.0
            .run_mobile_plugin("getPlaybackState", ())
            .map_err(Into::into)
    }

    pub fn get_now_playing(&self) -> Result<Option<NowPlaying>> {
        self.0
            .run_mobile_plugin("getNowPlaying", ())
            .map_err(Into::into)
    }

    pub fn search_catalog(&self, query: SearchQuery) -> Result<SearchResults> {
        self.0
            .run_mobile_plugin("searchCatalog", query)
            .map_err(Into::into)
    }
}