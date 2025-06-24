use tauri::{command, AppHandle, Runtime};

use crate::{models::*, BarometerExt, Result};

#[command]
pub(crate) async fn start_pressure_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.barometer().start_pressure_updates()
}

#[command]
pub(crate) async fn stop_pressure_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.barometer().stop_pressure_updates()
}

#[command]
pub(crate) async fn get_pressure_data<R: Runtime>(
    app: AppHandle<R>,
) -> Result<PressureData> {
    app.barometer().get_pressure_data()
}

#[command]
pub(crate) async fn is_barometer_available<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.barometer().is_barometer_available()
}

#[command]
pub(crate) async fn set_update_interval<R: Runtime>(
    app: AppHandle<R>,
    interval: f64,
) -> Result<()> {
    app.barometer().set_update_interval(interval)
}

#[command]
pub(crate) async fn get_reference_pressure<R: Runtime>(
    app: AppHandle<R>,
) -> Result<f64> {
    app.barometer().get_reference_pressure()
}

#[command]
pub(crate) async fn set_reference_pressure<R: Runtime>(
    app: AppHandle<R>,
    pressure: f64,
) -> Result<()> {
    app.barometer().set_reference_pressure(pressure)
}

#[command]
pub(crate) async fn get_altitude_from_pressure<R: Runtime>(
    app: AppHandle<R>,
    pressure: f64,
) -> Result<f64> {
    app.barometer().get_altitude_from_pressure(pressure)
}

#[command]
pub(crate) async fn start_altitude_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.barometer().start_altitude_updates()
}

#[command]
pub(crate) async fn stop_altitude_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.barometer().stop_altitude_updates()
}

#[command]
pub(crate) async fn get_weather_data<R: Runtime>(
    app: AppHandle<R>,
) -> Result<WeatherData> {
    app.barometer().get_weather_data()
}

#[command]
pub(crate) async fn calibrate_barometer<R: Runtime>(
    app: AppHandle<R>,
    calibration: BarometerCalibration,
) -> Result<()> {
    app.barometer().calibrate_barometer(calibration)
}