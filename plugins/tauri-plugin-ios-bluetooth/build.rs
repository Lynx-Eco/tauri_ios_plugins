const COMMANDS: &[&str] = &[
    "request_authorization",
    "get_authorization_status",
    "is_bluetooth_enabled",
    "start_central_scan",
    "stop_central_scan",
    "connect_peripheral",
    "disconnect_peripheral",
    "get_connected_peripherals",
    "get_discovered_peripherals",
    "discover_services",
    "discover_characteristics",
    "read_characteristic",
    "write_characteristic",
    "subscribe_to_characteristic",
    "unsubscribe_from_characteristic",
    "read_descriptor",
    "write_descriptor",
    "get_peripheral_rssi",
    "start_peripheral_advertising",
    "stop_peripheral_advertising",
    "add_service",
    "remove_service",
    "remove_all_services",
    "respond_to_request",
    "update_characteristic_value",
    "get_maximum_write_length",
    "set_notify_value",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}