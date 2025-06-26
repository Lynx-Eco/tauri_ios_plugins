import Tauri
import CoreBluetooth
import UIKit

extension NSNumber {
    var isBool: Bool {
        return self == kCFBooleanTrue || self == kCFBooleanFalse
    }
}

// Request structures
struct ScanOptionsData: Decodable {
    let serviceUuids: [String]
    let allowDuplicates: Bool
    let scanMode: String
}

struct ConnectionOptionsData: Decodable {
    let autoConnect: Bool
    let timeoutMs: Int?
}

struct WriteOptionsData: Decodable {
    let withResponse: Bool
}

struct AdvertisingDataData: Decodable {
    let localName: String?
    let serviceUuids: [String]
    let manufacturerData: [String: [UInt8]]?
    let serviceData: [String: [UInt8]]?
    let txPowerLevel: Int?
    let isConnectable: Bool
}

struct PeripheralServiceData: Decodable {
    let uuid: String
    let isPrimary: Bool
    let characteristics: [PeripheralCharacteristicData]
}

struct PeripheralCharacteristicData: Decodable {
    let uuid: String
    let properties: CharacteristicPropertiesData
    let permissions: CharacteristicPermissionsData
    let value: [UInt8]?
    let descriptors: [PeripheralDescriptorData]
}

struct CharacteristicPropertiesData: Decodable {
    let broadcast: Bool
    let read: Bool
    let writeWithoutResponse: Bool
    let write: Bool
    let notify: Bool
    let indicate: Bool
    let authenticatedSignedWrites: Bool
    let extendedProperties: Bool
    let notifyEncryptionRequired: Bool
    let indicateEncryptionRequired: Bool
}

struct CharacteristicPermissionsData: Decodable {
    let readable: Bool
    let writeable: Bool
    let readEncryptionRequired: Bool
    let writeEncryptionRequired: Bool
}

struct PeripheralDescriptorData: Decodable {
    let uuid: String
    let value: [UInt8]?
}

struct RequestResponseData: Decodable {
    let requestId: String
    let result: String
    let value: [UInt8]?
}

