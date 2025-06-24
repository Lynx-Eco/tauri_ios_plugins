import { invoke } from '@tauri-apps/api/core'

// Enums
export enum MagneticFieldAccuracy {
  Uncalibrated = 'uncalibrated',
  Low = 'low',
  Medium = 'medium',
  High = 'high'
}

export enum ActivityConfidence {
  Low = 'low',
  Medium = 'medium',
  High = 'high'
}

export enum MotionEventType {
  AccelerometerUpdate = 'accelerometerUpdate',
  GyroscopeUpdate = 'gyroscopeUpdate',
  MagnetometerUpdate = 'magnetometerUpdate',
  DeviceMotionUpdate = 'deviceMotionUpdate',
  ActivityUpdate = 'activityUpdate',
  PedometerUpdate = 'pedometerUpdate',
  AltimeterUpdate = 'altimeterUpdate',
  Error = 'error'
}

// Interfaces
export interface AccelerometerData {
  x: number
  y: number
  z: number
  timestamp: string
}

export interface GyroscopeData {
  x: number
  y: number
  z: number
  timestamp: string
}

export interface MagnetometerData {
  x: number
  y: number
  z: number
  accuracy: MagneticFieldAccuracy
  timestamp: string
}

export interface Vector3D {
  x: number
  y: number
  z: number
}

export interface RotationMatrix {
  m11: number
  m12: number
  m13: number
  m21: number
  m22: number
  m23: number
  m31: number
  m32: number
  m33: number
}

export interface Quaternion {
  x: number
  y: number
  z: number
  w: number
}

export interface Attitude {
  roll: number
  pitch: number
  yaw: number
  rotationMatrix: RotationMatrix
  quaternion: Quaternion
}

export interface RotationRate {
  x: number
  y: number
  z: number
}

export interface CalibratedMagneticField {
  field: Vector3D
  accuracy: MagneticFieldAccuracy
}

export interface DeviceMotionData {
  attitude: Attitude
  rotationRate: RotationRate
  gravity: Vector3D
  userAcceleration: Vector3D
  magneticField?: CalibratedMagneticField
  heading?: number
  timestamp: string
}

export interface MotionActivity {
  stationary: boolean
  walking: boolean
  running: boolean
  automotive: boolean
  cycling: boolean
  unknown: boolean
  startDate: string
  confidence: ActivityConfidence
}

export interface PedometerData {
  startDate: string
  endDate: string
  numberOfSteps: number
  distance?: number
  floorsAscended?: number
  floorsDescended?: number
  currentPace?: number
  currentCadence?: number
  averageActivePace?: number
}

export interface AltimeterData {
  relativeAltitude: number
  pressure: number
  timestamp: string
}

export interface MotionUpdateInterval {
  accelerometer?: number
  gyroscope?: number
  magnetometer?: number
  deviceMotion?: number
}

export interface MotionAvailability {
  accelerometer: boolean
  gyroscope: boolean
  magnetometer: boolean
  deviceMotion: boolean
  activity: boolean
  pedometer: boolean
  stepCounting: boolean
  distance: boolean
  floorCounting: boolean
  altimeter: boolean
  relativeAltitude: boolean
}

export interface MotionEvent {
  eventType: MotionEventType
  data: any
  timestamp: string
}

export interface ActivityQuery {
  startDate: string
  endDate: string
}

// API Functions
export async function startAccelerometerUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|start_accelerometer_updates')
}

export async function stopAccelerometerUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|stop_accelerometer_updates')
}

export async function getAccelerometerData(): Promise<AccelerometerData> {
  return await invoke('plugin:ios-motion-v2|get_accelerometer_data')
}

export async function startGyroscopeUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|start_gyroscope_updates')
}

export async function stopGyroscopeUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|stop_gyroscope_updates')
}

export async function getGyroscopeData(): Promise<GyroscopeData> {
  return await invoke('plugin:ios-motion-v2|get_gyroscope_data')
}

export async function startMagnetometerUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|start_magnetometer_updates')
}

export async function stopMagnetometerUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|stop_magnetometer_updates')
}

export async function getMagnetometerData(): Promise<MagnetometerData> {
  return await invoke('plugin:ios-motion-v2|get_magnetometer_data')
}

export async function startDeviceMotionUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|start_device_motion_updates')
}

export async function stopDeviceMotionUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|stop_device_motion_updates')
}

export async function getDeviceMotionData(): Promise<DeviceMotionData> {
  return await invoke('plugin:ios-motion-v2|get_device_motion_data')
}

export async function setUpdateInterval(intervals: MotionUpdateInterval): Promise<void> {
  return await invoke('plugin:ios-motion-v2|set_update_interval', { intervals })
}

export async function isAccelerometerAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_accelerometer_available')
}

export async function isGyroscopeAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_gyroscope_available')
}

export async function isMagnetometerAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_magnetometer_available')
}

export async function isDeviceMotionAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_device_motion_available')
}

export async function getMotionActivity(): Promise<MotionActivity> {
  return await invoke('plugin:ios-motion-v2|get_motion_activity')
}

export async function startActivityUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|start_activity_updates')
}

export async function stopActivityUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|stop_activity_updates')
}

export async function queryActivityHistory(query: ActivityQuery): Promise<MotionActivity[]> {
  return await invoke('plugin:ios-motion-v2|query_activity_history', { query })
}

export async function startPedometerUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|start_pedometer_updates')
}

export async function stopPedometerUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|stop_pedometer_updates')
}

export async function getPedometerData(startDate: string, endDate: string): Promise<PedometerData> {
  return await invoke('plugin:ios-motion-v2|get_pedometer_data', { startDate, endDate })
}

export async function isPedometerAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_pedometer_available')
}

export async function isStepCountingAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_step_counting_available')
}

export async function isDistanceAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_distance_available')
}

export async function isFloorCountingAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_floor_counting_available')
}

export async function getAltimeterData(): Promise<AltimeterData> {
  return await invoke('plugin:ios-motion-v2|get_altimeter_data')
}

export async function startAltimeterUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|start_altimeter_updates')
}

export async function stopAltimeterUpdates(): Promise<void> {
  return await invoke('plugin:ios-motion-v2|stop_altimeter_updates')
}

export async function isRelativeAltitudeAvailable(): Promise<boolean> {
  return await invoke('plugin:ios-motion-v2|is_relative_altitude_available')
}