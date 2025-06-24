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

/// Extensions to [`tauri::App`], [`tauri::AppHandle`], [`tauri::WebviewWindow`], [`tauri::Webview`] and [`tauri::Window`] to access the healthkit APIs.
pub trait HealthKitExt<R: Runtime> {
    fn healthkit(&self) -> &HealthKit<R>;
}

impl<R: Runtime, T: Manager<R>> crate::HealthKitExt<R> for T {
    fn healthkit(&self) -> &HealthKit<R> {
        self.state::<HealthKit<R>>().inner()
    }
}

/// Access to the healthkit APIs.
pub struct HealthKit<R: Runtime>(HealthKitImpl<R>);

#[cfg(desktop)]
type HealthKitImpl<R> = desktop::HealthKit<R>;
#[cfg(mobile)]
type HealthKitImpl<R> = mobile::HealthKit<R>;

impl<R: Runtime> HealthKit<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        self.0.check_permissions()
    }

    pub fn request_permissions(&self, permissions: PermissionRequest) -> Result<PermissionStatus> {
        self.0.request_permissions(permissions)
    }

    pub fn query_quantity_samples(&self, query: QuantityQuery) -> Result<Vec<QuantitySample>> {
        self.0.query_quantity_samples(query)
    }

    pub fn query_category_samples(&self, query: QuantityQuery) -> Result<Vec<CategorySample>> {
        self.0.query_category_samples(query)
    }

    pub fn query_workout_samples(&self, start_date: String, end_date: String, limit: Option<u32>) -> Result<Vec<WorkoutSample>> {
        self.0.query_workout_samples(start_date, end_date, limit)
    }

    pub fn write_quantity_sample(&self, sample: QuantitySample) -> Result<()> {
        self.0.write_quantity_sample(sample)
    }

    pub fn write_category_sample(&self, sample: CategorySample) -> Result<()> {
        self.0.write_category_sample(sample)
    }

    pub fn write_workout(&self, workout: WorkoutSample) -> Result<()> {
        self.0.write_workout(workout)
    }

    pub fn get_biological_sex(&self) -> Result<BiologicalSex> {
        self.0.get_biological_sex()
    }

    pub fn get_date_of_birth(&self) -> Result<String> {
        self.0.get_date_of_birth()
    }

    pub fn get_blood_type(&self) -> Result<BloodType> {
        self.0.get_blood_type()
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-healthkit")
        .invoke_handler(tauri::generate_handler![
            commands::check_permissions,
            commands::request_permissions,
            commands::query_quantity_samples,
            commands::query_category_samples,
            commands::query_workout_samples,
            commands::write_quantity_sample,
            commands::write_category_sample,
            commands::write_workout,
            commands::get_biological_sex,
            commands::get_date_of_birth,
            commands::get_blood_type,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let healthkit = mobile::init(app, api)?;
            #[cfg(desktop)]
            let healthkit = desktop::init(app, api)?;
            
            app.manage(HealthKit(healthkit));
            Ok(())
        })
        .build()
}