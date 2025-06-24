use tauri::{command, AppHandle, Runtime};
use chrono::{DateTime, Utc};

use crate::{models::*, MotionExt, Result};

#[command]
pub(crate) async fn start_accelerometer_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().start_accelerometer_updates()
}

#[command]
pub(crate) async fn stop_accelerometer_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().stop_accelerometer_updates()
}

#[command]
pub(crate) async fn get_accelerometer_data<R: Runtime>(
    app: AppHandle<R>,
) -> Result<AccelerometerData> {
    app.motion().get_accelerometer_data()
}

#[command]
pub(crate) async fn start_gyroscope_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().start_gyroscope_updates()
}

#[command]
pub(crate) async fn stop_gyroscope_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().stop_gyroscope_updates()
}

#[command]
pub(crate) async fn get_gyroscope_data<R: Runtime>(
    app: AppHandle<R>,
) -> Result<GyroscopeData> {
    app.motion().get_gyroscope_data()
}

#[command]
pub(crate) async fn start_magnetometer_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().start_magnetometer_updates()
}

#[command]
pub(crate) async fn stop_magnetometer_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().stop_magnetometer_updates()
}

#[command]
pub(crate) async fn get_magnetometer_data<R: Runtime>(
    app: AppHandle<R>,
) -> Result<MagnetometerData> {
    app.motion().get_magnetometer_data()
}

#[command]
pub(crate) async fn start_device_motion_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().start_device_motion_updates()
}

#[command]
pub(crate) async fn stop_device_motion_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().stop_device_motion_updates()
}

#[command]
pub(crate) async fn get_device_motion_data<R: Runtime>(
    app: AppHandle<R>,
) -> Result<DeviceMotionData> {
    app.motion().get_device_motion_data()
}

#[command]
pub(crate) async fn set_update_interval<R: Runtime>(
    app: AppHandle<R>,
    intervals: MotionUpdateInterval,
) -> Result<()> {
    app.motion().set_update_interval(intervals)
}

#[command]
pub(crate) async fn is_accelerometer_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_accelerometer_available()
}

#[command]
pub(crate) async fn is_gyroscope_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_gyroscope_available()
}

#[command]
pub(crate) async fn is_magnetometer_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_magnetometer_available()
}

#[command]
pub(crate) async fn is_device_motion_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_device_motion_available()
}

#[command]
pub(crate) async fn get_motion_activity<R: Runtime>(
    app: AppHandle<R>,
) -> Result<MotionActivity> {
    app.motion().get_motion_activity()
}

#[command]
pub(crate) async fn start_activity_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().start_activity_updates()
}

#[command]
pub(crate) async fn stop_activity_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().stop_activity_updates()
}

#[command]
pub(crate) async fn query_activity_history<R: Runtime>(
    app: AppHandle<R>,
    query: ActivityQuery,
) -> Result<Vec<MotionActivity>> {
    app.motion().query_activity_history(query)
}

#[command]
pub(crate) async fn start_pedometer_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().start_pedometer_updates()
}

#[command]
pub(crate) async fn stop_pedometer_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().stop_pedometer_updates()
}

#[command]
pub(crate) async fn get_pedometer_data<R: Runtime>(
    app: AppHandle<R>,
    start_date: DateTime<Utc>,
    end_date: DateTime<Utc>,
) -> Result<PedometerData> {
    app.motion().get_pedometer_data(start_date, end_date)
}

#[command]
pub(crate) async fn is_pedometer_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_pedometer_available()
}

#[command]
pub(crate) async fn is_step_counting_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_step_counting_available()
}

#[command]
pub(crate) async fn is_distance_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_distance_available()
}

#[command]
pub(crate) async fn is_floor_counting_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_floor_counting_available()
}

#[command]
pub(crate) async fn get_altimeter_data<R: Runtime>(
    app: AppHandle<R>,
) -> Result<AltimeterData> {
    app.motion().get_altimeter_data()
}

#[command]
pub(crate) async fn start_altimeter_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().start_altimeter_updates()
}

#[command]
pub(crate) async fn stop_altimeter_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.motion().stop_altimeter_updates()
}

#[command]
pub(crate) async fn is_relative_altitude_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.motion().is_relative_altitude_available()
}