import { invoke } from '@tauri-apps/api/core'

// Enums
export enum SortOrder {
  Title = 'title',
  Artist = 'artist',
  Album = 'album',
  DateAdded = 'dateAdded',
  PlayCount = 'playCount',
  RecentlyPlayed = 'recentlyPlayed'
}

export enum PlaybackStatus {
  Stopped = 'stopped',
  Playing = 'playing',
  Paused = 'paused',
  Interrupted = 'interrupted',
  SeekingForward = 'seekingForward',
  SeekingBackward = 'seekingBackward'
}

export enum RepeatMode {
  None = 'none',
  One = 'one',
  All = 'all'
}

export enum ShuffleMode {
  Off = 'off',
  Songs = 'songs',
  Albums = 'albums'
}

export enum SearchType {
  Songs = 'songs',
  Albums = 'albums',
  Artists = 'artists',
  Playlists = 'playlists'
}

// Interfaces
export interface MusicPermissions {
  mediaLibrary: 'granted' | 'denied' | 'prompt'
  appleMusic: 'granted' | 'denied' | 'prompt'
}

export interface LibraryStatus {
  isCloudEnabled: boolean
  hasAppleMusicSubscription: boolean
  songCount: number
  albumCount: number
  artistCount: number
  playlistCount: number
}

export interface Song {
  id: string
  title: string
  artist: string
  album: string
  albumArtist?: string
  genre?: string
  composer?: string
  duration: number
  trackNumber?: number
  discNumber?: number
  year?: number
  isExplicit: boolean
  isCloudItem: boolean
  hasLyrics: boolean
  artworkUrl?: string
  playCount: number
  skipCount: number
  rating?: number
  lastPlayedDate?: string
  dateAdded: string
}

export interface Album {
  id: string
  title: string
  artist: string
  albumArtist?: string
  genre?: string
  year?: number
  trackCount: number
  isCompilation: boolean
  isExplicit: boolean
  artworkUrl?: string
  songs?: Song[]
}

export interface Artist {
  id: string
  name: string
  genre?: string
  albumCount: number
  songCount: number
  artworkUrl?: string
}

export interface Playlist {
  id: string
  name: string
  description?: string
  author?: string
  isEditable: boolean
  isPublic: boolean
  songCount: number
  duration: number
  artworkUrl?: string
  dateCreated: string
  dateModified: string
  songs?: Song[]
}

export interface Genre {
  id: string
  name: string
  songCount: number
}

export interface SongQuery {
  artistId?: string
  albumId?: string
  playlistId?: string
  genre?: string
  searchText?: string
  isCloudItem?: boolean
  sortOrder?: SortOrder
  limit?: number
  offset?: number
}

export interface AlbumQuery {
  artistId?: string
  genre?: string
  searchText?: string
  isCompilation?: boolean
  sortOrder?: SortOrder
  limit?: number
  offset?: number
}

export interface ArtistQuery {
  genre?: string
  searchText?: string
  sortOrder?: SortOrder
  limit?: number
  offset?: number
}

export interface PlaylistQuery {
  isEditable?: boolean
  author?: string
  sortOrder?: SortOrder
}

export interface CreatePlaylistData {
  name: string
  description?: string
  songIds: string[]
}

export interface UpdatePlaylistData {
  id: string
  name?: string
  description?: string
  addSongIds: string[]
  removeSongIds: string[]
}

export type PlayableItem = 
  | { song: { id: string } }
  | { album: { id: string } }
  | { playlist: { id: string } }
  | { artist: { id: string } }
  | { queue: { songIds: string[] } }

export interface PlaybackState {
  status: PlaybackStatus
  currentTime: number
  repeatMode: RepeatMode
  shuffleMode: ShuffleMode
  playbackRate: number
  volume: number
}

export interface NowPlaying {
  item: Song
  index: number
  queueCount: number
  elapsedTime: number
  remainingTime: number
}

export interface SearchQuery {
  term: string
  types: SearchType[]
  limit?: number
  storefront?: string
}

export interface CatalogItem {
  id: string
  name: string
  artistName?: string
  artworkUrl?: string
  previewUrl?: string
  isExplicit: boolean
}

export interface SearchResults {
  songs: CatalogItem[]
  albums: CatalogItem[]
  artists: CatalogItem[]
  playlists: CatalogItem[]
}

// API Functions
export async function checkPermissions(): Promise<MusicPermissions> {
  return await invoke('plugin:ios-music-v2|check_permissions')
}

export async function requestPermissions(): Promise<MusicPermissions> {
  return await invoke('plugin:ios-music-v2|request_permissions')
}

export async function getLibraryStatus(): Promise<LibraryStatus> {
  return await invoke('plugin:ios-music-v2|get_library_status')
}

export async function getPlaylists(query?: PlaylistQuery): Promise<Playlist[]> {
  return await invoke('plugin:ios-music-v2|get_playlists', { query })
}

export async function getPlaylist(id: string): Promise<Playlist> {
  return await invoke('plugin:ios-music-v2|get_playlist', { id })
}

export async function createPlaylist(data: CreatePlaylistData): Promise<Playlist> {
  return await invoke('plugin:ios-music-v2|create_playlist', { data })
}

export async function getSongs(query?: SongQuery): Promise<Song[]> {
  return await invoke('plugin:ios-music-v2|get_songs', { query })
}

export async function getAlbums(query?: AlbumQuery): Promise<Album[]> {
  return await invoke('plugin:ios-music-v2|get_albums', { query })
}

export async function getArtists(query?: ArtistQuery): Promise<Artist[]> {
  return await invoke('plugin:ios-music-v2|get_artists', { query })
}

export async function playItem(item: PlayableItem): Promise<void> {
  return await invoke('plugin:ios-music-v2|play_item', { item })
}

export async function pause(): Promise<void> {
  return await invoke('plugin:ios-music-v2|pause')
}

export async function resume(): Promise<void> {
  return await invoke('plugin:ios-music-v2|resume')
}

export async function getPlaybackState(): Promise<PlaybackState> {
  return await invoke('plugin:ios-music-v2|get_playback_state')
}

export async function getNowPlaying(): Promise<NowPlaying | null> {
  return await invoke('plugin:ios-music-v2|get_now_playing')
}

export async function searchCatalog(query: SearchQuery): Promise<SearchResults> {
  return await invoke('plugin:ios-music-v2|search_catalog', { query })
}

export async function skipToNext(): Promise<void> {
  return await invoke('plugin:ios-music-v2|skip_to_next')
}

export async function skipToPrevious(): Promise<void> {
  return await invoke('plugin:ios-music-v2|skip_to_previous')
}

export async function setPlaybackTime(time: number): Promise<void> {
  return await invoke('plugin:ios-music-v2|set_playback_time', { time })
}

export async function setRepeatMode(mode: RepeatMode): Promise<void> {
  return await invoke('plugin:ios-music-v2|set_repeat_mode', { mode })
}

export async function setShuffleMode(mode: ShuffleMode): Promise<void> {
  return await invoke('plugin:ios-music-v2|set_shuffle_mode', { mode })
}
