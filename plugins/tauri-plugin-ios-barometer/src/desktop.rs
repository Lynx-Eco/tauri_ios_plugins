use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Barometer<R>> {
    Ok(Barometer(app.clone()))
}

/// Access to the Barometer APIs on desktop (returns errors as not available).
pub struct Barometer<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Barometer<R> {
    pub fn start_pressure_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_pressure_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_pressure_data(&self) -> Result<PressureData> {
        Err(Error::NotAvailable)
    }
    
    pub fn is_barometer_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn set_update_interval(&self, _interval: f64) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_reference_pressure(&self) -> Result<f64> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_reference_pressure(&self, _pressure: f64) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_altitude_from_pressure(&self, _pressure: f64) -> Result<f64> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_altitude_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_altitude_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_weather_data(&self) -> Result<WeatherData> {
        Err(Error::NotAvailable)
    }
    
    pub fn calibrate_barometer(&self, _calibration: BarometerCalibration) -> Result<()> {
        Err(Error::NotAvailable)
    }
}