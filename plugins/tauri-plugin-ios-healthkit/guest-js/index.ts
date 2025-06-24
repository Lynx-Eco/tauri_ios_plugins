import { invoke } from '@tauri-apps/api/core';

// Enums
export enum HealthKitDataType {
  Steps = 'steps',
  HeartRate = 'heartRate',
  ActiveEnergyBurned = 'activeEnergyBurned',
  DistanceWalkingRunning = 'distanceWalkingRunning',
  FlightsClimbed = 'flightsClimbed',
  Height = 'height',
  Weight = 'weight',
  BodyMassIndex = 'bodyMassIndex',
  BodyFatPercentage = 'bodyFatPercentage',
  SleepAnalysis = 'sleepAnalysis',
  BiologicalSex = 'biologicalSex',
  DateOfBirth = 'dateOfBirth',
  BloodType = 'bloodType'
}

export enum WorkoutActivityType {
  Running = 'running',
  Walking = 'walking',
  Cycling = 'cycling',
  Swimming = 'swimming',
  Yoga = 'yoga',
  Strength = 'strength',
  Other = 'other'
}

export enum BiologicalSex {
  NotSet = 'notSet',
  Female = 'female',
  Male = 'male',
  Other = 'other'
}

export enum BloodType {
  NotSet = 'notSet',
  APositive = 'aPositive',
  ANegative = 'aNegative',
  BPositive = 'bPositive',
  BNegative = 'bNegative',
  ABPositive = 'abPositive',
  ABNegative = 'abNegative',
  OPositive = 'oPositive',
  ONegative = 'oNegative'
}

export type PermissionState = 'granted' | 'denied' | 'prompt';

// Interfaces
export interface HealthKitPermissions {
  steps: PermissionState;
  heartRate: PermissionState;
  activeEnergyBurned: PermissionState;
  distanceWalkingRunning: PermissionState;
  flightsClimbed: PermissionState;
  height: PermissionState;
  weight: PermissionState;
  bodyMassIndex: PermissionState;
  bodyFatPercentage: PermissionState;
  sleepAnalysis: PermissionState;
}

export interface PermissionStatus {
  read: HealthKitPermissions;
  write: HealthKitPermissions;
}

export interface PermissionRequest {
  read: HealthKitDataType[];
  write: HealthKitDataType[];
}

export interface QuantityQuery {
  dataType: HealthKitDataType;
  startDate: string;
  endDate: string;
  limit?: number;
}

export interface QuantitySample {
  dataType: HealthKitDataType;
  value: number;
  unit: string;
  startDate: string;
  endDate: string;
  metadata?: Record<string, unknown>;
}

export interface CategorySample {
  dataType: HealthKitDataType;
  value: number;
  startDate: string;
  endDate: string;
  metadata?: Record<string, unknown>;
}

export interface WorkoutSample {
  activityType: WorkoutActivityType;
  startDate: string;
  endDate: string;
  duration: number;
  totalEnergyBurned?: number;
  totalDistance?: number;
  metadata?: Record<string, unknown>;
}

// API Functions
export async function checkPermissions(): Promise<PermissionStatus> {
  return await invoke('plugin:ios-healthkit|check_permissions');
}

export async function requestPermissions(permissions: PermissionRequest): Promise<PermissionStatus> {
  return await invoke('plugin:ios-healthkit|request_permissions', { permissions });
}

export async function queryQuantitySamples(query: QuantityQuery): Promise<QuantitySample[]> {
  return await invoke('plugin:ios-healthkit|query_quantity_samples', { query });
}

export async function queryCategorySamples(query: QuantityQuery): Promise<CategorySample[]> {
  return await invoke('plugin:ios-healthkit|query_category_samples', { query });
}

export async function queryWorkoutSamples(
  startDate: string,
  endDate: string,
  limit?: number
): Promise<WorkoutSample[]> {
  return await invoke('plugin:ios-healthkit|query_workout_samples', { startDate, endDate, limit });
}

export async function writeQuantitySample(sample: QuantitySample): Promise<void> {
  return await invoke('plugin:ios-healthkit|write_quantity_sample', { sample });
}

export async function writeCategorySample(sample: CategorySample): Promise<void> {
  return await invoke('plugin:ios-healthkit|write_category_sample', { sample });
}

export async function writeWorkout(workout: WorkoutSample): Promise<void> {
  return await invoke('plugin:ios-healthkit|write_workout', { workout });
}

export async function getBiologicalSex(): Promise<BiologicalSex> {
  return await invoke('plugin:ios-healthkit|get_biological_sex');
}

export async function getDateOfBirth(): Promise<string> {
  return await invoke('plugin:ios-healthkit|get_date_of_birth');
}

export async function getBloodType(): Promise<BloodType> {
  return await invoke('plugin:ios-healthkit|get_blood_type');
}