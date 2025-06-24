use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Bluetooth<R>> {
    Ok(Bluetooth(app.clone()))
}

/// Access to the Bluetooth APIs on desktop (returns errors as not available).
pub struct Bluetooth<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Bluetooth<R> {
    pub fn request_authorization(&self) -> Result<AuthorizationStatus> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_authorization_status(&self) -> Result<AuthorizationStatus> {
        Err(Error::NotAvailable)
    }
    
    pub fn is_bluetooth_enabled(&self) -> Result<bool> {
        Ok(false)
    }
    
    pub fn start_central_scan(&self, _options: ScanOptions) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_central_scan(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn connect_peripheral(&self, _uuid: String, _options: ConnectionOptions) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn disconnect_peripheral(&self, _uuid: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_connected_peripherals(&self) -> Result<Vec<Peripheral>> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_discovered_peripherals(&self) -> Result<Vec<Peripheral>> {
        Err(Error::NotAvailable)
    }
    
    pub fn discover_services(&self, _peripheral_uuid: String, _service_uuids: Option<Vec<String>>) -> Result<Vec<Service>> {
        Err(Error::NotAvailable)
    }
    
    pub fn discover_characteristics(&self, _peripheral_uuid: String, _service_uuid: String, _characteristic_uuids: Option<Vec<String>>) -> Result<Vec<Characteristic>> {
        Err(Error::NotAvailable)
    }
    
    pub fn read_characteristic(&self, _peripheral_uuid: String, _characteristic_uuid: String) -> Result<Vec<u8>> {
        Err(Error::NotAvailable)
    }
    
    pub fn write_characteristic(&self, _peripheral_uuid: String, _characteristic_uuid: String, _value: Vec<u8>, _options: WriteOptions) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn subscribe_to_characteristic(&self, _peripheral_uuid: String, _characteristic_uuid: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn unsubscribe_from_characteristic(&self, _peripheral_uuid: String, _characteristic_uuid: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn read_descriptor(&self, _peripheral_uuid: String, _descriptor_uuid: String) -> Result<Vec<u8>> {
        Err(Error::NotAvailable)
    }
    
    pub fn write_descriptor(&self, _peripheral_uuid: String, _descriptor_uuid: String, _value: Vec<u8>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_peripheral_rssi(&self, _peripheral_uuid: String) -> Result<i32> {
        Err(Error::NotAvailable)
    }
    
    pub fn start_peripheral_advertising(&self, _advertising_data: AdvertisingData) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn stop_peripheral_advertising(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn add_service(&self, _service: PeripheralService) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn remove_service(&self, _service_uuid: String) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn remove_all_services(&self) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn respond_to_request(&self, _response: RequestResponse) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn update_characteristic_value(&self, _characteristic_uuid: String, _value: Vec<u8>, _central_uuids: Option<Vec<String>>) -> Result<()> {
        Err(Error::NotAvailable)
    }
    
    pub fn get_maximum_write_length(&self, _peripheral_uuid: String, _write_type: WriteType) -> Result<usize> {
        Err(Error::NotAvailable)
    }
    
    pub fn set_notify_value(&self, _characteristic_uuid: String, _enabled: bool) -> Result<()> {
        Err(Error::NotAvailable)
    }
}