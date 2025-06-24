import { invoke } from '@tauri-apps/api/core'

// Enums
export enum CloudStatus {
  Current = 'current',
  Downloading = 'downloading',
  Downloaded = 'downloaded',
  NotDownloaded = 'notDownloaded',
  NotInCloud = 'notInCloud'
}

export enum SortOption {
  Name = 'name',
  Date = 'date',
  Size = 'size',
  Type = 'type'
}

export enum CloudDownloadStatus {
  Starting = 'starting',
  Downloading = 'downloading',
  Completed = 'completed',
  Failed = 'failed',
  Cancelled = 'cancelled'
}

export enum MonitoringEvent {
  Created = 'created',
  Modified = 'modified',
  Deleted = 'deleted',
  Renamed = 'renamed',
  AttributesChanged = 'attributesChanged'
}

// Types
export type FileType = 
  | 'image'
  | 'video'
  | 'audio'
  | 'pdf'
  | 'text'
  | 'spreadsheet'
  | 'presentation'
  | 'archive'
  | { custom: string[] }

export type FileData = 
  | { base64: string }
  | { text: string }
  | { url: string }

// Interfaces
export interface FilePickerOptions {
  types?: FileType[]
  allowMultiple?: boolean
  startingDirectory?: string
}

export interface PickedFile {
  url: string
  name: string
  size: number
  mimeType?: string
  utiType: string
  isDirectory: boolean
}

export interface SaveFileOptions {
  suggestedName: string
  types: FileType[]
  data: FileData
}

export interface DocumentInfo {
  url: string
  name: string
  size: number
  createdDate: string
  modifiedDate: string
  accessedDate?: string
  mimeType?: string
  utiType: string
  isDirectory: boolean
  isPackage: boolean
  isHidden: boolean
  isAlias: boolean
  cloudStatus: CloudStatus
  tags: string[]
  attributes: Record<string, string>
}

export interface ImportOptions {
  types?: FileType[]
  allowMultiple?: boolean
  copyToApp?: boolean
}

export interface ExportOptions {
  fileUrls: string[]
  destinationName?: string
}

export interface FileFilter {
  types?: FileType[]
  namePattern?: string
  minSize?: number
  maxSize?: number
  modifiedAfter?: string
  modifiedBefore?: string
}

export interface ListOptions {
  directoryUrl?: string
  includeHidden?: boolean
  includePackages?: boolean
  sortBy?: SortOption
  filter?: FileFilter
}

export interface FileOperation {
  sourceUrl: string
  destinationUrl: string
  overwrite?: boolean
}

export interface ShareOptions {
  fileUrls: string[]
  excludeActivityTypes?: string[]
}

export interface PreviewOptions {
  fileUrl: string
  canEdit?: boolean
}

export interface CloudDownloadProgress {
  fileUrl: string
  progress: number
  downloadedBytes: number
  totalBytes: number
  status: CloudDownloadStatus
}

export interface MonitoringOptions {
  directoryUrls: string[]
  recursive?: boolean
  events?: MonitoringEvent[]
}

export interface FileChange {
  fileUrl: string
  eventType: MonitoringEvent
  oldUrl?: string
  timestamp: string
}

export interface SecurityScopedResource {
  url: string
  bookmarkData: string
}

export interface FilePermissions {
  readable: boolean
  writable: boolean
  deletable: boolean
  executable: boolean
}

export interface SpaceInfo {
  totalSpace: number
  availableSpace: number
  usedSpace: number
  importantSpace: number
  opportunisticSpace: number
}

// API Functions
export async function pickFile(options?: FilePickerOptions): Promise<PickedFile> {
  return await invoke('plugin:ios-files-v2|pick_file', { options: options || {} })
}

export async function pickMultipleFiles(options?: FilePickerOptions): Promise<PickedFile[]> {
  return await invoke('plugin:ios-files-v2|pick_multiple_files', { options: options || {} })
}

export async function pickFolder(): Promise<PickedFile> {
  return await invoke('plugin:ios-files-v2|pick_folder')
}

export async function saveFile(options: SaveFileOptions): Promise<string> {
  return await invoke('plugin:ios-files-v2|save_file', { options })
}

export async function openInFiles(url: string): Promise<void> {
  return await invoke('plugin:ios-files-v2|open_in_files', { url })
}

export async function importFromFiles(options?: ImportOptions): Promise<PickedFile[]> {
  return await invoke('plugin:ios-files-v2|import_from_files', { options: options || {} })
}

export async function exportToFiles(options: ExportOptions): Promise<void> {
  return await invoke('plugin:ios-files-v2|export_to_files', { options })
}

export async function listDocuments(options?: ListOptions): Promise<DocumentInfo[]> {
  return await invoke('plugin:ios-files-v2|list_documents', { options })
}

export async function readFile(url: string): Promise<FileData> {
  return await invoke('plugin:ios-files-v2|read_file', { url })
}

export async function writeFile(url: string, data: FileData): Promise<void> {
  return await invoke('plugin:ios-files-v2|write_file', { url, data })
}

export async function deleteFile(url: string): Promise<void> {
  return await invoke('plugin:ios-files-v2|delete_file', { url })
}

export async function moveFile(operation: FileOperation): Promise<string> {
  return await invoke('plugin:ios-files-v2|move_file', { operation })
}

export async function copyFile(operation: FileOperation): Promise<string> {
  return await invoke('plugin:ios-files-v2|copy_file', { operation })
}

export async function createFolder(url: string, name: string): Promise<string> {
  return await invoke('plugin:ios-files-v2|create_folder', { url, name })
}

export async function getFileInfo(url: string): Promise<DocumentInfo> {
  return await invoke('plugin:ios-files-v2|get_file_info', { url })
}

export async function shareFile(options: ShareOptions): Promise<void> {
  return await invoke('plugin:ios-files-v2|share_file', { options })
}

export async function previewFile(options: PreviewOptions): Promise<void> {
  return await invoke('plugin:ios-files-v2|preview_file', { options })
}

export async function getCloudStatus(url: string): Promise<CloudStatus> {
  return await invoke('plugin:ios-files-v2|get_cloud_status', { url })
}

export async function downloadFromCloud(url: string): Promise<void> {
  return await invoke('plugin:ios-files-v2|download_from_cloud', { url })
}

export async function evictFromLocal(url: string): Promise<void> {
  return await invoke('plugin:ios-files-v2|evict_from_local', { url })
}

export async function startMonitoring(options: MonitoringOptions): Promise<void> {
  return await invoke('plugin:ios-files-v2|start_monitoring', { options })
}

export async function stopMonitoring(): Promise<void> {
  return await invoke('plugin:ios-files-v2|stop_monitoring')
}
