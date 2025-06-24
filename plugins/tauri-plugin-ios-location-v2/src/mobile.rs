use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_location);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Location<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_location)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.location", "LocationPlugin")?;
    
    Ok(Location(handle))
}

/// Access to the location APIs on mobile.
pub struct Location<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Location<R> {
    pub fn check_permissions(&self) -> Result<LocationPermissions> {
        self.0
            .run_mobile_plugin("checkPermissions", ())
            .map_err(Into::into)
    }

    pub fn request_permissions(&self, request: PermissionRequest) -> Result<LocationPermissions> {
        self.0
            .run_mobile_plugin("requestPermissions", request)
            .map_err(Into::into)
    }

    pub fn get_current_location(&self, options: LocationOptions) -> Result<LocationData> {
        self.0
            .run_mobile_plugin("getCurrentLocation", options)
            .map_err(Into::into)
    }

    pub fn start_location_updates(&self, options: LocationOptions) -> Result<()> {
        self.0
            .run_mobile_plugin("startLocationUpdates", options)
            .map_err(Into::into)
    }

    pub fn stop_location_updates(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopLocationUpdates", ())
            .map_err(Into::into)
    }

    pub fn start_monitoring_region(&self, region: Region) -> Result<()> {
        self.0
            .run_mobile_plugin("startMonitoringRegion", region)
            .map_err(Into::into)
    }

    pub fn stop_monitoring_region(&self, identifier: &str) -> Result<()> {
        #[derive(serde::Serialize)]
        struct StopRegionArgs<'a> {
            identifier: &'a str,
        }
        
        self.0
            .run_mobile_plugin("stopMonitoringRegion", StopRegionArgs { identifier })
            .map_err(Into::into)
    }

    pub fn geocode_address(&self, address: &str) -> Result<Vec<GeocodingResult>> {
        #[derive(serde::Serialize)]
        struct GeocodeArgs<'a> {
            address: &'a str,
        }
        
        self.0
            .run_mobile_plugin("geocodeAddress", GeocodeArgs { address })
            .map_err(Into::into)
    }

    pub fn reverse_geocode(&self, location: Coordinates) -> Result<Vec<Placemark>> {
        self.0
            .run_mobile_plugin("reverseGeocode", location)
            .map_err(Into::into)
    }

    pub fn get_distance(&self, from: Coordinates, to: Coordinates) -> Result<f64> {
        let request = DistanceRequest { from, to };
        self.0
            .run_mobile_plugin("getDistance", request)
            .map_err(Into::into)
    }
}