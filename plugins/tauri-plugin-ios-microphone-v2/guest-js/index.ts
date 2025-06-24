import { invoke } from '@tauri-apps/api/core'

// Enums
export enum AudioFormat {
  M4A = 'm4a',
  WAV = 'wav',
  CAF = 'caf',
  AIFF = 'aiff',
  MP3 = 'mp3'
}

export enum AudioQuality {
  Low = 'low',
  Medium = 'medium',
  High = 'high',
  Lossless = 'lossless'
}

export enum PortType {
  BuiltInMic = 'builtInMic',
  HeadsetMic = 'headsetMic',
  UsbAudio = 'usbAudio',
  BluetoothHFP = 'bluetoothHfp',
  CarAudio = 'carAudio',
  LineIn = 'lineIn',
  Other = 'other'
}

export enum RecordingState {
  Idle = 'idle',
  Recording = 'recording',
  Paused = 'paused',
  Stopping = 'stopping'
}

export enum RecordingEventType {
  Started = 'started',
  Paused = 'paused',
  Resumed = 'resumed',
  Stopped = 'stopped',
  LevelUpdate = 'levelUpdate',
  SilenceDetected = 'silenceDetected',
  Error = 'error',
  InputChanged = 'inputChanged'
}

// Interfaces
export interface PermissionStatus {
  microphone: 'granted' | 'denied' | 'prompt'
}

export interface RecordingOptions {
  format?: AudioFormat
  quality?: AudioQuality
  sampleRate?: number
  channels?: number
  bitRate?: number
  maxDuration?: number
  silenceDetection?: boolean
  noiseSuppression?: boolean
  echoCancellation?: boolean
}

export interface RecordingSession {
  id: string
  startTime: string
  format: AudioFormat
  sampleRate: number
  channels: number
  bitRate: number
}

export interface RecordingResult {
  path: string
  duration: number
  size: number
  format: AudioFormat
  sampleRate: number
  channels: number
  bitRate: number
  peakLevel: number
  averageLevel: number
}

export interface AudioLevels {
  peakLevel: number
  averageLevel: number
  isClipping: boolean
}

export interface AudioInput {
  id: string
  name: string
  portType: PortType
  isDefault: boolean
  channels: number
  sampleRate: number
}

export interface AudioMetrics {
  duration: number
  peakAmplitude: number
  averageAmplitude: number
  silenceRatio: number
  clippingCount: number
}

export interface RecordingEvent {
  eventType: RecordingEventType
  timestamp: string
  data?: any
}

// API Functions
export async function checkPermissions(): Promise<PermissionStatus> {
  return await invoke('plugin:ios-microphone-v2|check_permissions')
}

export async function requestPermissions(): Promise<PermissionStatus> {
  return await invoke('plugin:ios-microphone-v2|request_permissions')
}

export async function startRecording(options?: RecordingOptions): Promise<RecordingSession> {
  return await invoke('plugin:ios-microphone-v2|start_recording', { options })
}

export async function stopRecording(): Promise<RecordingResult> {
  return await invoke('plugin:ios-microphone-v2|stop_recording')
}

export async function pauseRecording(): Promise<void> {
  return await invoke('plugin:ios-microphone-v2|pause_recording')
}

export async function resumeRecording(): Promise<void> {
  return await invoke('plugin:ios-microphone-v2|resume_recording')
}

export async function getRecordingState(): Promise<RecordingState> {
  return await invoke('plugin:ios-microphone-v2|get_recording_state')
}

export async function getAudioLevels(): Promise<AudioLevels> {
  return await invoke('plugin:ios-microphone-v2|get_audio_levels')
}

export async function getAvailableInputs(): Promise<AudioInput[]> {
  return await invoke('plugin:ios-microphone-v2|get_available_inputs')
}

export async function setAudioInput(inputId: string): Promise<void> {
  return await invoke('plugin:ios-microphone-v2|set_audio_input', { inputId })
}

export async function getRecordingDuration(): Promise<number> {
  return await invoke('plugin:ios-microphone-v2|get_recording_duration')
}
