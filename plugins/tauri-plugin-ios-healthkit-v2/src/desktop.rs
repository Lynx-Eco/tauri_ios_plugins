use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<HealthKit<R>> {
    Ok(HealthKit(app.clone()))
}

/// Access to the healthkit APIs on desktop (returns errors as not available).
pub struct HealthKit<R: Runtime>(AppHandle<R>);

impl<R: Runtime> HealthKit<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        Err(Error::NotAvailable)
    }

    pub fn request_permissions(&self, _permissions: PermissionRequest) -> Result<PermissionStatus> {
        Err(Error::NotAvailable)
    }

    pub fn query_quantity_samples(&self, _query: QuantityQuery) -> Result<Vec<QuantitySample>> {
        Err(Error::NotAvailable)
    }

    pub fn write_quantity_sample(&self, _sample: QuantitySample) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn query_category_samples(&self, _query: QuantityQuery) -> Result<Vec<CategorySample>> {
        Err(Error::NotAvailable)
    }

    pub fn query_workout_samples(&self, _start_date: String, _end_date: String, _limit: Option<u32>) -> Result<Vec<WorkoutSample>> {
        Err(Error::NotAvailable)
    }

    pub fn write_category_sample(&self, _sample: CategorySample) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn write_workout(&self, _workout: WorkoutSample) -> Result<()> {
        Err(Error::NotAvailable)
    }

    pub fn get_biological_sex(&self) -> Result<BiologicalSex> {
        Err(Error::NotAvailable)
    }

    pub fn get_date_of_birth(&self) -> Result<String> {
        Err(Error::NotAvailable)
    }

    pub fn get_blood_type(&self) -> Result<BloodType> {
        Err(Error::NotAvailable)
    }
}