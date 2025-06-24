import { invoke } from '@tauri-apps/api/core'

// Enums
export enum AppCategory {
  Social = 'social',
  Entertainment = 'entertainment',
  Productivity = 'productivity',
  Education = 'education',
  Games = 'games',
  Health = 'health',
  Finance = 'finance',
  Shopping = 'shopping',
  News = 'news',
  Travel = 'travel',
  Utilities = 'utilities',
  Other = 'other'
}

export enum DeviceEventType {
  ScreenOn = 'screenOn',
  ScreenOff = 'screenOff',
  AppOpen = 'appOpen',
  AppClose = 'appClose',
  NotificationReceived = 'notificationReceived',
  NotificationInteracted = 'notificationInteracted'
}

export enum DayOfWeek {
  Sunday = 'sunday',
  Monday = 'monday',
  Tuesday = 'tuesday',
  Wednesday = 'wednesday',
  Thursday = 'thursday',
  Friday = 'friday',
  Saturday = 'saturday'
}

export enum TrendPeriod {
  Week = 'week',
  Month = 'month',
  Year = 'year'
}

export enum TrendDirection {
  Up = 'up',
  Down = 'down',
  Stable = 'stable'
}

export enum ReportFormat {
  Pdf = 'pdf',
  Csv = 'csv',
  Json = 'json'
}

// Interfaces
export interface ScreenTimeSummary {
  date: string
  totalScreenTime: number
  totalPickups: number
  firstPickup?: string
  mostUsedApp?: AppUsageInfo
  mostUsedCategory?: CategoryUsageInfo
}

export interface AppUsageInfo {
  bundleId: string
  displayName: string
  duration: number
  numberOfPickups: number
  numberOfNotifications: number
  category: AppCategory
  icon?: string
}

export interface CategoryUsageInfo {
  category: AppCategory
  duration: number
  numberOfApps: number
  apps: string[]
}

export interface WebUsageInfo {
  domain: string
  duration: number
  numberOfVisits: number
}

export interface DeviceActivity {
  timestamp: string
  eventType: DeviceEventType
  associatedApp?: string
}

export interface NotificationsSummary {
  totalNotifications: number
  notificationsByApp: Record<string, number>
  notificationsByHour: Record<number, number>
}

export interface PickupsSummary {
  totalPickups: number
  pickupsByHour: Record<number, number>
  averageTimeBetweenPickups: number
  longestSession: number
}

export interface AppLimit {
  id: string
  bundleIds: string[]
  timeLimit: number
  daysOfWeek: DayOfWeek[]
  enabled: boolean
}

export interface DowntimeSchedule {
  id: string
  startTime: string
  endTime: string
  daysOfWeek: DayOfWeek[]
  allowedApps: string[]
  enabled: boolean
}

export interface CommunicationNotificationSettings {
  notifyChild: boolean
  notifyParent: boolean
}

export interface CommunicationSafetySettings {
  checkPhotosAndVideos: boolean
  communicationSafetyEnabled: boolean
  notificationSettings: CommunicationNotificationSettings
}

export interface ScreenDistance {
  currentDistance: number
  isTooClose: boolean
  recommendedDistance: number
  durationTooClose: number
}

export interface UsageDataPoint {
  date: string
  screenTime: number
  pickups: number
}

export interface UsageTrend {
  period: TrendPeriod
  screenTimeTrend: TrendDirection
  pickupsTrend: TrendDirection
  screenTimeChange: number
  pickupsChange: number
  dataPoints: UsageDataPoint[]
}

export interface UsageReport {
  startDate: string
  endDate: string
  totalScreenTime: number
  averageDailyScreenTime: number
  totalPickups: number
  averageDailyPickups: number
  appUsage: AppUsageInfo[]
  categoryUsage: CategoryUsageInfo[]
  webUsage: WebUsageInfo[]
  dailySummaries: ScreenTimeSummary[]
}

export interface TimeRange {
  start: string
  end: string
}

