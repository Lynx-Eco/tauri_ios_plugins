use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};
use chrono::{DateTime, Utc};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<ScreenTime<R>> {
    Ok(ScreenTime(app.clone()))
}

/// Access to the Screen Time APIs on desktop (returns errors as not available).
pub struct ScreenTime<R: Runtime>(AppHandle<R>);

impl<R: Runtime> ScreenTime<R> {
    pub fn request_authorization(&self) -> Result<bool> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_screen_time_summary(&self, _date: Option<DateTime<Utc>>) -> Result<ScreenTimeSummary> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_app_usage(&self, _range: Option<TimeRange>) -> Result<Vec<AppUsageInfo>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_category_usage(&self, _range: Option<TimeRange>) -> Result<Vec<CategoryUsageInfo>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_web_usage(&self, _range: Option<TimeRange>) -> Result<Vec<WebUsageInfo>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_device_activity(&self, _range: Option<TimeRange>) -> Result<Vec<DeviceActivity>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_notifications_summary(&self, _date: Option<DateTime<Utc>>) -> Result<NotificationsSummary> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_pickups_summary(&self, _date: Option<DateTime<Utc>>) -> Result<PickupsSummary> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_app_limit(&self, _request: SetAppLimitRequest) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_app_limits(&self) -> Result<Vec<AppLimit>> {
        Err(Error::NotAvailable)
    }
    
    pub fn remove_app_limit(&self, _limit_id: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_downtime_schedule(&self, _request: SetDowntimeRequest) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_downtime_schedule(&self) -> Result<Option<DowntimeSchedule>> {
        Err(Error::NotAvailable)
    }
    
    pub fn remove_downtime_schedule(&self, _schedule_id: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn block_app(&self, _bundle_id: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn unblock_app(&self, _bundle_id: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_blocked_apps(&self) -> Result<Vec<String>> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_communication_safety(&self, _settings: CommunicationSafetySettings) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_communication_safety_settings(&self) -> Result<CommunicationSafetySettings> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_screen_distance(&self) -> Result<ScreenDistance> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_usage_trends(&self, _period: TrendPeriod) -> Result<UsageTrend> {
        Err(Error::NotAvailable)
    }
    
    pub fn export_usage_report(&self, _range: TimeRange, _format: ExportFormat) -> Result<String> {
        Err(Error::NotAvailable)
    }
}