# Tauri Plugin iOS Music

Access the iOS Music Library and Apple Music catalog in your Tauri applications.

## Features

- Full music library access (songs, albums, artists, playlists)
- Apple Music catalog search and streaming
- Playback control with queue management
- Playlist creation and management
- Smart filtering and sorting
- Real-time playback notifications
- Artwork access
- Metadata including play counts, ratings, and dates

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-music = "0.1"
```

## iOS Configuration

Add to your app's `Info.plist`:

```xml
<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your music library to play songs</string>
```

For Apple Music streaming, enable the Apple Music capability in your app.

## Usage

### Rust

```rust
use tauri_plugin_ios_music::{MusicExt, SongQuery, PlayableItem, RepeatMode};

// Check and request permissions
#[tauri::command]
async fn setup_music(app: tauri::AppHandle) -> Result<(), String> {
    let music = app.music();
    
    let permissions = music.check_permissions()
        .map_err(|e| e.to_string())?;
    
    if permissions.media_library != PermissionState::Granted {
        music.request_permissions()
            .map_err(|e| e.to_string())?;
    }
    
    Ok(())
}

// Get user's playlists
#[tauri::command]
async fn get_user_playlists(app: tauri::AppHandle) -> Result<Vec<Playlist>, String> {
    app.music()
        .get_playlists(PlaylistQuery {
            is_editable: Some(true),
            ..Default::default()
        })
        .map_err(|e| e.to_string())
}

// Search and play songs
#[tauri::command]
async fn search_and_play(app: tauri::AppHandle, search: String) -> Result<(), String> {
    let music = app.music();
    
    // Search local library
    let songs = music.get_songs(SongQuery {
        search_text: Some(search.clone()),
        limit: Some(10),
        ..Default::default()
    }).map_err(|e| e.to_string())?;
    
    if let Some(song) = songs.first() {
        // Play the song
        music.play_item(PlayableItem::Song { id: song.id.clone() })
            .map_err(|e| e.to_string())?;
    }
    
    Ok(())
}
```

### JavaScript/TypeScript

```typescript
import { 
  checkPermissions,
  requestPermissions,
  getLibraryStatus,
  getSongs,
  getAlbums,
  getPlaylists,
  playItem,
  pause,
  resume,
  getPlaybackState,
  getNowPlaying,
  searchCatalog,
  addPluginListener
} from 'tauri-plugin-ios-music';

// Setup permissions
const permissions = await checkPermissions();
if (permissions.mediaLibrary !== 'granted') {
  await requestPermissions();
}

// Get library information
const status = await getLibraryStatus();
console.log(`Library has ${status.songCount} songs`);
console.log(`Apple Music: ${status.hasAppleMusicSubscription}`);

// Query songs with filters
const recentSongs = await getSongs({
  sortOrder: 'dateAdded',
  limit: 50
});

const rockSongs = await getSongs({
  genre: 'Rock',
  isCloudItem: false,
  sortOrder: 'title'
});

// Get all albums by an artist
const albums = await getAlbums({
  searchText: 'Beatles',
  sortOrder: 'year'
});

// Play an album
await playItem({
  type: 'album',
  id: albums[0].id
});

// Control playback
await pause();
await resume();

// Get current playback info
const state = await getPlaybackState();
console.log(`Status: ${state.status}`);
console.log(`Time: ${state.currentTime}s`);

const nowPlaying = await getNowPlaying();
if (nowPlaying) {
  console.log(`Playing: ${nowPlaying.item.title} by ${nowPlaying.item.artist}`);
  console.log(`${nowPlaying.elapsedTime}s / ${nowPlaying.item.duration}s`);
}

// Create a playlist
const playlist = await createPlaylist({
  name: 'My Favorites',
  description: 'Best songs ever',
  songIds: recentSongs.slice(0, 10).map(s => s.id)
});

// Search Apple Music catalog (iOS 15+)
const results = await searchCatalog({
  term: 'Taylor Swift',
  types: ['songs', 'albums'],
  limit: 20
});

results.songs.forEach(song => {
  console.log(`${song.name} - ${song.artistName}`);
});

// Listen for playback events
const stateListener = await addPluginListener(
  'ios-music',
  'playbackStateChanged',
  (event) => {
    console.log(`Playback state: ${event.status}`);
  }
);

const nowPlayingListener = await addPluginListener(
  'ios-music',
  'nowPlayingChanged',
  (song) => {
    if (song) {
      console.log(`Now playing: ${song.title}`);
    }
  }
);

// Clean up
stateListener.remove();
nowPlayingListener.remove();
```

## API Reference

### Types

#### Song
```typescript
interface Song {
  id: string;
  title: string;
  artist: string;
  album: string;
  albumArtist?: string;
  genre?: string;
  composer?: string;
  duration: number;          // seconds
  trackNumber?: number;
  discNumber?: number;
  year?: number;
  isExplicit: boolean;
  isCloudItem: boolean;
  hasLyrics: boolean;
  artworkUrl?: string;       // Base64 data URL
  playCount: number;
  skipCount: number;
  rating?: number;
  lastPlayedDate?: string;
  dateAdded: string;
}
```

#### Album
```typescript
interface Album {
  id: string;
  title: string;
  artist: string;
  albumArtist?: string;
  genre?: string;
  year?: number;
  trackCount: number;
  isCompilation: boolean;
  isExplicit: boolean;
  artworkUrl?: string;
  songs?: Song[];            // Only when fetching specific album
}
```

#### Playlist
```typescript
interface Playlist {
  id: string;
  name: string;
  description?: string;
  author?: string;
  isEditable: boolean;
  isPublic: boolean;
  songCount: number;
  duration: number;          // Total seconds
  artworkUrl?: string;
  dateCreated: string;
  dateModified: string;
  songs?: Song[];            // Only when fetching specific playlist
}
```

### Commands

#### `checkPermissions()`
Check music library and Apple Music permissions.

#### `requestPermissions()`
Request necessary permissions.

#### `getLibraryStatus()`
Get library statistics and capabilities.

#### `getSongs(query?: SongQuery)`
Query songs with extensive filtering options.

#### `getAlbums(query?: AlbumQuery)`
Query albums with filtering.

#### `getArtists(query?: ArtistQuery)`
Query artists with filtering.

#### `getPlaylists(query?: PlaylistQuery)`
Get user playlists.

#### `createPlaylist(data: CreatePlaylistData)`
Create a new playlist with songs.

#### `playItem(item: PlayableItem)`
Play a song, album, playlist, or custom queue.

#### `pause()` / `resume()`
Control playback.

#### `getPlaybackState()`
Get current playback status and settings.

#### `getNowPlaying()`
Get currently playing song with timing info.

#### `searchCatalog(query: SearchQuery)`
Search Apple Music catalog (requires iOS 15+).

## Events

- `playbackStateChanged` - Playback status changed
- `nowPlayingChanged` - Current song changed

## Sort Orders

- `title` - Alphabetical by title
- `artist` - Alphabetical by artist
- `album` - Alphabetical by album
- `dateAdded` - Recently added first
- `playCount` - Most played first
- `recentlyPlayed` - Recently played first

## Error Handling

- `AccessDenied` - Music library permission denied
- `SubscriptionRequired` - Apple Music subscription needed
- `ItemNotFound` - Song/album/playlist not found
- `PlaylistNotEditable` - Cannot modify system playlists
- `PlaybackFailed` - Unable to play media

## License

MIT or Apache-2.0