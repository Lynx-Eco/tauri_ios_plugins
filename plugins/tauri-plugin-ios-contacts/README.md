# Tauri Plugin iOS Contacts

Access and manage iOS contacts in your Tauri applications.

## Features

- Read and write contacts with full field support
- Contact groups management
- Search and filter contacts
- Permission management
- Image support (photos and thumbnails)
- Support for all standard contact fields:
  - Names (given, family, middle, nickname, prefix, suffix)
  - Organization details
  - Phone numbers with labels
  - Email addresses
  - Postal addresses
  - URLs
  - Social profiles
  - Instant messaging
  - Notes and birthdays

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-contacts = "0.1"
```

## iOS Configuration

Add to your app's `Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts to display and manage them</string>
```

## Usage

### Rust

```rust
use tauri_plugin_ios_contacts::{ContactsExt, ContactQuery, NewContact};

// In your Tauri command
#[tauri::command]
async fn get_all_contacts(app: tauri::AppHandle) -> Result<Vec<Contact>, String> {
    let contacts = app.contacts();
    
    // Check permissions first
    let status = contacts.check_permissions()
        .map_err(|e| e.to_string())?;
    
    if status.contacts != PermissionState::Granted {
        // Request permissions
        contacts.request_permissions()
            .map_err(|e| e.to_string())?;
    }
    
    // Query contacts
    let query = ContactQuery {
        search_text: None,
        group_id: None,
        sort_order: Some(ContactSortOrder::GivenName),
        include_images: false,
        limit: Some(100),
    };
    
    contacts.get_contacts(Some(query))
        .map_err(|e| e.to_string())
}

// Create a new contact
#[tauri::command]
async fn create_contact(app: tauri::AppHandle, contact: NewContact) -> Result<Contact, String> {
    app.contacts()
        .create_contact(contact)
        .map_err(|e| e.to_string())
}
```

### JavaScript/TypeScript

```typescript
import { 
  checkPermissions, 
  requestPermissions, 
  getContacts, 
  createContact 
} from 'tauri-plugin-ios-contacts';

// Check and request permissions
const status = await checkPermissions();
if (status.contacts !== 'granted') {
  await requestPermissions();
}

// Get all contacts
const contacts = await getContacts({
  sortOrder: 'givenName',
  includeImages: false,
  limit: 100
});

// Search contacts
const searchResults = await getContacts({
  searchText: 'John',
  sortOrder: 'familyName'
});

// Create a new contact
const newContact = await createContact({
  givenName: 'John',
  familyName: 'Doe',
  phoneNumbers: [
    { label: 'mobile', value: '+1234567890' }
  ],
  emailAddresses: [
    { label: 'work', value: 'john.doe@example.com' }
  ]
});

// Update existing contact
const updated = await updateContact({
  id: contact.id,
  givenName: 'Jane',
  familyName: 'Doe'
});

// Delete contact
await deleteContact(contact.id);
```

## API Reference

### Types

#### Contact
```typescript
interface Contact {
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
  birthday?: string; // ISO date string
  phoneNumbers: PhoneNumber[];
  emailAddresses: EmailAddress[];
  postalAddresses: PostalAddress[];
  urlAddresses: UrlAddress[];
  socialProfiles: SocialProfile[];
  instantMessages: InstantMessage[];
  imageData?: string; // Base64
  thumbnailImageData?: string; // Base64
}
```

### Commands

#### `checkPermissions()`
Check current contacts permission status.

#### `requestPermissions()`
Request contacts access permission.

#### `getContacts(query?: ContactQuery)`
Retrieve contacts with optional filtering and sorting.

#### `getContact(id: string)`
Get a specific contact by ID.

#### `createContact(contact: NewContact)`
Create a new contact.

#### `updateContact(contact: Contact)`
Update an existing contact.

#### `deleteContact(id: string)`
Delete a contact.

#### `getGroups()`
Get all contact groups.

#### `createGroup(name: string)`
Create a new contact group.

## Error Handling

The plugin provides detailed error types:

- `AccessDenied` - User denied contacts access
- `ContactNotFound` - Requested contact doesn't exist
- `SaveFailed` - Failed to save contact
- `DeleteFailed` - Failed to delete contact
- `QueryFailed` - Failed to query contacts

## License

MIT or Apache-2.0