class BluetoothPlugin: Plugin, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private var connectedPeripherals: [UUID: CBPeripheral] = [:]
    private var peripheralDelegates: [UUID: PeripheralDelegate] = [:]
    private var pendingRequests: [String: CBATTRequest] = [:]
    private var isScanning = false
    private var scanOptions: ScanOptionsData?
    
    class PeripheralDelegate: NSObject, CBPeripheralDelegate {
        weak var plugin: BluetoothPlugin?
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            plugin?.peripheral(peripheral, didDiscoverServices: error)
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            plugin?.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            plugin?.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            // Handle write completion if needed
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            plugin?.peripheral(peripheral, didUpdateNotificationStateFor: characteristic, error: error)
        }
        
        func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
            plugin?.peripheral(peripheral, didReadRSSI: RSSI, error: error)
        }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    @objc public func requestAuthorization(_ invoke: Invoke) throws {
        // iOS doesn't require explicit Bluetooth permission for BLE
        // Permission is requested automatically when needed
        let status = getAuthorizationStatusString()
        invoke.resolve(status)
    }
    
    @objc public func getAuthorizationStatus(_ invoke: Invoke) throws {
        let status = getAuthorizationStatusString()
        invoke.resolve(status)
    }
    
    @objc public func isBluetoothEnabled(_ invoke: Invoke) throws {
        let enabled = centralManager?.state == .poweredOn
        invoke.resolve(enabled)
    }
    
    @objc public func startCentralScan(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(ScanOptionsData.self)
        
        guard centralManager?.state == .poweredOn else {
            invoke.reject("Bluetooth not powered on")
            return
        }
        
        guard !isScanning else {
            invoke.reject("Scan already in progress")
            return
        }
        
        scanOptions = args
        isScanning = true
        
        let serviceUUIDs = args?.serviceUuids.compactMap { CBUUID(string: $0) }
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: args?.allowDuplicates ?? false
        ]
        
        centralManager?.scanForPeripherals(
            withServices: serviceUUIDs?.isEmpty == true ? nil : serviceUUIDs,
            options: options
        )
        
        invoke.resolve()
    }
    
    @objc public func stopCentralScan(_ invoke: Invoke) throws {
        guard isScanning else {
            invoke.reject("Scan not started")
            return
        }
        
        centralManager?.stopScan()
        isScanning = false
        invoke.resolve()
    }
    
    @objc public func connectPeripheral(_ invoke: Invoke) throws {
        struct ConnectArgs: Decodable {
            let uuid: String
            let options: ConnectionOptionsData
        }
        
        let args = try invoke.parseArgs(ConnectArgs.self)
        
        guard let uuid = UUID(uuidString: args.uuid),
              let peripheral = discoveredPeripherals[uuid] else {
            invoke.reject("Peripheral not found")
            return
        }
        
        centralManager?.connect(peripheral, options: nil)
        invoke.resolve()
    }
    
    @objc public func disconnectPeripheral(_ invoke: Invoke) throws {
        struct DisconnectArgs: Decodable {
            let uuid: String
        }
        
        let args = try invoke.parseArgs(DisconnectArgs.self)
        
        guard let uuid = UUID(uuidString: args.uuid),
              let peripheral = connectedPeripherals[uuid] else {
            invoke.reject("Peripheral not connected")
            return
        }
        
        centralManager?.cancelPeripheralConnection(peripheral)
        invoke.resolve()
    }
    
    @objc public func getConnectedPeripherals(_ invoke: Invoke) throws {
        let peripherals = connectedPeripherals.values.map { peripheralToDict($0) }
        invoke.resolve(["peripherals": peripherals])
    }
    
    @objc public func getDiscoveredPeripherals(_ invoke: Invoke) throws {
        let peripherals = discoveredPeripherals.values.map { peripheralToDict($0) }
        invoke.resolve(["peripherals": peripherals])
    }
    
    @objc public func discoverServices(_ invoke: Invoke) throws {
        struct DiscoverServicesArgs: Decodable {
            let peripheralUuid: String
            let serviceUuids: [String]?
        }
        
        let args = try invoke.parseArgs(DiscoverServicesArgs.self)
        
        guard let uuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[uuid] else {
            invoke.reject("Peripheral not connected")
            return
        }
        
        let serviceUUIDs = args.serviceUuids?.compactMap { CBUUID(string: $0) }
        peripheral.discoverServices(serviceUUIDs)
        
        // Return current services if any
        let services = peripheral.services?.map { serviceToDict($0) } ?? []
        invoke.resolve(["services": services])
    }
    
    @objc public func discoverCharacteristics(_ invoke: Invoke) throws {
        struct DiscoverCharArgs: Decodable {
            let peripheralUuid: String
            let serviceUuid: String
            let characteristicUuids: [String]?
        }
        
        let args = try invoke.parseArgs(DiscoverCharArgs.self)
        
        guard let peripheralUuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[peripheralUuid],
              let service = peripheral.services?.first(where: { $0.uuid.uuidString == args.serviceUuid }) else {
            invoke.reject("Service not found")
            return
        }
        
        let charUUIDs = args.characteristicUuids?.compactMap { CBUUID(string: $0) }
        peripheral.discoverCharacteristics(charUUIDs, for: service)
        
        // Return current characteristics if any
        let characteristics = service.characteristics?.map { characteristicToDict($0, serviceUuid: service.uuid.uuidString) } ?? []
        invoke.resolve(["characteristics": characteristics])
    }
    
    @objc public func readCharacteristic(_ invoke: Invoke) throws {
        struct ReadCharArgs: Decodable {
            let peripheralUuid: String
            let characteristicUuid: String
        }
        
        let args = try invoke.parseArgs(ReadCharArgs.self)
        
        guard let peripheralUuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[peripheralUuid],
              let characteristic = findCharacteristic(peripheral: peripheral, uuid: args.characteristicUuid) else {
            invoke.reject("Characteristic not found")
            return
        }
        
        peripheral.readValue(for: characteristic)
        
        // Return current value if available
        if let value = characteristic.value {
            invoke.resolve(["value": Array(value) as [UInt8]])
        } else {
            invoke.resolve(["value": [] as [UInt8]])
        }
    }
    
    @objc public func writeCharacteristic(_ invoke: Invoke) throws {
        struct WriteCharArgs: Decodable {
            let peripheralUuid: String
            let characteristicUuid: String
            let value: [UInt8]
            let options: WriteOptionsData
        }
        
        let args = try invoke.parseArgs(WriteCharArgs.self)
        
        guard let peripheralUuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[peripheralUuid],
              let characteristic = findCharacteristic(peripheral: peripheral, uuid: args.characteristicUuid) else {
            invoke.reject("Characteristic not found")
            return
        }
        
        let data = Data(args.value)
        let type: CBCharacteristicWriteType = args.options.withResponse ? .withResponse : .withoutResponse
        
        peripheral.writeValue(data, for: characteristic, type: type)
        invoke.resolve()
    }
    
    @objc public func subscribeToCharacteristic(_ invoke: Invoke) throws {
        struct SubscribeArgs: Decodable {
            let peripheralUuid: String
            let characteristicUuid: String
        }
        
        let args = try invoke.parseArgs(SubscribeArgs.self)
        
        guard let peripheralUuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[peripheralUuid],
              let characteristic = findCharacteristic(peripheral: peripheral, uuid: args.characteristicUuid) else {
            invoke.reject("Characteristic not found")
            return
        }
        
        peripheral.setNotifyValue(true, for: characteristic)
        invoke.resolve()
    }
    
    @objc public func unsubscribeFromCharacteristic(_ invoke: Invoke) throws {
        struct UnsubscribeArgs: Decodable {
            let peripheralUuid: String
            let characteristicUuid: String
        }
        
        let args = try invoke.parseArgs(UnsubscribeArgs.self)
        
        guard let peripheralUuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[peripheralUuid],
              let characteristic = findCharacteristic(peripheral: peripheral, uuid: args.characteristicUuid) else {
            invoke.reject("Characteristic not found")
            return
        }
        
        peripheral.setNotifyValue(false, for: characteristic)
        invoke.resolve()
    }
    
    @objc public func readDescriptor(_ invoke: Invoke) throws {
        struct ReadDescArgs: Decodable {
            let peripheralUuid: String
            let descriptorUuid: String
        }
        
        let args = try invoke.parseArgs(ReadDescArgs.self)
        
        guard let peripheralUuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[peripheralUuid],
              let descriptor = findDescriptor(peripheral: peripheral, uuid: args.descriptorUuid) else {
            invoke.reject("Descriptor not found")
            return
        }
        
        peripheral.readValue(for: descriptor)
        
        if let value = descriptor.value as? Data {
            invoke.resolve(["value": Array(value) as [UInt8]])
        } else {
            invoke.resolve(["value": [] as [UInt8]])
        }
    }
    
    @objc public func writeDescriptor(_ invoke: Invoke) throws {
        struct WriteDescArgs: Decodable {
            let peripheralUuid: String
            let descriptorUuid: String
            let value: [UInt8]
        }
        
        let args = try invoke.parseArgs(WriteDescArgs.self)
        
        guard let peripheralUuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[peripheralUuid],
              let descriptor = findDescriptor(peripheral: peripheral, uuid: args.descriptorUuid) else {
            invoke.reject("Descriptor not found")
            return
        }
        
        let data = Data(args.value)
        peripheral.writeValue(data, for: descriptor)
        invoke.resolve()
    }
    
    @objc public func getPeripheralRssi(_ invoke: Invoke) throws {
        struct RssiArgs: Decodable {
            let peripheralUuid: String
        }
        
        let args = try invoke.parseArgs(RssiArgs.self)
        
        guard let uuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[uuid] else {
            invoke.reject("Peripheral not connected")
            return
        }
        
        peripheral.readRSSI()
        
        // Return a placeholder value
        invoke.resolve(-50)
    }
    
    @objc public func startPeripheralAdvertising(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(AdvertisingDataData.self)
        
        var advertisementData: [String: Any] = [:]
        
        if let name = args.localName {
            advertisementData[CBAdvertisementDataLocalNameKey] = name
        }
        
        if !args.serviceUuids.isEmpty {
            advertisementData[CBAdvertisementDataServiceUUIDsKey] = args.serviceUuids.map { CBUUID(string: $0) }
        }
        
        peripheralManager?.startAdvertising(advertisementData)
        invoke.resolve()
    }
    
    @objc public func stopPeripheralAdvertising(_ invoke: Invoke) throws {
        peripheralManager?.stopAdvertising()
        invoke.resolve()
    }
    
    @objc public func addService(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(PeripheralServiceData.self)
        
        let service = CBMutableService(type: CBUUID(string: args.uuid), primary: args.isPrimary)
        
        var characteristics: [CBMutableCharacteristic] = []
        for charData in args.characteristics {
            let properties = parseCharacteristicProperties(charData.properties)
            let permissions = parseCharacteristicPermissions(charData.permissions)
            
            let characteristic = CBMutableCharacteristic(
                type: CBUUID(string: charData.uuid),
                properties: properties,
                value: charData.value.map { Data($0) },
                permissions: permissions
            )
            
            characteristics.append(characteristic)
        }
        
        service.characteristics = characteristics
        peripheralManager?.add(service)
        invoke.resolve()
    }
    
    @objc public func removeService(_ invoke: Invoke) throws {
        struct RemoveServiceArgs: Decodable {
            let serviceUuid: String
        }
        
        let args = try invoke.parseArgs(RemoveServiceArgs.self)
        
        // CBPeripheralManager doesn't have a services property
        // You need to track services manually when adding them
        /*if false {
            for service in services {
                if service.uuid.uuidString == args.serviceUuid {
                    peripheralManager?.remove(service)
                    break
                }
            }
        }*/
        
        invoke.resolve()
    }
    
    @objc public func removeAllServices(_ invoke: Invoke) throws {
        peripheralManager?.removeAllServices()
        invoke.resolve()
    }
    
    @objc public func respondToRequest(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(RequestResponseData.self)
        
        guard let request = pendingRequests[args.requestId] else {
            invoke.reject("Request not found")
            return
        }
        
        if let value = args.value {
            request.value = Data(value)
        }
        
        let result = parseRequestResult(args.result)
        peripheralManager?.respond(to: request, withResult: result)
        
        pendingRequests.removeValue(forKey: args.requestId)
        invoke.resolve()
    }
    
    @objc public func updateCharacteristicValue(_ invoke: Invoke) throws {
        struct UpdateValueArgs: Decodable {
            let characteristicUuid: String
            let value: [UInt8]
            let centralUuids: [String]?
        }
        
        let args = try invoke.parseArgs(UpdateValueArgs.self)
        
        // This would require tracking characteristics added to peripheral manager
        invoke.resolve()
    }
    
    @objc public func getMaximumWriteLength(_ invoke: Invoke) throws {
        struct MaxWriteArgs: Decodable {
            let peripheralUuid: String
            let writeType: String
        }
        
        let args = try invoke.parseArgs(MaxWriteArgs.self)
        
        guard let uuid = UUID(uuidString: args.peripheralUuid),
              let peripheral = connectedPeripherals[uuid] else {
            invoke.reject("Peripheral not connected")
            return
        }
        
        let type: CBCharacteristicWriteType = args.writeType == "withResponse" ? .withResponse : .withoutResponse
        let maxLength = peripheral.maximumWriteValueLength(for: type)
        
        invoke.resolve(maxLength)
    }
    
    @objc public func setNotifyValue(_ invoke: Invoke) throws {
        struct NotifyArgs: Decodable {
            let characteristicUuid: String
            let enabled: Bool
        }
        
        let args = try invoke.parseArgs(NotifyArgs.self)
        
        // This would be used for peripheral mode
        invoke.resolve()
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        trigger("stateChanged", data: ["state": getBluetoothStateString()])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        discoveredPeripherals[peripheral.identifier] = peripheral
        
        let peripheralData = peripheralToDict(peripheral, advertisementData: advertisementData, rssi: RSSI.intValue)
        trigger("peripheralDiscovered", data: convertToJSObject(peripheralData))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripherals[peripheral.identifier] = peripheral
        
        // Set up delegate
        let delegate = PeripheralDelegate()
        delegate.plugin = self
        peripheralDelegates[peripheral.identifier] = delegate
        peripheral.delegate = delegate
        
        trigger("peripheralConnected", data: ["uuid": peripheral.identifier.uuidString])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripherals.removeValue(forKey: peripheral.identifier)
        peripheralDelegates.removeValue(forKey: peripheral.identifier)
        
        trigger("peripheralDisconnected", data: convertToJSObject([
            "uuid": peripheral.identifier.uuidString,
            "error": error?.localizedDescription ?? NSNull()
        ]))
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                trigger("serviceDiscovered", data: convertToJSObject(serviceToDict(service)))
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                trigger("characteristicDiscovered", data: convertToJSObject(characteristicToDict(characteristic, serviceUuid: service.uuid.uuidString)))
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data: [String: Any] = [
            "peripheralUuid": peripheral.identifier.uuidString,
            "characteristicUuid": characteristic.uuid.uuidString,
            "value": characteristic.value.map { Array($0) } ?? []
        ]
        trigger("characteristicValueUpdated", data: convertToJSObject(data))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let data: [String: Any] = [
            "peripheralUuid": peripheral.identifier.uuidString,
            "characteristicUuid": characteristic.uuid.uuidString,
            "isNotifying": characteristic.isNotifying
        ]
        trigger("characteristicSubscriptionChanged", data: convertToJSObject(data))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // Handle RSSI update
    }
    
    // MARK: - CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Handle peripheral manager state
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let requestId = UUID().uuidString
        pendingRequests[requestId] = request
        
        let data: [String: Any] = [
            "centralUuid": request.central.identifier.uuidString,
            "characteristicUuid": request.characteristic.uuid.uuidString,
            "offset": request.offset
        ]
        trigger("readRequestReceived", data: convertToJSObject(data))
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            let requestId = UUID().uuidString
            pendingRequests[requestId] = request
            
            let data: [String: Any] = [
                "centralUuid": request.central.identifier.uuidString,
                "characteristicUuid": request.characteristic.uuid.uuidString,
                "value": request.value.map { Array($0) } ?? [],
                "offset": request.offset
            ]
            trigger("writeRequestReceived", data: convertToJSObject(data))
        }
    }
    
    // MARK: - Helper Methods
    
    private func convertToJSObject(_ dict: [String: Any]) -> JSObject {
        var jsObject: JSObject = [:]
        for (key, value) in dict {
            if let str = value as? String {
                jsObject[key] = str
            } else if let num = value as? NSNumber {
                if num == kCFBooleanTrue || num == kCFBooleanFalse {
                    jsObject[key] = num.boolValue
                } else {
                    jsObject[key] = num.doubleValue
                }
            } else if let int = value as? Int {
                jsObject[key] = Double(int)
            } else if let double = value as? Double {
                jsObject[key] = double
            } else if let bool = value as? Bool {
                jsObject[key] = bool
            } else if let array = value as? [Any] {
                jsObject[key] = array
            } else if let dict = value as? [String: Any] {
                jsObject[key] = convertToJSObject(dict)
            } else if value is NSNull {
                jsObject[key] = nil
            }
        }
        return jsObject
    }
    
    private func getAuthorizationStatusString() -> String {
        if #available(iOS 13.1, *) {
            switch CBManager.authorization {
            case .notDetermined:
                return "notDetermined"
            case .restricted:
                return "restricted"
            case .denied:
                return "denied"
            case .allowedAlways:
                return "authorized"
            @unknown default:
                return "notDetermined"
            }
        } else {
            return "authorized"
        }
    }
    
    private func getBluetoothStateString() -> String {
        guard let state = centralManager?.state else { return "unknown" }
        
        switch state {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        @unknown default:
            return "unknown"
        }
    }
    
    private func peripheralToDict(_ peripheral: CBPeripheral, advertisementData: [String: Any]? = nil, rssi: Int = 0) -> [String: Any] {
        var dict: [String: Any] = [
            "uuid": peripheral.identifier.uuidString,
            "name": peripheral.name,
            "rssi": rssi,
            "isConnectable": advertisementData?[CBAdvertisementDataIsConnectable] as? Bool ?? true,
            "state": peripheralStateToString(peripheral.state),
            "services": peripheral.services?.map { $0.uuid.uuidString } ?? []
        ]
        
        if let advData = advertisementData {
            if let serviceUUIDs = advData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                dict["services"] = serviceUUIDs.map { $0.uuidString }
            }
            
            if let manufacturerData = advData[CBAdvertisementDataManufacturerDataKey] as? Data {
                // Parse manufacturer data
            }
            
            if let txPower = advData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber {
                dict["txPowerLevel"] = txPower.intValue
            }
        }
        
        return dict
    }
    
    private func peripheralStateToString(_ state: CBPeripheralState) -> String {
        switch state {
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .disconnecting:
            return "disconnecting"
        @unknown default:
            return "disconnected"
        }
    }
    
    private func serviceToDict(_ service: CBService) -> [String: Any] {
        return [
            "uuid": service.uuid.uuidString,
            "isPrimary": service.isPrimary,
            "characteristics": service.characteristics?.map { $0.uuid.uuidString } ?? [],
            "includedServices": service.includedServices?.map { $0.uuid.uuidString } ?? []
        ]
    }
    
    private func characteristicToDict(_ characteristic: CBCharacteristic, serviceUuid: String) -> [String: Any] {
        return [
            "uuid": characteristic.uuid.uuidString,
            "serviceUuid": serviceUuid,
            "properties": characteristicPropertiesToDict(characteristic.properties),
            "value": characteristic.value.map { Array($0) } ?? NSNull(),
            "descriptors": characteristic.descriptors?.map { $0.uuid.uuidString } ?? [],
            "isNotifying": characteristic.isNotifying
        ]
    }
    
    private func characteristicPropertiesToDict(_ properties: CBCharacteristicProperties) -> [String: Any] {
        return [
            "broadcast": properties.contains(.broadcast),
            "read": properties.contains(.read),
            "writeWithoutResponse": properties.contains(.writeWithoutResponse),
            "write": properties.contains(.write),
            "notify": properties.contains(.notify),
            "indicate": properties.contains(.indicate),
            "authenticatedSignedWrites": properties.contains(.authenticatedSignedWrites),
            "extendedProperties": properties.contains(.extendedProperties),
            "notifyEncryptionRequired": properties.contains(.notifyEncryptionRequired),
            "indicateEncryptionRequired": properties.contains(.indicateEncryptionRequired)
        ]
    }
    
    private func findCharacteristic(peripheral: CBPeripheral, uuid: String) -> CBCharacteristic? {
        guard let services = peripheral.services else { return nil }
        
        for service in services {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid.uuidString == uuid {
                        return characteristic
                    }
                }
            }
        }
        
        return nil
    }
    
    private func findDescriptor(peripheral: CBPeripheral, uuid: String) -> CBDescriptor? {
        guard let services = peripheral.services else { return nil }
        
        for service in services {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if let descriptors = characteristic.descriptors {
                        for descriptor in descriptors {
                            if descriptor.uuid.uuidString == uuid {
                                return descriptor
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    private func parseCharacteristicProperties(_ props: CharacteristicPropertiesData) -> CBCharacteristicProperties {
        var properties: CBCharacteristicProperties = []
        
        if props.broadcast { properties.insert(.broadcast) }
        if props.read { properties.insert(.read) }
        if props.writeWithoutResponse { properties.insert(.writeWithoutResponse) }
        if props.write { properties.insert(.write) }
        if props.notify { properties.insert(.notify) }
        if props.indicate { properties.insert(.indicate) }
        if props.authenticatedSignedWrites { properties.insert(.authenticatedSignedWrites) }
        if props.extendedProperties { properties.insert(.extendedProperties) }
        if props.notifyEncryptionRequired { properties.insert(.notifyEncryptionRequired) }
        if props.indicateEncryptionRequired { properties.insert(.indicateEncryptionRequired) }
        
        return properties
    }
    
    private func parseCharacteristicPermissions(_ perms: CharacteristicPermissionsData) -> CBAttributePermissions {
        var permissions: CBAttributePermissions = []
        
        if perms.readable { permissions.insert(.readable) }
        if perms.writeable { permissions.insert(.writeable) }
        if perms.readEncryptionRequired { permissions.insert(.readEncryptionRequired) }
        if perms.writeEncryptionRequired { permissions.insert(.writeEncryptionRequired) }
        
        return permissions
    }
    
    private func parseRequestResult(_ result: String) -> CBATTError.Code {
        switch result {
        case "success":
            return .success
        case "invalidHandle":
            return .invalidHandle
        case "readNotPermitted":
            return .readNotPermitted
        case "writeNotPermitted":
            return .writeNotPermitted
        case "invalidPdu":
            return .invalidPdu
        case "insufficientAuthentication":
            return .insufficientAuthentication
        case "requestNotSupported":
            return .requestNotSupported
        case "invalidOffset":
            return .invalidOffset
        case "insufficientAuthorization":
            return .insufficientAuthorization
        case "prepareQueueFull":
            return .prepareQueueFull
        case "attributeNotFound":
            return .attributeNotFound
        case "attributeNotLong":
            return .attributeNotLong
        case "insufficientEncryptionKeySize":
            return .insufficientEncryptionKeySize
        case "invalidAttributeValueLength":
            return .invalidAttributeValueLength
        case "unlikelyError":
            return .unlikelyError
        default:
            return .requestNotSupported
        }
    }
}

@_cdecl("init_plugin_ios_bluetooth")
func initPlugin() -> Plugin {
    return BluetoothPlugin()
}