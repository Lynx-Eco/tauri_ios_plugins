use tauri::{command, AppHandle, Runtime};

use crate::{BluetoothExt, ScanOptions, ConnectionOptions, WriteOptions, AdvertisingData, PeripheralService, RequestResponse, WriteType, Result};

#[command]
pub(crate) async fn request_authorization<R: Runtime>(
    app: AppHandle<R>,
) -> Result<crate::AuthorizationStatus> {
    app.bluetooth().request_authorization()
}

#[command]
pub(crate) async fn get_authorization_status<R: Runtime>(
    app: AppHandle<R>,
) -> Result<crate::AuthorizationStatus> {
    app.bluetooth().get_authorization_status()
}

#[command]
pub(crate) async fn is_bluetooth_enabled<R: Runtime>(
    app: AppHandle<R>,
) -> Result<bool> {
    app.bluetooth().is_bluetooth_enabled()
}

#[command]
pub(crate) async fn start_central_scan<R: Runtime>(
    app: AppHandle<R>,
    options: Option<ScanOptions>,
) -> Result<()> {
    app.bluetooth().start_central_scan(options.unwrap_or_default())
}

#[command]
pub(crate) async fn stop_central_scan<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.bluetooth().stop_central_scan()
}

#[command]
pub(crate) async fn connect_peripheral<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
    options: Option<ConnectionOptions>,
) -> Result<()> {
    app.bluetooth().connect_peripheral(uuid, options.unwrap_or_default())
}

#[command]
pub(crate) async fn disconnect_peripheral<R: Runtime>(
    app: AppHandle<R>,
    uuid: String,
) -> Result<()> {
    app.bluetooth().disconnect_peripheral(uuid)
}

#[command]
pub(crate) async fn get_connected_peripherals<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<crate::Peripheral>> {
    app.bluetooth().get_connected_peripherals()
}

#[command]
pub(crate) async fn get_discovered_peripherals<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<crate::Peripheral>> {
    app.bluetooth().get_discovered_peripherals()
}

#[command]
pub(crate) async fn discover_services<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    service_uuids: Option<Vec<String>>,
) -> Result<Vec<crate::Service>> {
    app.bluetooth().discover_services(peripheral_uuid, service_uuids)
}

#[command]
pub(crate) async fn discover_characteristics<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    service_uuid: String,
    characteristic_uuids: Option<Vec<String>>,
) -> Result<Vec<crate::Characteristic>> {
    app.bluetooth().discover_characteristics(peripheral_uuid, service_uuid, characteristic_uuids)
}

#[command]
pub(crate) async fn read_characteristic<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    characteristic_uuid: String,
) -> Result<Vec<u8>> {
    app.bluetooth().read_characteristic(peripheral_uuid, characteristic_uuid)
}

#[command]
pub(crate) async fn write_characteristic<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    characteristic_uuid: String,
    value: Vec<u8>,
    options: Option<WriteOptions>,
) -> Result<()> {
    app.bluetooth().write_characteristic(peripheral_uuid, characteristic_uuid, value, options.unwrap_or_default())
}

#[command]
pub(crate) async fn subscribe_to_characteristic<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    characteristic_uuid: String,
) -> Result<()> {
    app.bluetooth().subscribe_to_characteristic(peripheral_uuid, characteristic_uuid)
}

#[command]
pub(crate) async fn unsubscribe_from_characteristic<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    characteristic_uuid: String,
) -> Result<()> {
    app.bluetooth().unsubscribe_from_characteristic(peripheral_uuid, characteristic_uuid)
}

#[command]
pub(crate) async fn read_descriptor<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    descriptor_uuid: String,
) -> Result<Vec<u8>> {
    app.bluetooth().read_descriptor(peripheral_uuid, descriptor_uuid)
}

#[command]
pub(crate) async fn write_descriptor<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    descriptor_uuid: String,
    value: Vec<u8>,
) -> Result<()> {
    app.bluetooth().write_descriptor(peripheral_uuid, descriptor_uuid, value)
}

#[command]
pub(crate) async fn get_peripheral_rssi<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
) -> Result<i32> {
    app.bluetooth().get_peripheral_rssi(peripheral_uuid)
}

#[command]
pub(crate) async fn start_peripheral_advertising<R: Runtime>(
    app: AppHandle<R>,
    advertising_data: AdvertisingData,
) -> Result<()> {
    app.bluetooth().start_peripheral_advertising(advertising_data)
}

#[command]
pub(crate) async fn stop_peripheral_advertising<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.bluetooth().stop_peripheral_advertising()
}

#[command]
pub(crate) async fn add_service<R: Runtime>(
    app: AppHandle<R>,
    service: PeripheralService,
) -> Result<()> {
    app.bluetooth().add_service(service)
}

#[command]
pub(crate) async fn remove_service<R: Runtime>(
    app: AppHandle<R>,
    service_uuid: String,
) -> Result<()> {
    app.bluetooth().remove_service(service_uuid)
}

#[command]
pub(crate) async fn remove_all_services<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.bluetooth().remove_all_services()
}

#[command]
pub(crate) async fn respond_to_request<R: Runtime>(
    app: AppHandle<R>,
    response: RequestResponse,
) -> Result<()> {
    app.bluetooth().respond_to_request(response)
}

#[command]
pub(crate) async fn update_characteristic_value<R: Runtime>(
    app: AppHandle<R>,
    characteristic_uuid: String,
    value: Vec<u8>,
    central_uuids: Option<Vec<String>>,
) -> Result<()> {
    app.bluetooth().update_characteristic_value(characteristic_uuid, value, central_uuids)
}

#[command]
pub(crate) async fn get_maximum_write_length<R: Runtime>(
    app: AppHandle<R>,
    peripheral_uuid: String,
    write_type: WriteType,
) -> Result<usize> {
    app.bluetooth().get_maximum_write_length(peripheral_uuid, write_type)
}

#[command]
pub(crate) async fn set_notify_value<R: Runtime>(
    app: AppHandle<R>,
    characteristic_uuid: String,
    enabled: bool,
) -> Result<()> {
    app.bluetooth().set_notify_value(characteristic_uuid, enabled)
}