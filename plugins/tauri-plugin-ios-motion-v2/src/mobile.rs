use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};
use chrono::{DateTime, Utc};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_motion);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Motion<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_motion)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.motion", "MotionPlugin")?;
    
    Ok(Motion(handle))
}

/// Access to the Motion APIs on mobile.
pub struct Motion<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Motion<R> {
    pub fn start_accelerometer_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startAccelerometerUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_accelerometer_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopAccelerometerUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn get_accelerometer_data(&self) -> Result<AccelerometerData> {
        self.0
            .run_mobile_plugin("getAccelerometerData", ())
            .map_err(Into::into)
    }
    
    pub fn start_gyroscope_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startGyroscopeUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_gyroscope_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopGyroscopeUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn get_gyroscope_data(&self) -> Result<GyroscopeData> {
        self.0
            .run_mobile_plugin("getGyroscopeData", ())
            .map_err(Into::into)
    }
    
    pub fn start_magnetometer_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startMagnetometerUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_magnetometer_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopMagnetometerUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn get_magnetometer_data(&self) -> Result<MagnetometerData> {
        self.0
            .run_mobile_plugin("getMagnetometerData", ())
            .map_err(Into::into)
    }
    
    pub fn start_device_motion_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startDeviceMotionUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_device_motion_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopDeviceMotionUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn get_device_motion_data(&self) -> Result<DeviceMotionData> {
        self.0
            .run_mobile_plugin("getDeviceMotionData", ())
            .map_err(Into::into)
    }
    
    pub fn set_update_interval(&self, intervals: MotionUpdateInterval) -> Result<()> {
        self.0
            .run_mobile_plugin("setUpdateInterval", intervals)
            .map_err(Into::into)
    }
    
    pub fn is_accelerometer_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isAccelerometerAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn is_gyroscope_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isGyroscopeAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn is_magnetometer_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isMagnetometerAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn is_device_motion_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isDeviceMotionAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn get_motion_activity(&self) -> Result<MotionActivity> {
        self.0
            .run_mobile_plugin("getMotionActivity", ())
            .map_err(Into::into)
    }
    
    pub fn start_activity_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startActivityUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_activity_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopActivityUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn query_activity_history(&self, query: ActivityQuery) -> Result<Vec<MotionActivity>> {
        self.0
            .run_mobile_plugin("queryActivityHistory", query)
            .map_err(Into::into)
    }
    
    pub fn start_pedometer_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startPedometerUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_pedometer_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopPedometerUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn get_pedometer_data(&self, start_date: DateTime<Utc>, end_date: DateTime<Utc>) -> Result<PedometerData> {
        #[derive(serde::Serialize)]
        struct Args {
            start_date: DateTime<Utc>,
            end_date: DateTime<Utc>,
        }
        
        self.0
            .run_mobile_plugin("getPedometerData", Args { start_date, end_date })
            .map_err(Into::into)
    }
    
    pub fn is_pedometer_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isPedometerAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn is_step_counting_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isStepCountingAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn is_distance_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isDistanceAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn is_floor_counting_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isFloorCountingAvailable", ())
            .map_err(Into::into)
    }
    
    pub fn get_altimeter_data(&self) -> Result<AltimeterData> {
        self.0
            .run_mobile_plugin("getAltimeterData", ())
            .map_err(Into::into)
    }
    
    pub fn start_altimeter_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("startAltimeterUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn stop_altimeter_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopAltimeterUpdates", ())
            .map_err(Into::into)
    }
    
    pub fn is_relative_altitude_available(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isRelativeAltitudeAvailable", ())
            .map_err(Into::into)
    }
}