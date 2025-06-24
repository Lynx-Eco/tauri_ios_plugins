use tauri::{command, AppHandle, Runtime};

use crate::{models::*, WidgetsExt, Result};

#[command]
pub(crate) async fn reload_all_timelines<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.widgets().reload_all_timelines()
}

#[command]
pub(crate) async fn reload_timelines<R: Runtime>(
    app: AppHandle<R>,
    widget_kinds: Vec<String>,
) -> Result<()> {
    app.widgets().reload_timelines(widget_kinds)
}

#[command]
pub(crate) async fn get_current_configurations<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<WidgetConfiguration>> {
    app.widgets().get_current_configurations()
}

#[command]
pub(crate) async fn set_widget_data<R: Runtime>(
    app: AppHandle<R>,
    data: WidgetData,
) -> Result<()> {
    app.widgets().set_widget_data(data)
}

#[command]
pub(crate) async fn get_widget_data<R: Runtime>(
    app: AppHandle<R>,
    kind: String,
    family: Option<WidgetFamily>,
) -> Result<Option<WidgetData>> {
    app.widgets().get_widget_data(kind, family)
}

#[command]
pub(crate) async fn clear_widget_data<R: Runtime>(
    app: AppHandle<R>,
    kind: String,
) -> Result<()> {
    app.widgets().clear_widget_data(kind)
}

#[command]
pub(crate) async fn request_widget_update<R: Runtime>(
    app: AppHandle<R>,
    kind: String,
) -> Result<()> {
    app.widgets().request_widget_update(kind)
}

#[command]
pub(crate) async fn get_widget_info<R: Runtime>(
    app: AppHandle<R>,
    kind: String,
) -> Result<WidgetInfo> {
    app.widgets().get_widget_info(kind)
}

#[command]
pub(crate) async fn set_widget_url<R: Runtime>(
    app: AppHandle<R>,
    kind: String,
    url: WidgetUrl,
) -> Result<()> {
    app.widgets().set_widget_url(kind, url)
}

#[command]
pub(crate) async fn get_widget_url<R: Runtime>(
    app: AppHandle<R>,
    kind: String,
) -> Result<Option<WidgetUrl>> {
    app.widgets().get_widget_url(kind)
}

#[command]
pub(crate) async fn preview_widget_data<R: Runtime>(
    app: AppHandle<R>,
    data: WidgetData,
) -> Result<Vec<WidgetPreview>> {
    app.widgets().preview_widget_data(data)
}

#[command]
pub(crate) async fn get_widget_families<R: Runtime>(
    app: AppHandle<R>,
    kind: String,
) -> Result<Vec<WidgetFamily>> {
    app.widgets().get_widget_families(kind)
}

#[command]
pub(crate) async fn schedule_widget_refresh<R: Runtime>(
    app: AppHandle<R>,
    schedule: WidgetRefreshSchedule,
) -> Result<String> {
    app.widgets().schedule_widget_refresh(schedule)
}

#[command]
pub(crate) async fn cancel_widget_refresh<R: Runtime>(
    app: AppHandle<R>,
    schedule_id: String,
) -> Result<()> {
    app.widgets().cancel_widget_refresh(schedule_id)
}