use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_bluetooth);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Bluetooth<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_bluetooth)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.bluetooth", "BluetoothPlugin")?;
    
    Ok(Bluetooth(handle))
}

/// Access to the Bluetooth APIs on mobile.
pub struct Bluetooth<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Bluetooth<R> {
    pub fn request_authorization(&self) -> Result<AuthorizationStatus> {
        self.0
            .run_mobile_plugin("requestAuthorization", ())
            .map_err(Into::into)
    }
    
    pub fn get_authorization_status(&self) -> Result<AuthorizationStatus> {
        self.0
            .run_mobile_plugin("getAuthorizationStatus", ())
            .map_err(Into::into)
    }
    
    pub fn is_bluetooth_enabled(&self) -> Result<bool> {
        self.0
            .run_mobile_plugin("isBluetoothEnabled", ())
            .map_err(Into::into)
    }
    
    pub fn start_central_scan(&self, options: ScanOptions) -> Result<()> {
        self.0
            .run_mobile_plugin("startCentralScan", options)
            .map_err(Into::into)
    }
    
    pub fn stop_central_scan(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopCentralScan", ())
            .map_err(Into::into)
    }
    
    pub fn connect_peripheral(&self, uuid: String, options: ConnectionOptions) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
            options: ConnectionOptions,
        }
        
        self.0
            .run_mobile_plugin("connectPeripheral", Args { uuid, options })
            .map_err(Into::into)
    }
    
    pub fn disconnect_peripheral(&self, uuid: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            uuid: String,
        }
        
        self.0
            .run_mobile_plugin("disconnectPeripheral", Args { uuid })
            .map_err(Into::into)
    }
    
    pub fn get_connected_peripherals(&self) -> Result<Vec<Peripheral>> {
        self.0
            .run_mobile_plugin("getConnectedPeripherals", ())
            .map_err(Into::into)
    }
    
    pub fn get_discovered_peripherals(&self) -> Result<Vec<Peripheral>> {
        self.0
            .run_mobile_plugin("getDiscoveredPeripherals", ())
            .map_err(Into::into)
    }
    
    pub fn discover_services(&self, peripheral_uuid: String, service_uuids: Option<Vec<String>>) -> Result<Vec<Service>> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            service_uuids: Option<Vec<String>>,
        }
        
        self.0
            .run_mobile_plugin("discoverServices", Args { peripheral_uuid, service_uuids })
            .map_err(Into::into)
    }
    
    pub fn discover_characteristics(&self, peripheral_uuid: String, service_uuid: String, characteristic_uuids: Option<Vec<String>>) -> Result<Vec<Characteristic>> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            service_uuid: String,
            characteristic_uuids: Option<Vec<String>>,
        }
        
        self.0
            .run_mobile_plugin("discoverCharacteristics", Args { peripheral_uuid, service_uuid, characteristic_uuids })
            .map_err(Into::into)
    }
    
    pub fn read_characteristic(&self, peripheral_uuid: String, characteristic_uuid: String) -> Result<Vec<u8>> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            characteristic_uuid: String,
        }
        
        self.0
            .run_mobile_plugin("readCharacteristic", Args { peripheral_uuid, characteristic_uuid })
            .map_err(Into::into)
    }
    
    pub fn write_characteristic(&self, peripheral_uuid: String, characteristic_uuid: String, value: Vec<u8>, options: WriteOptions) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            characteristic_uuid: String,
            value: Vec<u8>,
            options: WriteOptions,
        }
        
        self.0
            .run_mobile_plugin("writeCharacteristic", Args { peripheral_uuid, characteristic_uuid, value, options })
            .map_err(Into::into)
    }
    
    pub fn subscribe_to_characteristic(&self, peripheral_uuid: String, characteristic_uuid: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            characteristic_uuid: String,
        }
        
        self.0
            .run_mobile_plugin("subscribeToCharacteristic", Args { peripheral_uuid, characteristic_uuid })
            .map_err(Into::into)
    }
    
    pub fn unsubscribe_from_characteristic(&self, peripheral_uuid: String, characteristic_uuid: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            characteristic_uuid: String,
        }
        
        self.0
            .run_mobile_plugin("unsubscribeFromCharacteristic", Args { peripheral_uuid, characteristic_uuid })
            .map_err(Into::into)
    }
    
    pub fn read_descriptor(&self, peripheral_uuid: String, descriptor_uuid: String) -> Result<Vec<u8>> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            descriptor_uuid: String,
        }
        
        self.0
            .run_mobile_plugin("readDescriptor", Args { peripheral_uuid, descriptor_uuid })
            .map_err(Into::into)
    }
    
    pub fn write_descriptor(&self, peripheral_uuid: String, descriptor_uuid: String, value: Vec<u8>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            descriptor_uuid: String,
            value: Vec<u8>,
        }
        
        self.0
            .run_mobile_plugin("writeDescriptor", Args { peripheral_uuid, descriptor_uuid, value })
            .map_err(Into::into)
    }
    
    pub fn get_peripheral_rssi(&self, peripheral_uuid: String) -> Result<i32> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
        }
        
        self.0
            .run_mobile_plugin("getPeripheralRssi", Args { peripheral_uuid })
            .map_err(Into::into)
    }
    
    pub fn start_peripheral_advertising(&self, advertising_data: AdvertisingData) -> Result<()> {
        self.0
            .run_mobile_plugin("startPeripheralAdvertising", advertising_data)
            .map_err(Into::into)
    }
    
    pub fn stop_peripheral_advertising(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("stopPeripheralAdvertising", ())
            .map_err(Into::into)
    }
    
    pub fn add_service(&self, service: PeripheralService) -> Result<()> {
        self.0
            .run_mobile_plugin("addService", service)
            .map_err(Into::into)
    }
    
    pub fn remove_service(&self, service_uuid: String) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            service_uuid: String,
        }
        
        self.0
            .run_mobile_plugin("removeService", Args { service_uuid })
            .map_err(Into::into)
    }
    
    pub fn remove_all_services(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("removeAllServices", ())
            .map_err(Into::into)
    }
    
    pub fn respond_to_request(&self, response: RequestResponse) -> Result<()> {
        self.0
            .run_mobile_plugin("respondToRequest", response)
            .map_err(Into::into)
    }
    
    pub fn update_characteristic_value(&self, characteristic_uuid: String, value: Vec<u8>, central_uuids: Option<Vec<String>>) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            characteristic_uuid: String,
            value: Vec<u8>,
            central_uuids: Option<Vec<String>>,
        }
        
        self.0
            .run_mobile_plugin("updateCharacteristicValue", Args { characteristic_uuid, value, central_uuids })
            .map_err(Into::into)
    }
    
    pub fn get_maximum_write_length(&self, peripheral_uuid: String, write_type: WriteType) -> Result<usize> {
        #[derive(serde::Serialize)]
        struct Args {
            peripheral_uuid: String,
            write_type: WriteType,
        }
        
        self.0
            .run_mobile_plugin("getMaximumWriteLength", Args { peripheral_uuid, write_type })
            .map_err(Into::into)
    }
    
    pub fn set_notify_value(&self, characteristic_uuid: String, enabled: bool) -> Result<()> {
        #[derive(serde::Serialize)]
        struct Args {
            characteristic_uuid: String,
            enabled: bool,
        }
        
        self.0
            .run_mobile_plugin("setNotifyValue", Args { characteristic_uuid, enabled })
            .map_err(Into::into)
    }
}