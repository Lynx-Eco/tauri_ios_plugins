use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`], [`tauri::WebviewWindow`], [`tauri::Webview`] and [`tauri::Window`] to access the music APIs.
pub trait MusicExt<R: Runtime> {
    fn music(&self) -> &Music<R>;
}

impl<R: Runtime, T: Manager<R>> crate::MusicExt<R> for T {
    fn music(&self) -> &Music<R> {
        self.state::<Music<R>>().inner()
    }
}

/// Access to the music APIs.
pub struct Music<R: Runtime>(MusicImpl<R>);

#[cfg(desktop)]
type MusicImpl<R> = desktop::Music<R>;
#[cfg(mobile)]
type MusicImpl<R> = mobile::Music<R>;

impl<R: Runtime> Music<R> {
    pub fn check_permissions(&self) -> Result<MusicPermissions> {
        self.0.check_permissions()
    }

    pub fn request_permissions(&self) -> Result<MusicPermissions> {
        self.0.request_permissions()
    }

    pub fn get_library_status(&self) -> Result<LibraryStatus> {
        self.0.get_library_status()
    }

    pub fn get_playlists(&self, query: PlaylistQuery) -> Result<Vec<Playlist>> {
        self.0.get_playlists(query)
    }

    pub fn get_playlist(&self, id: &str) -> Result<Playlist> {
        self.0.get_playlist(id)
    }

    pub fn create_playlist(&self, data: CreatePlaylistData) -> Result<Playlist> {
        self.0.create_playlist(data)
    }

    pub fn get_songs(&self, query: SongQuery) -> Result<Vec<Song>> {
        self.0.get_songs(query)
    }

    pub fn get_albums(&self, query: AlbumQuery) -> Result<Vec<Album>> {
        self.0.get_albums(query)
    }

    pub fn get_artists(&self, query: ArtistQuery) -> Result<Vec<Artist>> {
        self.0.get_artists(query)
    }

    pub fn play_item(&self, item: PlayableItem) -> Result<()> {
        self.0.play_item(item)
    }

    pub fn pause(&self) -> Result<()> {
        self.0.pause()
    }

    pub fn resume(&self) -> Result<()> {
        self.0.resume()
    }

    pub fn get_playback_state(&self) -> Result<PlaybackState> {
        self.0.get_playback_state()
    }

    pub fn get_now_playing(&self) -> Result<Option<NowPlaying>> {
        self.0.get_now_playing()
    }

    pub fn search_catalog(&self, query: SearchQuery) -> Result<SearchResults> {
        self.0.search_catalog(query)
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-music")
        .invoke_handler(tauri::generate_handler![
            commands::check_permissions,
            commands::request_permissions,
            commands::get_library_status,
            commands::get_playlists,
            commands::get_playlist,
            commands::create_playlist,
            commands::get_songs,
            commands::get_albums,
            commands::get_artists,
            commands::play_item,
            commands::pause,
            commands::resume,
            commands::get_playback_state,
            commands::get_now_playing,
            commands::search_catalog,
            commands::skip_to_next,
            commands::skip_to_previous,
            commands::set_playback_time,
            commands::set_repeat_mode,
            commands::set_shuffle_mode,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let music = mobile::init(app, api)?;
            #[cfg(desktop)]
            let music = desktop::init(app, api)?;
            
            app.manage(Music(music));
            Ok(())
        })
        .build()
}