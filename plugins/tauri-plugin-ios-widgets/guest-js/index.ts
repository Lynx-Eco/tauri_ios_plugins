import { invoke } from '@tauri-apps/api/core'

// Enums
export enum WidgetFamily {
  SystemSmall = 'systemSmall',
  SystemMedium = 'systemMedium',
  SystemLarge = 'systemLarge',
  SystemExtraLarge = 'systemExtraLarge',
  AccessoryCircular = 'accessoryCircular',
  AccessoryRectangular = 'accessoryRectangular',
  AccessoryInline = 'accessoryInline'
}

export enum FontWeight {
  UltraLight = 'ultraLight',
  Thin = 'thin',
  Light = 'light',
  Regular = 'regular',
  Medium = 'medium',
  Semibold = 'semibold',
  Bold = 'bold',
  Heavy = 'heavy',
  Black = 'black'
}

export enum FontDesign {
  Default = 'default',
  Serif = 'serif',
  Rounded = 'rounded',
  Monospaced = 'monospaced'
}

export enum WidgetEventType {
  Appeared = 'appeared',
  Disappeared = 'disappeared',
  Tapped = 'tapped',
  TimelineReloaded = 'timelineReloaded',
  ConfigurationChanged = 'configurationChanged',
  Error = 'error'
}

// Types
export type TimelineReloadPolicy = 
  | { atEnd: true }
  | { after: string }
  | { never: true }

// Interfaces
export interface WidgetConfiguration {
  kind: string
  family: WidgetFamily
  intentConfiguration?: Record<string, any>
}

export interface WidgetFont {
  size: number
  weight: FontWeight
  design: FontDesign
}

export interface WidgetContent {
  title?: string
  subtitle?: string
  body?: string
  image?: string
  backgroundImage?: string
  tintColor?: string
  font?: WidgetFont
  customData: Record<string, any>
}

export interface WidgetRelevance {
  score: number
  duration: number
}

export interface WidgetData {
  kind: string
  family?: WidgetFamily
  content: WidgetContent
  refreshDate?: string
  expirationDate?: string
  relevance?: WidgetRelevance
}

export interface WidgetInfo {
  bundleIdentifier: string
  displayName: string
  description: string
  supportedFamilies: WidgetFamily[]
  configurationDisplayName?: string
  customIntents: string[]
}

export interface WidgetUrl {
  scheme: string
  host?: string
  path?: string
  queryParameters: Record<string, string>
}

export interface WidgetPreview {
  family: WidgetFamily
  displayName: string
  description: string
  previewImage: string
}

export interface RefreshInterval {
  startDate: string
  intervalSeconds: number
  repeatCount?: number
}

export interface WidgetRefreshSchedule {
  widgetKind: string
  refreshIntervals: RefreshInterval[]
}

export interface WidgetEntry {
  date: string
  content: WidgetContent
  relevance?: WidgetRelevance
}

export interface WidgetTimeline {
  entries: WidgetEntry[]
  policy: TimelineReloadPolicy
}

export interface WidgetEvent {
  eventType: WidgetEventType
  widgetKind: string
  widgetFamily?: WidgetFamily
  timestamp: string
  data?: any
}

// API Functions
export async function reloadAllTimelines(): Promise<void> {
  return await invoke('plugin:ios-widgets-v2|reload_all_timelines')
}

export async function reloadTimelines(widgetKinds: string[]): Promise<void> {
  return await invoke('plugin:ios-widgets-v2|reload_timelines', { widgetKinds })
}

export async function getCurrentConfigurations(): Promise<WidgetConfiguration[]> {
  return await invoke('plugin:ios-widgets-v2|get_current_configurations')
}

export async function setWidgetData(data: WidgetData): Promise<void> {
  return await invoke('plugin:ios-widgets-v2|set_widget_data', { data })
}

export async function getWidgetData(kind: string, family?: WidgetFamily): Promise<WidgetData | null> {
  return await invoke('plugin:ios-widgets-v2|get_widget_data', { kind, family })
}

export async function clearWidgetData(kind: string): Promise<void> {
  return await invoke('plugin:ios-widgets-v2|clear_widget_data', { kind })
}

export async function requestWidgetUpdate(kind: string): Promise<void> {
  return await invoke('plugin:ios-widgets-v2|request_widget_update', { kind })
}

export async function getWidgetInfo(kind: string): Promise<WidgetInfo> {
  return await invoke('plugin:ios-widgets-v2|get_widget_info', { kind })
}

export async function setWidgetUrl(kind: string, url: WidgetUrl): Promise<void> {
  return await invoke('plugin:ios-widgets-v2|set_widget_url', { kind, url })
}

export async function getWidgetUrl(kind: string): Promise<WidgetUrl | null> {
  return await invoke('plugin:ios-widgets-v2|get_widget_url', { kind })
}

export async function previewWidgetData(data: WidgetData): Promise<WidgetPreview[]> {
  return await invoke('plugin:ios-widgets-v2|preview_widget_data', { data })
}

export async function getWidgetFamilies(kind: string): Promise<WidgetFamily[]> {
  return await invoke('plugin:ios-widgets-v2|get_widget_families', { kind })
}

export async function scheduleWidgetRefresh(schedule: WidgetRefreshSchedule): Promise<string> {
  return await invoke('plugin:ios-widgets-v2|schedule_widget_refresh', { schedule })
}

export async function cancelWidgetRefresh(scheduleId: string): Promise<void> {
  return await invoke('plugin:ios-widgets-v2|cancel_widget_refresh', { scheduleId })
}