export interface SetAppLimitRequest {
  bundleIds: string[]
  timeLimit: number
  daysOfWeek: DayOfWeek[]
}

export interface SetDowntimeRequest {
  startTime: string
  endTime: string
  daysOfWeek: DayOfWeek[]
  allowedApps: string[]
}

export interface ExportFormat {
  format: ReportFormat
  includeCharts: boolean
}

// API Functions
export async function requestAuthorization(): Promise<boolean> {
  return await invoke('plugin:ios-screentime-v2|request_authorization')
}

export async function getScreenTimeSummary(date?: string): Promise<ScreenTimeSummary> {
  return await invoke('plugin:ios-screentime-v2|get_screen_time_summary', { date })
}

export async function getAppUsage(range?: TimeRange): Promise<AppUsageInfo[]> {
  return await invoke('plugin:ios-screentime-v2|get_app_usage', { range })
}

export async function getCategoryUsage(range?: TimeRange): Promise<CategoryUsageInfo[]> {
  return await invoke('plugin:ios-screentime-v2|get_category_usage', { range })
}

export async function getWebUsage(range?: TimeRange): Promise<WebUsageInfo[]> {
  return await invoke('plugin:ios-screentime-v2|get_web_usage', { range })
}

export async function getDeviceActivity(range?: TimeRange): Promise<DeviceActivity[]> {
  return await invoke('plugin:ios-screentime-v2|get_device_activity', { range })
}

export async function getNotificationsSummary(date?: string): Promise<NotificationsSummary> {
  return await invoke('plugin:ios-screentime-v2|get_notifications_summary', { date })
}

export async function getPickupsSummary(date?: string): Promise<PickupsSummary> {
  return await invoke('plugin:ios-screentime-v2|get_pickups_summary', { date })
}

export async function setAppLimit(request: SetAppLimitRequest): Promise<string> {
  return await invoke('plugin:ios-screentime-v2|set_app_limit', { request })
}

export async function getAppLimits(): Promise<AppLimit[]> {
  return await invoke('plugin:ios-screentime-v2|get_app_limits')
}

export async function removeAppLimit(limitId: string): Promise<void> {
  return await invoke('plugin:ios-screentime-v2|remove_app_limit', { limitId })
}

export async function setDowntimeSchedule(request: SetDowntimeRequest): Promise<string> {
  return await invoke('plugin:ios-screentime-v2|set_downtime_schedule', { request })
}

export async function getDowntimeSchedule(): Promise<DowntimeSchedule | null> {
  return await invoke('plugin:ios-screentime-v2|get_downtime_schedule')
}

export async function removeDowntimeSchedule(scheduleId: string): Promise<void> {
  return await invoke('plugin:ios-screentime-v2|remove_downtime_schedule', { scheduleId })
}

export async function blockApp(bundleId: string): Promise<void> {
  return await invoke('plugin:ios-screentime-v2|block_app', { bundleId })
}

export async function unblockApp(bundleId: string): Promise<void> {
  return await invoke('plugin:ios-screentime-v2|unblock_app', { bundleId })
}

export async function getBlockedApps(): Promise<string[]> {
  return await invoke('plugin:ios-screentime-v2|get_blocked_apps')
}

export async function setCommunicationSafety(settings: CommunicationSafetySettings): Promise<void> {
  return await invoke('plugin:ios-screentime-v2|set_communication_safety', { settings })
}

export async function getCommunicationSafetySettings(): Promise<CommunicationSafetySettings> {
  return await invoke('plugin:ios-screentime-v2|get_communication_safety_settings')
}

export async function getScreenDistance(): Promise<ScreenDistance> {
  return await invoke('plugin:ios-screentime-v2|get_screen_distance')
}

export async function getUsageTrends(period: TrendPeriod): Promise<UsageTrend> {
  return await invoke('plugin:ios-screentime-v2|get_usage_trends', { period })
}

export async function exportUsageReport(range: TimeRange, format: ExportFormat): Promise<string> {
  return await invoke('plugin:ios-screentime-v2|export_usage_report', { range, format })
}
