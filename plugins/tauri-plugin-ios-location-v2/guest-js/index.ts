import { invoke } from '@tauri-apps/api/core'

// Enums
export enum LocationAccuracy {
  Best = 'best',
  BestForNavigation = 'bestForNavigation',
  NearestTenMeters = 'nearestTenMeters',
  HundredMeters = 'hundredMeters',
  Kilometer = 'kilometer',
  ThreeKilometers = 'threeKilometers',
  Reduced = 'reduced'
}

export enum LocationEventType {
  LocationUpdate = 'locationUpdate',
  HeadingUpdate = 'headingUpdate',
  RegionEntered = 'regionEntered',
  RegionExited = 'regionExited',
  AuthorizationChanged = 'authorizationChanged',
  Error = 'error'
}

// Interfaces
export interface LocationPermissions {
  whenInUse: 'granted' | 'denied' | 'prompt'
  always: 'granted' | 'denied' | 'prompt'
}

export interface PermissionRequest {
  accuracy: LocationAccuracy
  background: boolean
}

export interface LocationOptions {
  accuracy?: LocationAccuracy
  distanceFilter?: number
  timeout?: number
  maximumAge?: number
  enableHighAccuracy?: boolean
  showBackgroundLocationIndicator?: boolean
}

export interface Coordinates {
  latitude: number
  longitude: number
}

export interface Floor {
  level: number
}

export interface LocationData {
  coordinates: Coordinates
  altitude?: number
  accuracy: number
  altitudeAccuracy?: number
  heading?: number
  speed?: number
  timestamp: string
  floor?: Floor
}

export interface Region {
  identifier: string
  center: Coordinates
  radius: number
  notifyOnEntry: boolean
  notifyOnExit: boolean
}

export interface Heading {
  magneticHeading: number
  trueHeading: number
  headingAccuracy: number
  timestamp: string
}

export interface Placemark {
  name?: string
  thoroughfare?: string
  subThoroughfare?: string
  locality?: string
  subLocality?: string
  administrativeArea?: string
  subAdministrativeArea?: string
  postalCode?: string
  isoCountryCode?: string
  country?: string
  inlandWater?: string
  ocean?: string
  areasOfInterest: string[]
  formattedAddress?: string
}

export interface GeocodingResult {
  coordinates: Coordinates
  placemark: Placemark
}

export interface LocationEvent {
  eventType: LocationEventType
  data: any
}

export interface DistanceRequest {
  from: Coordinates
  to: Coordinates
}

// API Functions
export async function checkPermissions(): Promise<LocationPermissions> {
  return await invoke('plugin:ios-location-v2|check_permissions')
}

export async function requestPermissions(request: PermissionRequest): Promise<LocationPermissions> {
  return await invoke('plugin:ios-location-v2|request_permissions', { request })
}

export async function getCurrentLocation(options?: LocationOptions): Promise<LocationData> {
  return await invoke('plugin:ios-location-v2|get_current_location', { options })
}

export async function startLocationUpdates(options?: LocationOptions): Promise<void> {
  return await invoke('plugin:ios-location-v2|start_location_updates', { options })
}

export async function stopLocationUpdates(): Promise<void> {
  return await invoke('plugin:ios-location-v2|stop_location_updates')
}

export async function startSignificantLocationUpdates(): Promise<void> {
  return await invoke('plugin:ios-location-v2|start_significant_location_updates')
}

export async function stopSignificantLocationUpdates(): Promise<void> {
  return await invoke('plugin:ios-location-v2|stop_significant_location_updates')
}

export async function startMonitoringRegion(region: Region): Promise<void> {
  return await invoke('plugin:ios-location-v2|start_monitoring_region', { region })
}

export async function stopMonitoringRegion(identifier: string): Promise<void> {
  return await invoke('plugin:ios-location-v2|stop_monitoring_region', { identifier })
}

export async function getMonitoredRegions(): Promise<Region[]> {
  return await invoke('plugin:ios-location-v2|get_monitored_regions')
}

export async function startHeadingUpdates(): Promise<void> {
  return await invoke('plugin:ios-location-v2|start_heading_updates')
}

export async function stopHeadingUpdates(): Promise<void> {
  return await invoke('plugin:ios-location-v2|stop_heading_updates')
}

export async function geocodeAddress(address: string): Promise<GeocodingResult[]> {
  return await invoke('plugin:ios-location-v2|geocode_address', { address })
}

export async function reverseGeocode(coordinates: Coordinates): Promise<Placemark[]> {
  return await invoke('plugin:ios-location-v2|reverse_geocode', { coordinates })
}

export async function getDistance(from: Coordinates, to: Coordinates): Promise<number> {
  return await invoke('plugin:ios-location-v2|get_distance', { from, to })
}
