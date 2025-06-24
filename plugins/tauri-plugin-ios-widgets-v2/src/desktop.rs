use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Widgets<R>> {
    Ok(Widgets(app.clone()))
}

/// Access to the Widgets APIs on desktop (returns errors as not available).
pub struct Widgets<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Widgets<R> {
    pub fn reload_all_timelines(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn reload_timelines(&self, _widget_kinds: Vec<String>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_current_configurations(&self) -> Result<Vec<WidgetConfiguration>> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_widget_data(&self, _data: WidgetData) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_widget_data(&self, _kind: String, _family: Option<WidgetFamily>) -> Result<Option<WidgetData>> {
        Err(Error::NotAvailable)
    }
    
    pub fn clear_widget_data(&self, _kind: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn request_widget_update(&self, _kind: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_widget_info(&self, _kind: String) -> Result<WidgetInfo> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_widget_url(&self, _kind: String, _url: WidgetUrl) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_widget_url(&self, _kind: String) -> Result<Option<WidgetUrl>> {
        Err(Error::NotAvailable)
    }
    
    pub fn preview_widget_data(&self, _data: WidgetData) -> Result<Vec<WidgetPreview>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_widget_families(&self, _kind: String) -> Result<Vec<WidgetFamily>> {
        Err(Error::NotAvailable)
    }
    
    pub fn schedule_widget_refresh(&self, _schedule: WidgetRefreshSchedule) -> Result<String> {
        Err(Error::NotAvailable)
    }
    
    pub fn cancel_widget_refresh(&self, _schedule_id: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
}