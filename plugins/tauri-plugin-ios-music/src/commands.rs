use tauri::{command, AppHandle, Runtime};

use crate::{MusicExt, MusicPermissions, LibraryStatus, PlaylistQuery, Playlist, CreatePlaylistData, SongQuery, Song, AlbumQuery, Album, ArtistQuery, Artist, PlayableItem, PlaybackState, NowPlaying, SearchQuery, SearchResults, RepeatMode, ShuffleMode, Result};

#[command]
pub(crate) async fn check_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<MusicPermissions> {
    app.music().check_permissions()
}

#[command]
pub(crate) async fn request_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<MusicPermissions> {
    app.music().request_permissions()
}

#[command]
pub(crate) async fn get_library_status<R: Runtime>(
    app: AppHandle<R>,
) -> Result<LibraryStatus> {
    app.music().get_library_status()
}

#[command]
pub(crate) async fn get_playlists<R: Runtime>(
    app: AppHandle<R>,
    query: Option<PlaylistQuery>,
) -> Result<Vec<Playlist>> {
    app.music().get_playlists(query.unwrap_or_default())
}

#[command]
pub(crate) async fn get_playlist<R: Runtime>(
    app: AppHandle<R>,
    id: String,
) -> Result<Playlist> {
    app.music().get_playlist(&id)
}

#[command]
pub(crate) async fn create_playlist<R: Runtime>(
    app: AppHandle<R>,
    data: CreatePlaylistData,
) -> Result<Playlist> {
    app.music().create_playlist(data)
}

#[command]
pub(crate) async fn get_songs<R: Runtime>(
    app: AppHandle<R>,
    query: Option<SongQuery>,
) -> Result<Vec<Song>> {
    app.music().get_songs(query.unwrap_or_default())
}

#[command]
pub(crate) async fn get_albums<R: Runtime>(
    app: AppHandle<R>,
    query: Option<AlbumQuery>,
) -> Result<Vec<Album>> {
    app.music().get_albums(query.unwrap_or_default())
}

#[command]
pub(crate) async fn get_artists<R: Runtime>(
    app: AppHandle<R>,
    query: Option<ArtistQuery>,
) -> Result<Vec<Artist>> {
    app.music().get_artists(query.unwrap_or_default())
}

#[command]
pub(crate) async fn play_item<R: Runtime>(
    app: AppHandle<R>,
    item: PlayableItem,
) -> Result<()> {
    app.music().play_item(item)
}

#[command]
pub(crate) async fn pause<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.music().pause()
}

#[command]
pub(crate) async fn resume<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.music().resume()
}

#[command]
pub(crate) async fn get_playback_state<R: Runtime>(
    app: AppHandle<R>,
) -> Result<PlaybackState> {
    app.music().get_playback_state()
}

#[command]
pub(crate) async fn get_now_playing<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Option<NowPlaying>> {
    app.music().get_now_playing()
}

#[command]
pub(crate) async fn search_catalog<R: Runtime>(
    app: AppHandle<R>,
    query: SearchQuery,
) -> Result<SearchResults> {
    app.music().search_catalog(query)
}

#[command]
pub(crate) async fn skip_to_next<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    // This would need implementation
    Ok(())
}

#[command]
pub(crate) async fn skip_to_previous<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    // This would need implementation
    Ok(())
}

#[command]
pub(crate) async fn set_playback_time<R: Runtime>(
    app: AppHandle<R>,
    _time: f64,
) -> Result<()> {
    // This would need implementation
    Ok(())
}

#[command]
pub(crate) async fn set_repeat_mode<R: Runtime>(
    app: AppHandle<R>,
    _mode: RepeatMode,
) -> Result<()> {
    // This would need implementation
    Ok(())
}

#[command]
pub(crate) async fn set_shuffle_mode<R: Runtime>(
    app: AppHandle<R>,
    _mode: ShuffleMode,
) -> Result<()> {
    // This would need implementation
    Ok(())
}