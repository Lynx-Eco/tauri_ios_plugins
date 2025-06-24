use tauri::{command, AppHandle, Runtime};
use chrono::{DateTime, Utc};

use crate::{ScreenTimeExt, TimeRange, SetAppLimitRequest, SetDowntimeRequest, CommunicationSafetySettings, TrendPeriod, ExportFormat, Result};

#[command]
pub(crate) async fn request_authorization<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.screentime().request_authorization()
}

#[command]
pub(crate) async fn get_screen_time_summary<R: Runtime>(
    app: AppHandle<R>,
    date: Option<DateTime<Utc>>,
) -> Result<crate::ScreenTimeSummary> {
    app.screentime().get_screen_time_summary(date)
}

#[command]
pub(crate) async fn get_app_usage<R: Runtime>(
    app: AppHandle<R>,
    range: Option<TimeRange>,
) -> Result<Vec<crate::AppUsageInfo>> {
    app.screentime().get_app_usage(range)
}

#[command]
pub(crate) async fn get_category_usage<R: Runtime>(
    app: AppHandle<R>,
    range: Option<TimeRange>,
) -> Result<Vec<crate::CategoryUsageInfo>> {
    app.screentime().get_category_usage(range)
}

#[command]
pub(crate) async fn get_web_usage<R: Runtime>(
    app: AppHandle<R>,
    range: Option<TimeRange>,
) -> Result<Vec<crate::WebUsageInfo>> {
    app.screentime().get_web_usage(range)
}

#[command]
pub(crate) async fn get_device_activity<R: Runtime>(
    app: AppHandle<R>,
    range: Option<TimeRange>,
) -> Result<Vec<crate::DeviceActivity>> {
    app.screentime().get_device_activity(range)
}

#[command]
pub(crate) async fn get_notifications_summary<R: Runtime>(
    app: AppHandle<R>,
    date: Option<DateTime<Utc>>,
) -> Result<crate::NotificationsSummary> {
    app.screentime().get_notifications_summary(date)
}

#[command]
pub(crate) async fn get_pickups_summary<R: Runtime>(
    app: AppHandle<R>,
    date: Option<DateTime<Utc>>,
) -> Result<crate::PickupsSummary> {
    app.screentime().get_pickups_summary(date)
}

#[command]
pub(crate) async fn set_app_limit<R: Runtime>(
    app: AppHandle<R>,
    request: SetAppLimitRequest,
) -> Result<String> {
    app.screentime().set_app_limit(request)
}

#[command]
pub(crate) async fn get_app_limits<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<crate::AppLimit>> {
    app.screentime().get_app_limits()
}

#[command]
pub(crate) async fn remove_app_limit<R: Runtime>(
    app: AppHandle<R>,
    limit_id: String,
) -> Result<()> {
    app.screentime().remove_app_limit(limit_id)
}

#[command]
pub(crate) async fn set_downtime_schedule<R: Runtime>(
    app: AppHandle<R>,
    request: SetDowntimeRequest,
) -> Result<String> {
    app.screentime().set_downtime_schedule(request)
}

#[command]
pub(crate) async fn get_downtime_schedule<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Option<crate::DowntimeSchedule>> {
    app.screentime().get_downtime_schedule()
}

#[command]
pub(crate) async fn remove_downtime_schedule<R: Runtime>(
    app: AppHandle<R>,
    schedule_id: String,
) -> Result<()> {
    app.screentime().remove_downtime_schedule(schedule_id)
}

#[command]
pub(crate) async fn block_app<R: Runtime>(
    app: AppHandle<R>,
    bundle_id: String,
) -> Result<()> {
    app.screentime().block_app(bundle_id)
}

#[command]
pub(crate) async fn unblock_app<R: Runtime>(
    app: AppHandle<R>,
    bundle_id: String,
) -> Result<()> {
    app.screentime().unblock_app(bundle_id)
}

#[command]
pub(crate) async fn get_blocked_apps<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<String>> {
    app.screentime().get_blocked_apps()
}

#[command]
pub(crate) async fn set_communication_safety<R: Runtime>(
    app: AppHandle<R>,
    settings: CommunicationSafetySettings,
) -> Result<()> {
    app.screentime().set_communication_safety(settings)
}

#[command]
pub(crate) async fn get_communication_safety_settings<R: Runtime>(
    app: AppHandle<R>,
) -> Result<CommunicationSafetySettings> {
    app.screentime().get_communication_safety_settings()
}

#[command]
pub(crate) async fn get_screen_distance<R: Runtime>(
    app: AppHandle<R>,
) -> Result<crate::ScreenDistance> {
    app.screentime().get_screen_distance()
}

#[command]
pub(crate) async fn get_usage_trends<R: Runtime>(
    app: AppHandle<R>,
    period: TrendPeriod,
) -> Result<crate::UsageTrend> {
    app.screentime().get_usage_trends(period)
}

#[command]
pub(crate) async fn export_usage_report<R: Runtime>(
    app: AppHandle<R>,
    range: TimeRange,
    format: ExportFormat,
) -> Result<String> {
    app.screentime().export_usage_report(range, format)
}