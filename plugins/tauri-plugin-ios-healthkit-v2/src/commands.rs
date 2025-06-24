use tauri::{command, AppHandle, Runtime};

use crate::{
    BiologicalSex, BloodType, CategorySample, HealthKitExt, PermissionRequest, PermissionStatus,
    QuantityQuery, QuantitySample, Result, WorkoutSample,
};

#[command]
pub(crate) async fn check_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<PermissionStatus> {
    app.healthkit().check_permissions()
}

#[command]
pub(crate) async fn request_permissions<R: Runtime>(
    app: AppHandle<R>,
    permissions: PermissionRequest,
) -> Result<PermissionStatus> {
    app.healthkit().request_permissions(permissions)
}

#[command]
pub(crate) async fn query_quantity_samples<R: Runtime>(
    app: AppHandle<R>,
    query: QuantityQuery,
) -> Result<Vec<QuantitySample>> {
    app.healthkit().query_quantity_samples(query)
}

#[command]
pub(crate) async fn query_category_samples<R: Runtime>(
    app: AppHandle<R>,
    query: QuantityQuery,
) -> Result<Vec<CategorySample>> {
    app.healthkit().query_category_samples(query)
}

#[command]
pub(crate) async fn query_workout_samples<R: Runtime>(
    app: AppHandle<R>,
    start_date: String,
    end_date: String,
    limit: Option<u32>,
) -> Result<Vec<WorkoutSample>> {
    app.healthkit().query_workout_samples(start_date, end_date, limit)
}

#[command]
pub(crate) async fn write_quantity_sample<R: Runtime>(
    app: AppHandle<R>,
    sample: QuantitySample,
) -> Result<()> {
    app.healthkit().write_quantity_sample(sample)
}

#[command]
pub(crate) async fn write_category_sample<R: Runtime>(
    app: AppHandle<R>,
    sample: CategorySample,
) -> Result<()> {
    app.healthkit().write_category_sample(sample)
}

#[command]
pub(crate) async fn write_workout<R: Runtime>(
    app: AppHandle<R>,
    workout: WorkoutSample,
) -> Result<()> {
    app.healthkit().write_workout(workout)
}

#[command]
pub(crate) async fn get_biological_sex<R: Runtime>(
    app: AppHandle<R>,
) -> Result<BiologicalSex> {
    app.healthkit().get_biological_sex()
}

#[command]
pub(crate) async fn get_date_of_birth<R: Runtime>(
    app: AppHandle<R>,
) -> Result<String> {
    app.healthkit().get_date_of_birth()
}

#[command]
pub(crate) async fn get_blood_type<R: Runtime>(
    app: AppHandle<R>,
) -> Result<BloodType> {
    app.healthkit().get_blood_type()
}