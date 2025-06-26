use tauri::{command, AppHandle, Runtime};

use crate::{LocationExt, LocationPermissions, PermissionRequest, LocationOptions, LocationData, Region, Coordinates, GeocodingResult, Placemark, Result};

#[command]
pub(crate) async fn check_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<LocationPermissions> {
    app.location().check_permissions()
}

#[command]
pub(crate) async fn request_permissions<R: Runtime>(
    app: AppHandle<R>,
    request: PermissionRequest,
) -> Result<LocationPermissions> {
    app.location().request_permissions(request)
}

#[command]
pub(crate) async fn get_current_location<R: Runtime>(
    app: AppHandle<R>,
    options: Option<LocationOptions>,
) -> Result<LocationData> {
    app.location().get_current_location(options.unwrap_or_default())
}

#[command]
pub(crate) async fn start_location_updates<R: Runtime>(
    app: AppHandle<R>,
    options: Option<LocationOptions>,
) -> Result<()> {
    app.location().start_location_updates(options.unwrap_or_default())
}

#[command]
pub(crate) async fn stop_location_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.location().stop_location_updates()
}

#[command]
pub(crate) async fn start_significant_location_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.location().start_location_updates(LocationOptions {
        accuracy: crate::LocationAccuracy::ThreeKilometers,
        ..Default::default()
    })
}

#[command]
pub(crate) async fn stop_significant_location_updates<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.location().stop_location_updates()
}

#[command]
pub(crate) async fn start_monitoring_region<R: Runtime>(
    app: AppHandle<R>,
    region: Region,
) -> Result<()> {
    app.location().start_monitoring_region(region)
}

#[command]
pub(crate) async fn stop_monitoring_region<R: Runtime>(
    app: AppHandle<R>,
    identifier: String,
) -> Result<()> {
    app.location().stop_monitoring_region(&identifier)
}

#[command]
pub(crate) async fn get_monitored_regions<R: Runtime>(
    _app: AppHandle<R>,
) -> Result<Vec<Region>> {
    // This would need to be implemented in the mobile module
    Ok(vec![])
}

#[command]
pub(crate) async fn start_heading_updates<R: Runtime>(
    _app: AppHandle<R>,
) -> Result<()> {
    // This would need to be implemented
    Ok(())
}

#[command]
pub(crate) async fn stop_heading_updates<R: Runtime>(
    _app: AppHandle<R>,
) -> Result<()> {
    // This would need to be implemented
    Ok(())
}

#[command]
pub(crate) async fn geocode_address<R: Runtime>(
    app: AppHandle<R>,
    address: String,
) -> Result<Vec<GeocodingResult>> {
    app.location().geocode_address(&address)
}

#[command]
pub(crate) async fn reverse_geocode<R: Runtime>(
    app: AppHandle<R>,
    coordinates: Coordinates,
) -> Result<Vec<Placemark>> {
    app.location().reverse_geocode(coordinates)
}

#[command]
pub(crate) async fn get_distance<R: Runtime>(
    app: AppHandle<R>,
    from: Coordinates,
    to: Coordinates,
) -> Result<f64> {
    app.location().get_distance(from, to)
}