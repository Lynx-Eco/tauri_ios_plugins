use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_widgets);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Widgets<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_widgets)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.widgets", "WidgetsPlugin")?;
    
    Ok(Widgets(handle))
}

/// Access to the Widgets APIs on mobile.
pub struct Widgets<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Widgets<R> {
    pub fn reload_all_timelines(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("reloadAllTimelines", ())
            .map_err(Into::into)
    }
    
    pub fn reload_timelines(&self, widget_kinds: Vec<String>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            widget_kinds: Vec<String>,
        }
        
        self.0
            .run_mobile_plugin("reloadTimelines", Args { widget_kinds })
            .map_err(Into::into)
    }
    
    pub fn get_current_configurations(&self) -> Result<Vec<WidgetConfiguration>> {
        self.0
            .run_mobile_plugin("getCurrentConfigurations", ())
            .map_err(Into::into)
    }
    
    pub fn set_widget_data(&self, data: WidgetData) -> Result<()> {
        self.0
            .run_mobile_plugin("setWidgetData", data)
            .map_err(Into::into)
    }
    
    pub fn get_widget_data(&self, kind: String, family: Option<WidgetFamily>) -> Result<Option<WidgetData>> {
        #[derive(serde::Serialize)]
        struct Args {
            kind: String,
            family: Option<WidgetFamily>,
        }
        
        self.0
            .run_mobile_plugin("getWidgetData", Args { kind, family })
            .map_err(Into::into)
    }
    
    pub fn clear_widget_data(&self, kind: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            kind: String,
        }
        
        self.0
            .run_mobile_plugin("clearWidgetData", Args { kind })
            .map_err(Into::into)
    }
    
    pub fn request_widget_update(&self, kind: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            kind: String,
        }
        
        self.0
            .run_mobile_plugin("requestWidgetUpdate", Args { kind })
            .map_err(Into::into)
    }
    
    pub fn get_widget_info(&self, kind: String) -> Result<WidgetInfo> {
        #[derive(serde::Serialize)]
        struct Args {
            kind: String,
        }
        
        self.0
            .run_mobile_plugin("getWidgetInfo", Args { kind })
            .map_err(Into::into)
    }
    
    pub fn set_widget_url(&self, kind: String, url: WidgetUrl) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            kind: String,
            url: WidgetUrl,
        }
        
        self.0
            .run_mobile_plugin("setWidgetUrl", Args { kind, url })
            .map_err(Into::into)
    }
    
    pub fn get_widget_url(&self, kind: String) -> Result<Option<WidgetUrl>> {
        #[derive(serde::Serialize)]
        struct Args {
            kind: String,
        }
        
        self.0
            .run_mobile_plugin("getWidgetUrl", Args { kind })
            .map_err(Into::into)
    }
    
    pub fn preview_widget_data(&self, data: WidgetData) -> Result<Vec<WidgetPreview>> {
        self.0
            .run_mobile_plugin("previewWidgetData", data)
            .map_err(Into::into)
    }
    
    pub fn get_widget_families(&self, kind: String) -> Result<Vec<WidgetFamily>> {
        #[derive(serde::Serialize)]
        struct Args {
            kind: String,
        }
        
        self.0
            .run_mobile_plugin("getWidgetFamilies", Args { kind })
            .map_err(Into::into)
    }
    
    pub fn schedule_widget_refresh(&self, schedule: WidgetRefreshSchedule) -> Result<String> {
        self.0
            .run_mobile_plugin("scheduleWidgetRefresh", schedule)
            .map_err(Into::into)
    }
    
    pub fn cancel_widget_refresh(&self, schedule_id: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            schedule_id: String,
        }
        
        self.0
            .run_mobile_plugin("cancelWidgetRefresh", Args { schedule_id })
            .map_err(Into::into)
    }
}