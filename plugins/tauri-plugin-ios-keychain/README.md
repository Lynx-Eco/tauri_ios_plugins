# Tauri Plugin iOS Keychain

A Tauri plugin for secure credential storage using the iOS Keychain Services API.

## Features

- **Secure Storage**: Store passwords, tokens, and sensitive data securely
- **Biometric Protection**: Optional Face ID/Touch ID authentication
- **Access Control**: Fine-grained access control options
- **Synchronization**: iCloud Keychain sync support
- **Sharing**: Share credentials between app groups

## Installation

Add the plugin to your Tauri project:

```bash
cargo add tauri-plugin-ios-keychain
```

## Configuration

### iOS

Add keychain sharing capability to your `Info.plist` if needed:

```xml
<key>keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)com.yourcompany.yourapp</string>
</array>
```

### Rust

Register the plugin in your Tauri app:

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_ios_keychain::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Usage

### JavaScript/TypeScript

```typescript
import { keychain } from 'tauri-plugin-ios-keychain-api';

// Store a password
await keychain.setPassword({
    service: 'myapp',
    account: 'user@example.com',
    password: 'secret123',
    accessGroup: null, // Use default access group
    synchronizable: true, // Sync with iCloud Keychain
    biometricProtected: true // Require Face ID/Touch ID
});

// Retrieve a password
const result = await keychain.getPassword({
    service: 'myapp',
    account: 'user@example.com'
});
console.log('Password:', result.password);

// Store generic data
await keychain.setGenericPassword({
    service: 'myapp-tokens',
    account: 'api-token',
    data: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    label: 'API Access Token',
    accessible: 'whenUnlockedThisDeviceOnly'
});

// Delete credentials
await keychain.deletePassword({
    service: 'myapp',
    account: 'user@example.com'
});

// Store internet credentials
await keychain.setInternetPassword({
    server: 'api.example.com',
    account: 'user@example.com',
    password: 'secret123',
    protocol: 'https',
    port: 443,
    path: '/api'
});

// Find items
const items = await keychain.findItems({
    service: 'myapp',
    synchronizable: true
});

// Update existing item
await keychain.updatePassword({
    service: 'myapp',
    account: 'user@example.com',
    newPassword: 'newSecret456',
    oldPassword: 'secret123' // Optional verification
});

// Check biometric availability
const biometricAvailable = await keychain.isBiometricAvailable();
if (biometricAvailable) {
    // Use biometric protection
}

// Get all accounts for a service
const accounts = await keychain.getAllAccounts('myapp');
console.log('Accounts:', accounts);
```

### Rust

```rust
use tauri_plugin_ios_keychain::{KeychainExt, PasswordQuery, PasswordData};

// Store password
let password_data = PasswordData {
    service: "myapp".to_string(),
    account: "user@example.com".to_string(),
    password: "secret123".to_string(),
    access_group: None,
    synchronizable: true,
    biometric_protected: false,
};

app.keychain().set_password(password_data)?;

// Retrieve password
let query = PasswordQuery {
    service: "myapp".to_string(),
    account: "user@example.com".to_string(),
};

let result = app.keychain().get_password(query)?;
println!("Password: {}", result.password);
```

## API Reference

### Password Management

- `setPassword(data)` - Store a password
- `getPassword(query)` - Retrieve a password
- `deletePassword(query)` - Delete a password
- `updatePassword(data)` - Update existing password
- `findItems(query)` - Search for keychain items
- `getAllAccounts(service)` - Get all accounts for a service

### Generic Password

- `setGenericPassword(data)` - Store generic secure data
- `getGenericPassword(query)` - Retrieve generic data
- `deleteGenericPassword(query)` - Delete generic data

### Internet Password

- `setInternetPassword(data)` - Store internet credentials
- `getInternetPassword(query)` - Retrieve internet credentials
- `deleteInternetPassword(query)` - Delete internet credentials

### Security

- `isBiometricAvailable()` - Check Face ID/Touch ID availability
- `isKeychainAvailable()` - Check keychain availability

## Data Types

### PasswordData
```typescript
{
    service: string;           // Service/app identifier
    account: string;           // Account/username
    password: string;          // Password to store
    accessGroup?: string;      // Keychain access group
    synchronizable?: boolean;  // Sync with iCloud
    biometricProtected?: boolean; // Require biometric auth
    label?: string;           // User-visible label
    comment?: string;         // Comment
    accessible?: Accessible;  // When item is accessible
}
```

### Accessible Options
```typescript
type Accessible = 
    | 'whenUnlocked'                    // Default
    | 'whenUnlockedThisDeviceOnly'      
    | 'afterFirstUnlock'
    | 'afterFirstUnlockThisDeviceOnly'
    | 'whenPasscodeSetThisDeviceOnly'
    | 'always'                          // Deprecated
    | 'alwaysThisDeviceOnly';          // Deprecated
```

### InternetPasswordData
```typescript
{
    server: string;          // Server domain
    account: string;         // Username
    password: string;        // Password
    protocol?: string;       // http, https, ftp, etc.
    port?: number;          // Port number
    path?: string;          // URL path
    securityDomain?: string; // Security domain
    authenticationType?: string; // Auth type
    synchronizable?: boolean;
    accessGroup?: string;
}
```

## Security Best Practices

1. **Use Biometric Protection**: Enable for sensitive data
2. **Device-Only Storage**: Use `whenUnlockedThisDeviceOnly` for sensitive data
3. **Access Groups**: Use app groups for sharing between your apps
4. **Minimal Permissions**: Only request what you need
5. **Regular Cleanup**: Delete old/unused credentials

## Error Handling

Common errors:
- `ItemNotFound`: No matching keychain item
- `DuplicateItem`: Item already exists
- `AuthenticationFailed`: Biometric auth failed
- `AccessDenied`: No permission to access item
- `BiometricNotAvailable`: Device doesn't support biometrics

## Platform Support

This plugin only works on iOS devices. Desktop platforms will return `NotSupported` errors.

## License

This plugin is licensed under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.