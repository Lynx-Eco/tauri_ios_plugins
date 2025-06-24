use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};
use chrono::{DateTime, Utc};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_screentime);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<ScreenTime<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_screentime)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.screentime", "ScreenTimePlugin")?;
    
    Ok(ScreenTime(handle))
}

/// Access to the Screen Time APIs on mobile.
pub struct ScreenTime<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> ScreenTime<R> {
    pub fn request_authorization(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("requestAuthorization", ())
            .map_err(Into::into)
    }
    
    pub fn get_screen_time_summary(&self, date: Option<DateTime<Utc>>) -> Result<ScreenTimeSummary> {
        #[derive(serde::Serialize)]
        struct Args {
            date: Option<DateTime<Utc>>,
        }
        
        self.0
            .run_mobile_plugin("getScreenTimeSummary", Args { date })
            .map_err(Into::into)
    }
    
    pub fn get_app_usage(&self, range: Option<TimeRange>) -> Result<Vec<AppUsageInfo>> {
        #[derive(serde::Serialize)]
        struct Args {
            range: Option<TimeRange>,
        }
        
        self.0
            .run_mobile_plugin("getAppUsage", Args { range })
            .map_err(Into::into)
    }
    
    pub fn get_category_usage(&self, range: Option<TimeRange>) -> Result<Vec<CategoryUsageInfo>> {
        #[derive(serde::Serialize)]
        struct Args {
            range: Option<TimeRange>,
        }
        
        self.0
            .run_mobile_plugin("getCategoryUsage", Args { range })
            .map_err(Into::into)
    }
    
    pub fn get_web_usage(&self, range: Option<TimeRange>) -> Result<Vec<WebUsageInfo>> {
        #[derive(serde::Serialize)]
        struct Args {
            range: Option<TimeRange>,
        }
        
        self.0
            .run_mobile_plugin("getWebUsage", Args { range })
            .map_err(Into::into)
    }
    
    pub fn get_device_activity(&self, range: Option<TimeRange>) -> Result<Vec<DeviceActivity>> {
        #[derive(serde::Serialize)]
        struct Args {
            range: Option<TimeRange>,
        }
        
        self.0
            .run_mobile_plugin("getDeviceActivity", Args { range })
            .map_err(Into::into)
    }
    
    pub fn get_notifications_summary(&self, date: Option<DateTime<Utc>>) -> Result<NotificationsSummary> {
        #[derive(serde::Serialize)]
        struct Args {
            date: Option<DateTime<Utc>>,
        }
        
        self.0
            .run_mobile_plugin("getNotificationsSummary", Args { date })
            .map_err(Into::into)
    }
    
    pub fn get_pickups_summary(&self, date: Option<DateTime<Utc>>) -> Result<PickupsSummary> {
        #[derive(serde::Serialize)]
        struct Args {
            date: Option<DateTime<Utc>>,
        }
        
        self.0
            .run_mobile_plugin("getPickupsSummary", Args { date })
            .map_err(Into::into)
    }
    
    pub fn set_app_limit(&self, request: SetAppLimitRequest) -> Result<String> {
        self.0
            .run_mobile_plugin("setAppLimit", request)
            .map_err(Into::into)
    }
    
    pub fn get_app_limits(&self) -> Result<Vec<AppLimit>> {
        self.0
            .run_mobile_plugin("getAppLimits", ())
            .map_err(Into::into)
    }
    
    pub fn remove_app_limit(&self, limit_id: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            limit_id: String,
        }
        
        self.0
            .run_mobile_plugin("removeAppLimit", Args { limit_id })
            .map_err(Into::into)
    }
    
    pub fn set_downtime_schedule(&self, request: SetDowntimeRequest) -> Result<String> {
        self.0
            .run_mobile_plugin("setDowntimeSchedule", request)
            .map_err(Into::into)
    }
    
    pub fn get_downtime_schedule(&self) -> Result<Option<DowntimeSchedule>> {
        self.0
            .run_mobile_plugin("getDowntimeSchedule", ())
            .map_err(Into::into)
    }
    
    pub fn remove_downtime_schedule(&self, schedule_id: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            schedule_id: String,
        }
        
        self.0
            .run_mobile_plugin("removeDowntimeSchedule", Args { schedule_id })
            .map_err(Into::into)
    }
    
    pub fn block_app(&self, bundle_id: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            bundle_id: String,
        }
        
        self.0
            .run_mobile_plugin("blockApp", Args { bundle_id })
            .map_err(Into::into)
    }
    
    pub fn unblock_app(&self, bundle_id: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            bundle_id: String,
        }
        
        self.0
            .run_mobile_plugin("unblockApp", Args { bundle_id })
            .map_err(Into::into)
    }
    
    pub fn get_blocked_apps(&self) -> Result<Vec<String>> {
        self.0
            .run_mobile_plugin("getBlockedApps", ())
            .map_err(Into::into)
    }
    
    pub fn set_communication_safety(&self, settings: CommunicationSafetySettings) -> Result<()> {
        self.0
            .run_mobile_plugin("setCommunicationSafety", settings)
            .map_err(Into::into)
    }
    
    pub fn get_communication_safety_settings(&self) -> Result<CommunicationSafetySettings> {
        self.0
            .run_mobile_plugin("getCommunicationSafetySettings", ())
            .map_err(Into::into)
    }
    
    pub fn get_screen_distance(&self) -> Result<ScreenDistance> {
        self.0
            .run_mobile_plugin("getScreenDistance", ())
            .map_err(Into::into)
    }
    
    pub fn get_usage_trends(&self, period: TrendPeriod) -> Result<UsageTrend> {
        #[derive(serde::Serialize)]
        struct Args {
            period: TrendPeriod,
        }
        
        self.0
            .run_mobile_plugin("getUsageTrends", Args { period })
            .map_err(Into::into)
    }
    
    pub fn export_usage_report(&self, range: TimeRange, format: ExportFormat) -> Result<String> {
        #[derive(serde::Serialize)]
        struct Args {
            range: TimeRange,
            format: ExportFormat,
        }
        
        self.0
            .run_mobile_plugin("exportUsageReport", Args { range, format })
            .map_err(Into::into)
    }
}