import { invoke } from '@tauri-apps/api/core'

// Enums
export enum Accessible {
  WhenUnlocked = 'whenUnlocked',
  AfterFirstUnlock = 'afterFirstUnlock',
  WhenUnlockedThisDeviceOnly = 'whenUnlockedThisDeviceOnly',
  AfterFirstUnlockThisDeviceOnly = 'afterFirstUnlockThisDeviceOnly',
  WhenPasscodeSetThisDeviceOnly = 'whenPasscodeSetThisDeviceOnly'
}

export enum InternetProtocol {
  Http = 'http',
  Https = 'https',
  Ftp = 'ftp',
  Ftps = 'ftps',
  Smtp = 'smtp',
  Pop3 = 'pop3',
  Imap = 'imap',
  Ldap = 'ldap',
  Ssh = 'ssh',
  Telnet = 'telnet'
}

export enum AuthenticationType {
  Default = 'default',
  HttpBasic = 'httpBasic',
  HttpDigest = 'httpDigest',
  HtmlForm = 'htmlForm',
  Ntlm = 'ntlm',
  Negotiate = 'negotiate'
}

export enum BiometryType {
  None = 'none',
  TouchId = 'touchId',
  FaceId = 'faceId'
}

// Types
export type SecureValue = 
  | { password: string }
  | { data: string }
  | { certificate: string }
  | { key: string }

// Interfaces
export interface KeychainItem {
  key: string
  value: string
  service?: string
  account?: string
  accessGroup?: string
  accessible: Accessible
  synchronizable: boolean
  label?: string
  comment?: string
}

export interface KeychainQuery {
  key: string
  service?: string
  account?: string
  accessGroup?: string
}

export interface KeychainUpdate {
  value?: string
  accessible?: Accessible
  synchronizable?: boolean
  label?: string
  comment?: string
}

export interface AuthenticationPolicy {
  biometryAny: boolean
  biometryCurrentSet: boolean
  devicePasscode: boolean
  userPresence: boolean
  applicationPassword?: string
}

export interface SecureKeychainItem {
  key: string
  value: SecureValue
  service?: string
  accessGroup?: string
  authentication: AuthenticationPolicy
  accessible: Accessible
  validityDuration?: number
}

export interface SecureKeychainQuery {
  key: string
  service?: string
  accessGroup?: string
  authenticationPrompt?: string
}

export interface InternetPasswordItem {
  server: string
  account: string
  password: string
  port?: number
  protocol?: InternetProtocol
  authenticationType?: AuthenticationType
  securityDomain?: string
  accessible: Accessible
  synchronizable: boolean
}

export interface InternetPasswordQuery {
  server: string
  account?: string
  port?: number
  protocol?: InternetProtocol
}

export interface PasswordOptions {
  length?: number
  includeUppercase?: boolean
  includeLowercase?: boolean
  includeNumbers?: boolean
  includeSymbols?: boolean
  excludeAmbiguous?: boolean
  customCharacters?: string
}

export interface AuthenticationResult {
  success: boolean
  biometryType?: BiometryType
  error?: string
}

export interface KeychainStatus {
  isAvailable: boolean
  isLocked: boolean
  biometryAvailable: boolean
  biometryType: BiometryType
  accessGroups: string[]
}

// API Functions
export async function setItem(item: KeychainItem): Promise<void> {
  return await invoke('plugin:ios-keychain-v2|set_item', { item })
}

export async function getItem(query: KeychainQuery): Promise<KeychainItem> {
  return await invoke('plugin:ios-keychain-v2|get_item', { query })
}

export async function deleteItem(query: KeychainQuery): Promise<void> {
  return await invoke('plugin:ios-keychain-v2|delete_item', { query })
}

export async function hasItem(query: KeychainQuery): Promise<boolean> {
  return await invoke('plugin:ios-keychain-v2|has_item', { query })
}

export async function updateItem(query: KeychainQuery, updates: KeychainUpdate): Promise<void> {
  return await invoke('plugin:ios-keychain-v2|update_item', { query, updates })
}

export async function getAllKeys(service?: string): Promise<string[]> {
  return await invoke('plugin:ios-keychain-v2|get_all_keys', { service })
}

export async function deleteAll(service?: string): Promise<void> {
  return await invoke('plugin:ios-keychain-v2|delete_all', { service })
}

export async function setAccessGroup(group: string): Promise<void> {
  return await invoke('plugin:ios-keychain-v2|set_access_group', { group })
}

export async function getAccessGroup(): Promise<string | null> {
  return await invoke('plugin:ios-keychain-v2|get_access_group')
}

export async function setSecureItem(item: SecureKeychainItem): Promise<void> {
  return await invoke('plugin:ios-keychain-v2|set_secure_item', { item })
}

export async function getSecureItem(query: SecureKeychainQuery): Promise<SecureKeychainItem> {
  return await invoke('plugin:ios-keychain-v2|get_secure_item', { query })
}

export async function generatePassword(options?: PasswordOptions): Promise<string> {
  return await invoke('plugin:ios-keychain-v2|generate_password', { options })
}

export async function checkAuthentication(reason: string): Promise<AuthenticationResult> {
  return await invoke('plugin:ios-keychain-v2|check_authentication', { reason })
}

export async function setInternetPassword(item: InternetPasswordItem): Promise<void> {
  return await invoke('plugin:ios-keychain-v2|set_internet_password', { item })
}

export async function getInternetPassword(query: InternetPasswordQuery): Promise<InternetPasswordItem> {
  return await invoke('plugin:ios-keychain-v2|get_internet_password', { query })
}
