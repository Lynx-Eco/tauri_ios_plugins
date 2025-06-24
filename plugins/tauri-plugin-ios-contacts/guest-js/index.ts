import { invoke } from '@tauri-apps/api/core';

export interface PermissionStatus {
  contacts: 'granted' | 'denied' | 'prompt';
}

export interface PhoneNumber {
  label: string;
  value: string;
}

export interface EmailAddress {
  label: string;
  value: string;
}

export interface PostalAddress {
  label: string;
  street?: string;
  city?: string;
  state?: string;
  postalCode?: string;
  country?: string;
}

export interface UrlAddress {
  label: string;
  value: string;
}

export interface SocialProfile {
  label: string;
  service: string;
  username: string;
  url?: string;
}

export interface InstantMessage {
  label: string;
  service: string;
  username: string;
}

export interface Contact {
  id: string;
  givenName?: string;
  familyName?: string;
  middleName?: string;
  nickname?: string;
  prefix?: string;
  suffix?: string;
  organization?: string;
  jobTitle?: string;
  department?: string;
  note?: string;
  birthday?: string;
  phoneNumbers: PhoneNumber[];
  emailAddresses: EmailAddress[];
  postalAddresses: PostalAddress[];
  urlAddresses: UrlAddress[];
  socialProfiles: SocialProfile[];
  instantMessages: InstantMessage[];
  imageData?: string; // Base64 encoded
  thumbnailImageData?: string; // Base64 encoded
}

export interface NewContact {
  givenName?: string;
  familyName?: string;
  middleName?: string;
  nickname?: string;
  prefix?: string;
  suffix?: string;
  organization?: string;
  jobTitle?: string;
  department?: string;
  note?: string;
  birthday?: string;
  phoneNumbers: PhoneNumber[];
  emailAddresses: EmailAddress[];
  postalAddresses: PostalAddress[];
  urlAddresses: UrlAddress[];
  socialProfiles: SocialProfile[];
  instantMessages: InstantMessage[];
  imageData?: string; // Base64 encoded
}

export interface ContactGroup {
  id: string;
  name: string;
  memberCount: number;
}

export type ContactSortOrder = 'givenName' | 'familyName' | 'none';

export interface ContactQuery {
  searchText?: string;
  groupId?: string;
  sortOrder?: ContactSortOrder;
  includeImages: boolean;
  limit?: number;
}

/**
 * Check current permissions for accessing contacts.
 * @returns Current permission status.
 */
export async function checkPermissions(): Promise<PermissionStatus> {
  return await invoke<PermissionStatus>('plugin:ios-contacts|check_permissions');
}

/**
 * Request permissions to access contacts.
 * @returns Updated permission status after request.
 */
export async function requestPermissions(): Promise<PermissionStatus> {
  return await invoke<PermissionStatus>('plugin:ios-contacts|request_permissions');
}

/**
 * Get all contacts matching the query.
 * @param query Optional query parameters to filter and sort contacts.
 * @returns Array of contacts matching the query.
 */
export async function getContacts(query?: ContactQuery): Promise<Contact[]> {
  return await invoke<Contact[]>('plugin:ios-contacts|get_contacts', { query });
}

/**
 * Get a specific contact by ID.
 * @param id The contact identifier.
 * @returns The contact information.
 */
export async function getContact(id: string): Promise<Contact> {
  return await invoke<Contact>('plugin:ios-contacts|get_contact', { id });
}

/**
 * Create a new contact.
 * @param contact The contact information to create.
 * @returns The created contact with its ID.
 */
export async function createContact(contact: NewContact): Promise<Contact> {
  return await invoke<Contact>('plugin:ios-contacts|create_contact', { contact });
}

/**
 * Update an existing contact.
 * @param contact The updated contact information including ID.
 * @returns The updated contact.
 */
export async function updateContact(contact: Contact): Promise<Contact> {
  return await invoke<Contact>('plugin:ios-contacts|update_contact', { contact });
}

/**
 * Delete a contact.
 * @param id The contact identifier to delete.
 */
export async function deleteContact(id: string): Promise<void> {
  return await invoke<void>('plugin:ios-contacts|delete_contact', { id });
}

/**
 * Get all contact groups.
 * @returns Array of contact groups.
 */
export async function getGroups(): Promise<ContactGroup[]> {
  return await invoke<ContactGroup[]>('plugin:ios-contacts|get_groups');
}

/**
 * Create a new contact group.
 * @param name The name of the group to create.
 * @returns The created group.
 */
export async function createGroup(name: string): Promise<ContactGroup> {
  return await invoke<ContactGroup>('plugin:ios-contacts|create_group', { name });
}

/**
 * Add a contact to a group.
 * @param contactId The contact identifier.
 * @param groupId The group identifier.
 */
export async function addContactToGroup(contactId: string, groupId: string): Promise<void> {
  return await invoke<void>('plugin:ios-contacts|add_contact_to_group', { contactId, groupId });
}

/**
 * Remove a contact from a group.
 * @param contactId The contact identifier.
 * @param groupId The group identifier.
 */
export async function removeContactFromGroup(contactId: string, groupId: string): Promise<void> {
  return await invoke<void>('plugin:ios-contacts|remove_contact_from_group', { contactId, groupId });
}

/**
 * Update a group's name.
 * @param groupId The group identifier.
 * @param name The new name for the group.
 * @returns The updated group.
 */
export async function updateGroup(groupId: string, name: string): Promise<ContactGroup> {
  return await invoke<ContactGroup>('plugin:ios-contacts|update_group', { groupId, name });
}

/**
 * Delete a contact group.
 * @param groupId The group identifier to delete.
 */
export async function deleteGroup(groupId: string): Promise<void> {
  return await invoke<void>('plugin:ios-contacts|delete_group', { groupId });
}
