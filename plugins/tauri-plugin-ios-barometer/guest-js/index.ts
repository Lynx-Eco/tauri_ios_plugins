import { invoke } from '@tauri-apps/api/core'

// Enums
export enum PressureTrend {
  Rising = 'rising',
  Falling = 'falling',
  Steady = 'steady'
}

export enum WeatherCondition {
  Fair = 'fair',
  Changing = 'changing',
  Stormy = 'stormy',
  Unknown = 'unknown'
}

export enum BarometerEventType {
  PressureUpdate = 'pressureUpdate',
  AltitudeUpdate = 'altitudeUpdate',
  WeatherChange = 'weatherChange',
  CalibrationComplete = 'calibrationComplete',
  Error = 'error'
}

// Interfaces
export interface PressureData {
  pressure: number
  relativeAltitude?: number
  temperature?: number
  timestamp: string
}

export interface AltitudeData {
  altitude: number
  pressure: number
  referencePressure: number
  timestamp: string
}

export interface WeatherData {
  pressure: number
  pressureTrend: PressureTrend
  altitude?: number
  temperature?: number
  humidity?: number
  weatherCondition: WeatherCondition
  timestamp: string
}

export interface BarometerCalibration {
  referencePressure: number
  referenceAltitude: number
  calibrationDate: string
}

export interface BarometerConfiguration {
  updateInterval: number
  useCalibration: boolean
  enableWeatherPrediction: boolean
  altitudeSmoothing: boolean
}

export interface BarometerEvent {
  eventType: BarometerEventType
  data: any
  timestamp: string
}

export interface PressureEntry {
  pressure: number
  timestamp: string
}

export interface PressureHistory {
  entries: PressureEntry[]
  durationHours: number
  averagePressure: number
  minPressure: number
  maxPressure: number
}

// API Functions
export async function startPressureUpdates(): Promise<void> {
  return await invoke('plugin:ios-barometer-v2|start_pressure_updates')
}

export async function stopPressureUpdates(): Promise<void> {
  return await invoke('plugin:ios-barometer-v2|stop_pressure_updates')
}

export async function getPressureData(): Promise<PressureData> {
  return await invoke('plugin:ios-barometer-v2|get_pressure_data')
}

export async function isBarometerAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-barometer-v2|is_barometer_available')
}

export async function setUpdateInterval(interval: number): Promise<void> {
  return await invoke('plugin:ios-barometer-v2|set_update_interval', { interval })
}

export async function getReferencePressure(): Promise<number> {
  return await invoke('plugin:ios-barometer-v2|get_reference_pressure')
}

export async function setReferencePressure(pressure: number): Promise<void> {
  return await invoke('plugin:ios-barometer-v2|set_reference_pressure', { pressure })
}

export async function getAltitudeFromPressure(pressure: number): Promise<number> {
  return await invoke('plugin:ios-barometer-v2|get_altitude_from_pressure', { pressure })
}

export async function startAltitudeUpdates(): Promise<void> {
  return await invoke('plugin:ios-barometer-v2|start_altitude_updates')
}

export async function stopAltitudeUpdates(): Promise<void> {
  return await invoke('plugin:ios-barometer-v2|stop_altitude_updates')
}

export async function getWeatherData(): Promise<WeatherData> {
  return await invoke('plugin:ios-barometer-v2|get_weather_data')
}

export async function calibrateBarometer(calibration: BarometerCalibration): Promise<void> {
  return await invoke('plugin:ios-barometer-v2|calibrate_barometer', { calibration })
}
