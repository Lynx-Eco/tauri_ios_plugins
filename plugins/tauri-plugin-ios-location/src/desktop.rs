use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Location<R>> {
    Ok(Location(app.clone()))
}

/// Access to the location APIs on desktop (returns errors as not available).
pub struct Location<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Location<R> {
    pub fn check_permissions(&self) -> Result<LocationPermissions> {
        Err(Error::NotAvailable)
    }

    pub fn request_permissions(&self, _request: PermissionRequest) -> Result<LocationPermissions> {
        Err(Error::NotAvailable)
    }

    pub fn get_current_location(&self, _options: LocationOptions) -> Result<LocationData> {
        Err(Error::NotAvailable)
    }

    pub fn start_location_updates(&self, _options: LocationOptions) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn stop_location_updates(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn start_monitoring_region(&self, _region: Region) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn stop_monitoring_region(&self, _identifier: &str) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn geocode_address(&self, _address: &str) -> Result<Vec<GeocodingResult>> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn reverse_geocode(&self, _location: Coordinates) -> Result<Vec<Placemark>> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn get_distance(&self, from: Coordinates, to: Coordinates) -> Result<f64> {
        // Simple haversine distance calculation
        const EARTH_RADIUS: f64 = 6371000.0; // meters
        
        let lat1 = from.latitude.to_radians();
        let lat2 = to.latitude.to_radians();
        let delta_lat = (to.latitude - from.latitude).to_radians();
        let delta_lon = (to.longitude - from.longitude).to_radians();
        
        let a = (delta_lat / 2.0).sin().powi(2) +
                lat1.cos() * lat2.cos() *
                (delta_lon / 2.0).sin().powi(2);
        let c = 2.0 * a.sqrt().atan2((1.0 - a).sqrt());
        
        Ok(EARTH_RADIUS * c)
    }
}