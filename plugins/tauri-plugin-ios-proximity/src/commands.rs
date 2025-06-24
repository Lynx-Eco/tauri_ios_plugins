use tauri::{command, AppHandle, Runtime};

use crate::{models::*, ProximityExt, Result};

#[command]
pub(crate) async fn start_proximity_monitoring<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.proximity().start_proximity_monitoring()
}

#[command]
pub(crate) async fn stop_proximity_monitoring<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.proximity().stop_proximity_monitoring()
}

#[command]
pub(crate) async fn get_proximity_state<R: Runtime>(
    app: AppHandle<R>,
) -> Result<ProximityState> {
    app.proximity().get_proximity_state()
}

#[command]
pub(crate) async fn is_proximity_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.proximity().is_proximity_available()
}

#[command]
pub(crate) async fn enable_proximity_monitoring<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.proximity().enable_proximity_monitoring()
}

#[command]
pub(crate) async fn disable_proximity_monitoring<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.proximity().disable_proximity_monitoring()
}

#[command]
pub(crate) async fn set_display_auto_lock<R: Runtime>(
    app: AppHandle<R>,
    enabled: bool,
) -> Result<()> {
    app.proximity().set_display_auto_lock(enabled)
}

#[command]
pub(crate) async fn get_display_auto_lock_state<R: Runtime>(
    app: AppHandle<R>,
) -> Result<DisplayAutoLockState> {
    app.proximity().get_display_auto_lock_state()
}