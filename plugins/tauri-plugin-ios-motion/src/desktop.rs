use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};
use chrono::{DateTime, Utc};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Motion<R>> {
    Ok(Motion(app.clone()))
}

/// Access to the Motion APIs on desktop (returns errors as not available).
pub struct Motion<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Motion<R> {
    pub fn start_accelerometer_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_accelerometer_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_accelerometer_data(&self) -> Result<AccelerometerData> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_gyroscope_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_gyroscope_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_gyroscope_data(&self) -> Result<GyroscopeData> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_magnetometer_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_magnetometer_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_magnetometer_data(&self) -> Result<MagnetometerData> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_device_motion_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_device_motion_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_device_motion_data(&self) -> Result<DeviceMotionData> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_update_interval(&self, _intervals: MotionUpdateInterval) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn is_accelerometer_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn is_gyroscope_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn is_magnetometer_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn is_device_motion_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn get_motion_activity(&self) -> Result<MotionActivity> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_activity_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_activity_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn query_activity_history(&self, _query: ActivityQuery) -> Result<Vec<MotionActivity>> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_pedometer_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_pedometer_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_pedometer_data(&self, _start_date: DateTime<Utc>, _end_date: DateTime<Utc>) -> Result<PedometerData> {
        Err(Error::NotAvailable)
    }
    
    pub fn is_pedometer_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn is_step_counting_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn is_distance_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn is_floor_counting_available(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn get_altimeter_data(&self) -> Result<AltimeterData> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_altimeter_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_altimeter_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn is_relative_altitude_available(&self) -> Result<bool> {
        Ok(false)
    }
}