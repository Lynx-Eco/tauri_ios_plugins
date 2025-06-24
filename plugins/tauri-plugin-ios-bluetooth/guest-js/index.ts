import { invoke } from '@tauri-apps/api/core'

// Enums
export enum AuthorizationStatus {
  NotDetermined = 'notDetermined',
  Restricted = 'restricted',
  Denied = 'denied',
  Authorized = 'authorized'
}

export enum BluetoothState {
  Unknown = 'unknown',
  Resetting = 'resetting',
  Unsupported = 'unsupported',
  Unauthorized = 'unauthorized',
  PoweredOff = 'poweredOff',
  PoweredOn = 'poweredOn'
}

export enum ScanMode {
  LowPower = 'lowPower',
  Balanced = 'balanced',
  LowLatency = 'lowLatency'
}

export enum PeripheralState {
  Disconnected = 'disconnected',
  Connecting = 'connecting',
  Connected = 'connected',
  Disconnecting = 'disconnecting'
}

export enum WriteType {
  WithResponse = 'withResponse',
  WithoutResponse = 'withoutResponse'
}

export enum RequestResult {
  Success = 'success',
  InvalidHandle = 'invalidHandle',
  ReadNotPermitted = 'readNotPermitted',
  WriteNotPermitted = 'writeNotPermitted',
  InvalidPdu = 'invalidPdu',
  InsufficientAuthentication = 'insufficientAuthentication',
  RequestNotSupported = 'requestNotSupported',
  InvalidOffset = 'invalidOffset',
  InsufficientAuthorization = 'insufficientAuthorization',
  PrepareQueueFull = 'prepareQueueFull',
  AttributeNotFound = 'attributeNotFound',
  AttributeNotLong = 'attributeNotLong',
  InsufficientEncryptionKeySize = 'insufficientEncryptionKeySize',
  InvalidAttributeValueLength = 'invalidAttributeValueLength',
  UnlikelyError = 'unlikelyError'
}

export enum BluetoothEventType {
  StateChanged = 'stateChanged',
  PeripheralDiscovered = 'peripheralDiscovered',
  PeripheralConnected = 'peripheralConnected',
  PeripheralDisconnected = 'peripheralDisconnected',
  ServiceDiscovered = 'serviceDiscovered',
  CharacteristicDiscovered = 'characteristicDiscovered',
  CharacteristicValueUpdated = 'characteristicValueUpdated',
  CharacteristicSubscriptionChanged = 'characteristicSubscriptionChanged',
  DescriptorValueUpdated = 'descriptorValueUpdated',
  CentralSubscribed = 'centralSubscribed',
  CentralUnsubscribed = 'centralUnsubscribed',
  ReadRequestReceived = 'readRequestReceived',
  WriteRequestReceived = 'writeRequestReceived'
}

// Interfaces
export interface ScanOptions {
  serviceUuids?: string[]
  allowDuplicates?: boolean
  scanMode?: ScanMode
}

export interface Peripheral {
  uuid: string
  name?: string
  rssi: number
  isConnectable: boolean
  state: PeripheralState
  services: string[]
  manufacturerData?: Record<number, number[]>
  serviceData?: Record<string, number[]>
  txPowerLevel?: number
  solicitedServiceUuids: string[]
  overflowServiceUuids: string[]
}

export interface Service {
  uuid: string
  isPrimary: boolean
  characteristics: string[]
  includedServices: string[]
}

export interface CharacteristicProperties {
  broadcast: boolean
  read: boolean
  writeWithoutResponse: boolean
  write: boolean
  notify: boolean
  indicate: boolean
  authenticatedSignedWrites: boolean
  extendedProperties: boolean
  notifyEncryptionRequired: boolean
  indicateEncryptionRequired: boolean
}

export interface Characteristic {
  uuid: string
  serviceUuid: string
  properties: CharacteristicProperties
  value?: number[]
  descriptors: string[]
  isNotifying: boolean
}

export interface Descriptor {
  uuid: string
  characteristicUuid: string
  value?: number[]
}

export interface WriteOptions {
  withResponse?: boolean
}

export interface ConnectionOptions {
  autoConnect?: boolean
  timeoutMs?: number
}

export interface AdvertisingData {
  localName?: string
  serviceUuids?: string[]
  manufacturerData?: Record<number, number[]>
  serviceData?: Record<string, number[]>
  txPowerLevel?: number
  isConnectable?: boolean
}

export interface CharacteristicPermissions {
  readable: boolean
  writeable: boolean
  readEncryptionRequired: boolean
  writeEncryptionRequired: boolean
}

export interface PeripheralDescriptor {
  uuid: string
  value?: number[]
}

export interface PeripheralCharacteristic {
  uuid: string
  properties: CharacteristicProperties
  permissions: CharacteristicPermissions
  value?: number[]
  descriptors: PeripheralDescriptor[]
}

