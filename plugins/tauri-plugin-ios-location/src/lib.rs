use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`], [`tauri::WebviewWindow`], [`tauri::Webview`] and [`tauri::Window`] to access the location APIs.
pub trait LocationExt<R: Runtime> {
    fn location(&self) -> &Location<R>;
}

impl<R: Runtime, T: Manager<R>> crate::LocationExt<R> for T {
    fn location(&self) -> &Location<R> {
        self.state::<Location<R>>().inner()
    }
}

/// Access to the location APIs.
pub struct Location<R: Runtime>(LocationImpl<R>);

#[cfg(desktop)]
type LocationImpl<R> = desktop::Location<R>;
#[cfg(mobile)]
type LocationImpl<R> = mobile::Location<R>;

impl<R: Runtime> Location<R> {
    pub fn check_permissions(&self) -> Result<LocationPermissions> {
        self.0.check_permissions()
    }

    pub fn request_permissions(&self, request: PermissionRequest) -> Result<LocationPermissions> {
        self.0.request_permissions(request)
    }

    pub fn get_current_location(&self, options: LocationOptions) -> Result<LocationData> {
        self.0.get_current_location(options)
    }

    pub fn start_location_updates(&self, options: LocationOptions) -> Result<()> {
        self.0.start_location_updates(options)
    }

    pub fn stop_location_updates(&self) -> Result<()> {
        self.0.stop_location_updates()
    }

    pub fn start_monitoring_region(&self, region: Region) -> Result<()> {
        self.0.start_monitoring_region(region)
    }

    pub fn stop_monitoring_region(&self, identifier: &str) -> Result<()> {
        self.0.stop_monitoring_region(identifier)
    }

    pub fn geocode_address(&self, address: &str) -> Result<Vec<GeocodingResult>> {
        self.0.geocode_address(address)
    }

    pub fn reverse_geocode(&self, location: Coordinates) -> Result<Vec<Placemark>> {
        self.0.reverse_geocode(location)
    }

    pub fn get_distance(&self, from: Coordinates, to: Coordinates) -> Result<f64> {
        self.0.get_distance(from, to)
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-location")
        .invoke_handler(tauri::generate_handler![
            commands::check_permissions,
            commands::request_permissions,
            commands::get_current_location,
            commands::start_location_updates,
            commands::stop_location_updates,
            commands::start_significant_location_updates,
            commands::stop_significant_location_updates,
            commands::start_monitoring_region,
            commands::stop_monitoring_region,
            commands::get_monitored_regions,
            commands::start_heading_updates,
            commands::stop_heading_updates,
            commands::geocode_address,
            commands::reverse_geocode,
            commands::get_distance,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let location = mobile::init(app, api)?;
            #[cfg(desktop)]
            let location = desktop::init(app, api)?;
            
            app.manage(Location(location));
            Ok(())
        })
        .build()
}