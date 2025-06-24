import { invoke } from '@tauri-apps/api/core'

// Enums
export enum ProximityEventType {
  ProximityDetected = 'proximityDetected',
  ProximityCleared = 'proximityCleared',
  MonitoringStarted = 'monitoringStarted',
  MonitoringStopped = 'monitoringStopped',
  Error = 'error'
}

// Interfaces
export interface ProximityState {
  isClose: boolean
  timestamp: string
}

export interface ProximityConfiguration {
  enabled: boolean
  autoLockDisplay: boolean
}

export interface ProximityEvent {
  eventType: ProximityEventType
  state: ProximityState
  timestamp: string
}

export interface ProximityStatistics {
  totalDetections: number
  currentSessionDetections: number
  lastDetection?: string
  averageProximityDuration?: number
  monitoringDuration: number
}

export interface DisplayAutoLockState {
  enabled: boolean
  proximityMonitoringEnabled: boolean
}

// API Functions
export async function startProximityMonitoring(): Promise<void> {
  return await invoke('plugin:ios-proximity-v2|start_proximity_monitoring')
}

export async function stopProximityMonitoring(): Promise<void> {
  return await invoke('plugin:ios-proximity-v2|stop_proximity_monitoring')
}

export async function getProximityState(): Promise<ProximityState> {
  return await invoke('plugin:ios-proximity-v2|get_proximity_state')
}

export async function isProximityAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-proximity-v2|is_proximity_available')
}

export async function enableProximityMonitoring(): Promise<void> {
  return await invoke('plugin:ios-proximity-v2|enable_proximity_monitoring')
}

export async function disableProximityMonitoring(): Promise<void> {
  return await invoke('plugin:ios-proximity-v2|disable_proximity_monitoring')
}

export async function setDisplayAutoLock(enabled: boolean): Promise<void> {
  return await invoke('plugin:ios-proximity-v2|set_display_auto_lock', { enabled })
}

export async function getDisplayAutoLockState(): Promise<DisplayAutoLockState> {
  return await invoke('plugin:ios-proximity-v2|get_display_auto_lock_state')
}
