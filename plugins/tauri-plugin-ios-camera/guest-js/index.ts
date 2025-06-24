import { invoke } from '@tauri-apps/api/core'

/**
 * Camera position enumeration
 */
export enum CameraPosition {
  Front = 'front',
  Back = 'back',
  External = 'external'
}

/**
 * Image quality settings
 */
export enum ImageQuality {
  Low = 'low',
  Medium = 'medium',
  High = 'high',
  Original = 'original'
}

/**
 * Video quality settings
 */
export enum VideoQuality {
  Low = 'low',        // 480p
  Medium = 'medium',  // 720p
  High = 'high',      // 1080p
  Ultra = 'ultra'     // 4K
}

/**
 * Flash mode settings
 */
export enum FlashMode {
  Off = 'off',
  On = 'on',
  Auto = 'auto',
  Torch = 'torch'
}

/**
 * Media type selection
 */
export enum MediaType {
  Image = 'image',
  Video = 'video',
  Any = 'any'
}

/**
 * Permission state enumeration (from Tauri)
 */
export enum PermissionState {
  Granted = 'granted',
  Denied = 'denied',
  Prompt = 'prompt'
}

/**
 * Camera and media permissions status
 */
export interface CameraPermissions {
  camera: PermissionState;
  photoLibrary: PermissionState;
  microphone: PermissionState;
}

/**
 * Permission request configuration
 */
export interface PermissionRequest {
  camera: boolean;
  photoLibrary: boolean;
  microphone: boolean;
}

/**
 * Options for taking photos
 */
export interface PhotoOptions {
  cameraPosition?: CameraPosition;
  quality?: ImageQuality;
  allowEditing?: boolean;
  saveToGallery?: boolean;
  flashMode?: FlashMode;
  maxWidth?: number;
  maxHeight?: number;
}

/**
 * Options for recording videos
 */
export interface VideoOptions {
  cameraPosition?: CameraPosition;
  quality?: VideoQuality;
  maxDuration?: number; // seconds
  saveToGallery?: boolean;
  flashMode?: FlashMode;
}

/**
 * Options for picking media from gallery
 */
export interface PickerOptions {
  allowMultiple?: boolean;
  includeMetadata?: boolean;
  limit?: number;
  mediaTypes?: MediaType[];
}

/**
 * Result from capturing photo or video
 */
export interface CaptureResult {
  path: string;
  width: number;
  height: number;
  size: number; // bytes
  mimeType: string;
  duration?: number; // seconds for video
  metadata?: MediaMetadata;
}

/**
 * GPS location information
 */
export interface Location {
  latitude: number;
  longitude: number;
  altitude?: number;
}

/**
 * Media item from gallery
 */
export interface MediaItem {
  id: string;
  path: string;
  width: number;
  height: number;
  size: number; // bytes
  mimeType: string;
  creationDate?: string;
  modificationDate?: string;
  duration?: number; // seconds for video
  location?: Location;
  metadata?: MediaMetadata;
}

/**
 * Metadata for photos/videos
 */
export interface MediaMetadata {
  make?: string;
  model?: string;
  orientation?: number;
  dateTimeOriginal?: string;
  fNumber?: number;
  exposureTime?: string;
  isoSpeed?: number;
  gpsLatitude?: number;
  gpsLongitude?: number;
}

/**
 * Camera device information
 */
export interface CameraInfo {
  id: string;
  position: CameraPosition;
  name: string;
  hasFlash: boolean;
  hasTorch: boolean;
  maxZoom: number;
  minZoom: number;
  supportsVideo: boolean;
  supportsPhoto: boolean;
}

/**
 * Check current camera and media permissions
 * @returns Current permission states
 */
export async function checkPermissions(): Promise<CameraPermissions> {
  return await invoke<CameraPermissions>('plugin:ios-camera|check_permissions');
}

/**
 * Request camera and media permissions
 * @param permissions - Which permissions to request
 * @returns Updated permission states
 */
export async function requestPermissions(permissions: PermissionRequest): Promise<CameraPermissions> {
  return await invoke<CameraPermissions>('plugin:ios-camera|request_permissions', {
    permissions
  });
}

/**
 * Take a photo using the camera
 * @param options - Photo capture options
 * @returns Capture result with photo information
 */
export async function takePhoto(options?: PhotoOptions): Promise<CaptureResult> {
  return await invoke<CaptureResult>('plugin:ios-camera|take_photo', {
    options
  });
}

/**
 * Record a video using the camera
 * @param options - Video recording options
 * @returns Capture result with video information
 */
export async function recordVideo(options?: VideoOptions): Promise<CaptureResult> {
  return await invoke<CaptureResult>('plugin:ios-camera|record_video', {
    options
  });
}

/**
 * Pick image(s) from the photo gallery
 * @param options - Image picker options
 * @returns Array of selected media items
 */
export async function pickImage(options?: PickerOptions): Promise<MediaItem[]> {
  return await invoke<MediaItem[]>('plugin:ios-camera|pick_image', {
    options
  });
}

/**
 * Pick video(s) from the photo gallery
 * @param options - Video picker options
 * @returns Array of selected media items
 */
export async function pickVideo(options?: PickerOptions): Promise<MediaItem[]> {
  return await invoke<MediaItem[]>('plugin:ios-camera|pick_video', {
    options
  });
}

/**
 * Pick any media (images or videos) from the photo gallery
 * @param options - Media picker options
 * @returns Array of selected media items
 */
export async function pickMedia(options?: PickerOptions): Promise<MediaItem[]> {
  return await invoke<MediaItem[]>('plugin:ios-camera|pick_media', {
    options
  });
}

/**
 * Get information about available cameras
 * @returns Array of camera information
 */
export async function getCameraInfo(): Promise<CameraInfo[]> {
  return await invoke<CameraInfo[]>('plugin:ios-camera|get_camera_info');
}