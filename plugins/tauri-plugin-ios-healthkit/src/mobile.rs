use serde::de::DeserializeOwned;
use serde_json;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_healthkit);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<HealthKit<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_healthkit)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.healthkit", "HealthKitPlugin")?;
    
    Ok(HealthKit(handle))
}

/// Access to the healthkit APIs on mobile.
pub struct HealthKit<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> HealthKit<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        self.0
            .run_mobile_plugin("checkPermissions", ())
            .map_err(Into::into)
    }

    pub fn request_permissions(&self, permissions: PermissionRequest) -> Result<PermissionStatus> {
        self.0
            .run_mobile_plugin("requestPermissions", permissions)
            .map_err(Into::into)
    }

    pub fn query_quantity_samples(&self, query: QuantityQuery) -> Result<Vec<QuantitySample>> {
        self.0
            .run_mobile_plugin("queryQuantitySamples", query)
            .map_err(Into::into)
    }

    pub fn query_category_samples(&self, query: QuantityQuery) -> Result<Vec<CategorySample>> {
        self.0
            .run_mobile_plugin("queryCategorySamples", query)
            .map_err(Into::into)
    }

    pub fn query_workout_samples(&self, start_date: String, end_date: String, limit: Option<u32>) -> Result<Vec<WorkoutSample>> {
        self.0
            .run_mobile_plugin("queryWorkoutSamples", serde_json::json!({
                "startDate": start_date,
                "endDate": end_date,
                "limit": limit
            }))
            .map_err(Into::into)
    }

    pub fn write_quantity_sample(&self, sample: QuantitySample) -> Result<()> {
        self.0
            .run_mobile_plugin("writeQuantitySample", sample)
            .map_err(Into::into)
    }

    pub fn write_category_sample(&self, sample: CategorySample) -> Result<()> {
        self.0
            .run_mobile_plugin("writeCategorySample", sample)
            .map_err(Into::into)
    }

    pub fn write_workout(&self, workout: WorkoutSample) -> Result<()> {
        self.0
            .run_mobile_plugin("writeWorkout", workout)
            .map_err(Into::into)
    }

    pub fn get_biological_sex(&self) -> Result<BiologicalSex> {
        self.0
            .run_mobile_plugin("getBiologicalSex", ())
            .map_err(Into::into)
    }

    pub fn get_date_of_birth(&self) -> Result<String> {
        self.0
            .run_mobile_plugin("getDateOfBirth", ())
            .map_err(Into::into)
    }

    pub fn get_blood_type(&self) -> Result<BloodType> {
        self.0
            .run_mobile_plugin("getBloodType", ())
            .map_err(Into::into)
    }
}