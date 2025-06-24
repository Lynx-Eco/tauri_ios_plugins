import { invoke } from '@tauri-apps/api/core'

// Enums
export enum AccessLevel {
  ReadWrite = 'readWrite',
  AddOnly = 'addOnly'
}

export enum AlbumType {
  Regular = 'regular',
  SmartAlbum = 'smartAlbum',
  Shared = 'shared',
  CloudShared = 'cloudShared',
  Faces = 'faces',
  Moments = 'moments'
}

export enum MediaType {
  Unknown = 'unknown',
  Image = 'image',
  Video = 'video',
  Audio = 'audio'
}

export enum MediaSubtype {
  PhotoPanorama = 'photoPanorama',
  PhotoHDR = 'photoHdr',
  PhotoScreenshot = 'photoScreenshot',
  PhotoLive = 'photoLive',
  PhotoDepthEffect = 'photoDepthEffect',
  VideoStreamed = 'videoStreamed',
  VideoHighFrameRate = 'videoHighFrameRate',
  VideoTimelapse = 'videoTimelapse',
  VideoCinematic = 'videoCinematic',
  VideoSloMo = 'videoSloMo'
}

export enum SortOrder {
  CreationDateAscending = 'creationDateAscending',
  CreationDateDescending = 'creationDateDescending',
  ModificationDateAscending = 'modificationDateAscending',
  ModificationDateDescending = 'modificationDateDescending'
}

export enum ImageFormat {
  JPEG = 'jpeg',
  PNG = 'png',
  HEIF = 'heif',
  TIFF = 'tiff'
}

export enum VideoFormat {
  MOV = 'mov',
  MP4 = 'mp4',
  M4V = 'm4v'
}

// Interfaces
export interface PhotosPermissions {
  readWrite: 'granted' | 'denied' | 'prompt'
  addOnly: 'granted' | 'denied' | 'prompt'
}

export interface Album {
  id: string
  title: string
  assetCount: number
  startDate?: string
  endDate?: string
  albumType: AlbumType
  canAddAssets: boolean
  canRemoveAssets: boolean
  canDelete: boolean
  isSmartAlbum: boolean
}

export interface AlbumQuery {
  albumTypes?: AlbumType[]
  includeEmpty?: boolean
  includeHidden?: boolean
  includeSmartAlbums?: boolean
}

export interface AssetLocation {
  latitude: number
  longitude: number
  altitude?: number
}

export interface Asset {
  id: string
  mediaType: MediaType
  mediaSubtype: MediaSubtype[]
  creationDate: string
  modificationDate: string
  width: number
  height: number
  duration?: number
  isFavorite: boolean
  isHidden: boolean
  location?: AssetLocation
  burstIdentifier?: string
  representsBurst: boolean
}

export interface AssetQuery {
  albumId?: string
  mediaTypes?: MediaType[]
  mediaSubtypes?: MediaSubtype[]
  startDate?: string
  endDate?: string
  isFavorite?: boolean
  isHidden?: boolean
  hasLocation?: boolean
  burstOnly?: boolean
  sortOrder?: SortOrder
  limit?: number
  offset?: number
}

export interface ImageMetadata {
  creationDate?: string
  location?: AssetLocation
  exif?: any
}

export interface SaveImageData {
  imageData: string
  toAlbum?: string
  metadata?: ImageMetadata
}

export interface ExportOptions {
  imageFormat?: ImageFormat
  videoFormat?: VideoFormat
  quality?: number
  maxWidth?: number
  maxHeight?: number
  preserveMetadata?: boolean
}

export interface CameraInfo {
  make?: string
  model?: string
  lensMake?: string
  lensModel?: string
}

export interface Dimensions {
  width: number
  height: number
}

export interface AssetMetadata {
  exif?: any
  gps?: AssetLocation
  creationDate: string
  modificationDate: string
  takenWith?: CameraInfo
  dimensions: Dimensions
  fileSize: number
  codec?: string
  bitRate?: number
  frameRate?: number
}

export interface DateRange {
  startDate: string
  endDate: string
}

export interface LocationRadius {
  latitude: number
  longitude: number
  radiusMeters: number
}

export interface SearchQuery {
  text?: string
  albumIds?: string[]
  mediaTypes?: MediaType[]
  dateRange?: DateRange
  locationRadius?: LocationRadius
}

// API Functions
export async function checkPermissions(): Promise<PhotosPermissions> {
  return await invoke('plugin:ios-photos-v2|check_permissions')
}

export async function requestPermissions(accessLevel: AccessLevel): Promise<PhotosPermissions> {
  return await invoke('plugin:ios-photos-v2|request_permissions', { accessLevel })
}

export async function getAlbums(options?: AlbumQuery): Promise<Album[]> {
  return await invoke('plugin:ios-photos-v2|get_albums', { options })
}

export async function getAlbum(id: string): Promise<Album> {
  return await invoke('plugin:ios-photos-v2|get_album', { id })
}

export async function createAlbum(title: string): Promise<Album> {
  return await invoke('plugin:ios-photos-v2|create_album', { title })
}

export async function deleteAlbum(id: string): Promise<void> {
  return await invoke('plugin:ios-photos-v2|delete_album', { id })
}

export async function getAssets(query?: AssetQuery): Promise<Asset[]> {
  return await invoke('plugin:ios-photos-v2|get_assets', { query })
}

export async function getAsset(id: string): Promise<Asset> {
  return await invoke('plugin:ios-photos-v2|get_asset', { id })
}

export async function deleteAssets(ids: string[]): Promise<void> {
  return await invoke('plugin:ios-photos-v2|delete_assets', { ids })
}

export async function saveImage(data: SaveImageData): Promise<string> {
  return await invoke('plugin:ios-photos-v2|save_image', { data })
}

export async function saveVideo(path: string, toAlbum?: string): Promise<string> {
  return await invoke('plugin:ios-photos-v2|save_video', { path, toAlbum })
}

export async function exportAsset(id: string, options?: ExportOptions): Promise<string> {
  return await invoke('plugin:ios-photos-v2|export_asset', { id, options })
}

export async function getAssetMetadata(id: string): Promise<AssetMetadata> {
  return await invoke('plugin:ios-photos-v2|get_asset_metadata', { id })
}

export async function searchAssets(query: SearchQuery): Promise<Asset[]> {
  return await invoke('plugin:ios-photos-v2|search_assets', { query })
}
