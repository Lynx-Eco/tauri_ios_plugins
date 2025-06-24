use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_barometer);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Barometer<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_barometer)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.barometer", "BarometerPlugin")?;
    
    Ok(Barometer(handle))
}

/// Access to the Barometer APIs on mobile.
pub struct Barometer<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Barometer<R> {
    pub fn start_pressure_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startPressureUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_pressure_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopPressureUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn get_pressure_data(&self) -> Result<PressureData> {
        self.0
            .run_mobile_plugin("getPressureData", ())
            .map_err(Into::into)
    }
    
    pub fn is_barometer_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isBarometerAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn set_update_interval(&self, interval: f64) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            interval: f64,
        }
        
        self.0
            .run_mobile_plugin("setUpdateInterval", Args { interval })
            .map_err(Into::into)
    }
    
    pub fn get_reference_pressure(&self) -> Result<f64> {
        self.0
            .run_mobile_plugin("getReferencePressure", ())
            .map_err(Into::into)
    }
    
    pub fn set_reference_pressure(&self, pressure: f64) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            pressure: f64,
        }
        
        self.0
            .run_mobile_plugin("setReferencePressure", Args { pressure })
            .map_err(Into::into)
    }
    
    pub fn get_altitude_from_pressure(&self, pressure: f64) -> Result<f64> {
        #[derive(serde::Serialize)]
        struct Args {
            pressure: f64,
        }
        
        self.0
            .run_mobile_plugin("getAltitudeFromPressure", Args { pressure })
            .map_err(Into::into)
    }
    
    pub fn start_altitude_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startAltitudeUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_altitude_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopAltitudeUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn get_weather_data(&self) -> Result<WeatherData> {
        self.0
            .run_mobile_plugin("getWeatherData", ())
            .map_err(Into::into)
    }
    
    pub fn calibrate_barometer(&self, calibration: BarometerCalibration) -> Result<()> {
        self.0
            .run_mobile_plugin("calibrateBarometer", calibration)
            .map_err(Into::into)
    }
}