# Tauri Plugin iOS Screen Time

A Tauri plugin for accessing iOS Screen Time and app usage statistics APIs.

## Features

- Request Screen Time authorization
- Get screen time summaries and statistics
- Monitor app usage by app and category
- Track web browsing usage
- Monitor device activity and events
- Get notification statistics
- Track device pickups
- Set and manage app limits
- Configure downtime schedules
- Block/unblock specific apps
- Configure communication safety settings
- Monitor screen distance (iOS 17+)
- View usage trends over time
- Export usage reports in various formats

## Installation

Add the plugin to your Tauri project:

```toml
[dependencies]
tauri-plugin-ios-screentime = { path = "../path/to/plugin" }
```

## Usage

```rust
use tauri_plugin_ios_screentime::{ScreenTimeExt, TimeRange, SetAppLimitRequest, DayOfWeek};

#[tauri::command]
async fn check_screen_time<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<(), String> {
    // Request authorization
    let authorized = app.screentime()
        .request_authorization()
        .map_err(|e| e.to_string())?;
    
    if !authorized {
        return Err("Screen Time authorization denied".to_string());
    }
    
    // Get today's summary
    let summary = app.screentime()
        .get_screen_time_summary(None)
        .map_err(|e| e.to_string())?;
    
    println!("Total screen time: {} seconds", summary.total_screen_time);
    println!("Total pickups: {}", summary.total_pickups);
    
    // Get app usage
    let apps = app.screentime()
        .get_app_usage(None)
        .map_err(|e| e.to_string())?;
    
    for app in apps {
        println!("{}: {} seconds", app.display_name, app.duration);
    }
    
    Ok(())
}

#[tauri::command]
async fn set_social_media_limit<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<String, String> {
    let request = SetAppLimitRequest {
        bundle_ids: vec![
            "com.facebook.app".to_string(),
            "com.twitter.app".to_string(),
            "com.instagram.app".to_string(),
        ],
        time_limit: 3600, // 1 hour per day
        days_of_week: vec![
            DayOfWeek::Monday,
            DayOfWeek::Tuesday,
            DayOfWeek::Wednesday,
            DayOfWeek::Thursday,
            DayOfWeek::Friday,
        ],
    };
    
    let limit_id = app.screentime()
        .set_app_limit(request)
        .map_err(|e| e.to_string())?;
    
    Ok(limit_id)
}
```

## Permissions

### iOS

Add to your `Info.plist`:

```xml
<key>NSFamilyControlsUsageDescription</key>
<string>This app needs access to Screen Time data to show your app usage statistics.</string>
```

### Required Capabilities

Add to your app's entitlements:

```xml
<key>com.apple.developer.family-controls</key>
<true/>
```

## Platform Support

This plugin only supports iOS 16.0+. Desktop platforms will return `NotSupported` errors.

## Important Notes

1. **Family Sharing**: Some features require Family Sharing to be enabled
2. **Parental Controls**: If parental controls are active, some operations may be restricted
3. **Privacy**: Screen Time data is sensitive - always explain why you need access
4. **Authorization**: Users must explicitly grant Screen Time access
5. **Data Accuracy**: Some data is aggregated and may not be real-time

## Screen Time Categories

The plugin recognizes the following app categories:
- Social
- Entertainment
- Productivity
- Education
- Games
- Health
- Finance
- Shopping
- News
- Travel
- Utilities
- Other

## Error Handling

The plugin provides detailed error types:
- `NotAvailable`: Screen Time not available on device
- `AuthorizationDenied`: User denied access
- `AuthorizationRestricted`: Access restricted by parental controls
- `FamilySharingRequired`: Feature requires Family Sharing
- `FeatureNotSupported`: Feature not available on current iOS version

## API Methods

### Authorization
- `request_authorization()` - Request Screen Time access

### Usage Data
- `get_screen_time_summary(date)` - Get daily summary
- `get_app_usage(range)` - Get app usage statistics
- `get_category_usage(range)` - Get usage by category
- `get_web_usage(range)` - Get web browsing statistics
- `get_device_activity(range)` - Get device events

### Statistics
- `get_notifications_summary(date)` - Get notification statistics
- `get_pickups_summary(date)` - Get pickup statistics
- `get_usage_trends(period)` - Get usage trends over time

### Limits & Restrictions
- `set_app_limit(request)` - Set time limit for apps
- `get_app_limits()` - Get all app limits
- `remove_app_limit(id)` - Remove an app limit
- `set_downtime_schedule(request)` - Set downtime hours
- `get_downtime_schedule()` - Get downtime schedule
- `remove_downtime_schedule(id)` - Remove downtime
- `block_app(bundle_id)` - Block an app
- `unblock_app(bundle_id)` - Unblock an app
- `get_blocked_apps()` - Get list of blocked apps

### Safety Features
- `set_communication_safety(settings)` - Configure communication safety
- `get_communication_safety_settings()` - Get safety settings
- `get_screen_distance()` - Get screen distance data (iOS 17+)

### Reports
- `export_usage_report(range, format)` - Export usage report

## Example: Usage Dashboard

```rust
use tauri_plugin_ios_screentime::{ScreenTimeExt, TrendPeriod};
use chrono::{DateTime, Utc, Duration};

#[tauri::command]
async fn get_usage_dashboard<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<UsageDashboard, String> {
    let screentime = app.screentime();
    
    // Get today's summary
    let today_summary = screentime
        .get_screen_time_summary(None)
        .map_err(|e| e.to_string())?;
    
    // Get weekly trend
    let weekly_trend = screentime
        .get_usage_trends(TrendPeriod::Week)
        .map_err(|e| e.to_string())?;
    
    // Get top 5 apps
    let mut app_usage = screentime
        .get_app_usage(None)
        .map_err(|e| e.to_string())?;
    
    app_usage.sort_by(|a, b| b.duration.cmp(&a.duration));
    let top_apps: Vec<_> = app_usage.into_iter().take(5).collect();
    
    Ok(UsageDashboard {
        today_screen_time: today_summary.total_screen_time,
        today_pickups: today_summary.total_pickups,
        weekly_trend,
        top_apps,
    })
}
```