export interface PeripheralService {
  uuid: string
  isPrimary: boolean
  characteristics: PeripheralCharacteristic[]
}

export interface ReadRequest {
  centralUuid: string
  characteristicUuid: string
  offset: number
}

export interface WriteRequest {
  centralUuid: string
  characteristicUuid: string
  value: number[]
  offset: number
}

export interface RequestResponse {
  requestId: string
  result: RequestResult
  value?: number[]
}

export interface BluetoothEvent {
  eventType: BluetoothEventType
  timestamp: string
  data: any
}

// API Functions
export async function requestAuthorization(): Promise<AuthorizationStatus> {
  return await invoke('plugin:ios-bluetooth-v2|request_authorization')
}

export async function getAuthorizationStatus(): Promise<AuthorizationStatus> {
  return await invoke('plugin:ios-bluetooth-v2|get_authorization_status')
}

export async function isBluetoothEnabled(): Promise<boolean> {
  return await invoke('plugin:ios-bluetooth-v2|is_bluetooth_enabled')
}

export async function startCentralScan(options?: ScanOptions): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|start_central_scan', { options })
}

export async function stopCentralScan(): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|stop_central_scan')
}

export async function connectPeripheral(uuid: string, options?: ConnectionOptions): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|connect_peripheral', { uuid, options })
}

export async function disconnectPeripheral(uuid: string): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|disconnect_peripheral', { uuid })
}

export async function getConnectedPeripherals(): Promise<Peripheral[]> {
  return await invoke('plugin:ios-bluetooth-v2|get_connected_peripherals')
}

export async function getDiscoveredPeripherals(): Promise<Peripheral[]> {
  return await invoke('plugin:ios-bluetooth-v2|get_discovered_peripherals')
}

export async function discoverServices(peripheralUuid: string, serviceUuids?: string[]): Promise<Service[]> {
  return await invoke('plugin:ios-bluetooth-v2|discover_services', { peripheralUuid, serviceUuids })
}

export async function discoverCharacteristics(peripheralUuid: string, serviceUuid: string, characteristicUuids?: string[]): Promise<Characteristic[]> {
  return await invoke('plugin:ios-bluetooth-v2|discover_characteristics', { peripheralUuid, serviceUuid, characteristicUuids })
}

export async function readCharacteristic(peripheralUuid: string, characteristicUuid: string): Promise<number[]> {
  return await invoke('plugin:ios-bluetooth-v2|read_characteristic', { peripheralUuid, characteristicUuid })
}

export async function writeCharacteristic(peripheralUuid: string, characteristicUuid: string, value: number[], options?: WriteOptions): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|write_characteristic', { peripheralUuid, characteristicUuid, value, options })
}

export async function subscribeToCharacteristic(peripheralUuid: string, characteristicUuid: string): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|subscribe_to_characteristic', { peripheralUuid, characteristicUuid })
}

export async function unsubscribeFromCharacteristic(peripheralUuid: string, characteristicUuid: string): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|unsubscribe_from_characteristic', { peripheralUuid, characteristicUuid })
}

export async function readDescriptor(peripheralUuid: string, descriptorUuid: string): Promise<number[]> {
  return await invoke('plugin:ios-bluetooth-v2|read_descriptor', { peripheralUuid, descriptorUuid })
}

export async function writeDescriptor(peripheralUuid: string, descriptorUuid: string, value: number[]): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|write_descriptor', { peripheralUuid, descriptorUuid, value })
}

export async function getPeripheralRssi(peripheralUuid: string): Promise<number> {
  return await invoke('plugin:ios-bluetooth-v2|get_peripheral_rssi', { peripheralUuid })
}

export async function startPeripheralAdvertising(advertisingData: AdvertisingData): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|start_peripheral_advertising', { advertisingData })
}

export async function stopPeripheralAdvertising(): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|stop_peripheral_advertising')
}

export async function addService(service: PeripheralService): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|add_service', { service })
}

export async function removeService(serviceUuid: string): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|remove_service', { serviceUuid })
}

export async function removeAllServices(): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|remove_all_services')
}

export async function respondToRequest(response: RequestResponse): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|respond_to_request', { response })
}

export async function updateCharacteristicValue(characteristicUuid: string, value: number[], centralUuids?: string[]): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|update_characteristic_value', { characteristicUuid, value, centralUuids })
}

export async function getMaximumWriteLength(peripheralUuid: string, writeType: WriteType): Promise<number> {
  return await invoke('plugin:ios-bluetooth-v2|get_maximum_write_length', { peripheralUuid, writeType })
}

export async function setNotifyValue(characteristicUuid: string, enabled: boolean): Promise<void> {
  return await invoke('plugin:ios-bluetooth-v2|set_notify_value', { characteristicUuid, enabled })
}