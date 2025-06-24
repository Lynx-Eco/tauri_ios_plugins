# Tauri Plugin iOS Files

A Tauri plugin for comprehensive iOS Files app integration and document management.

## Features

- Document picker for files and folders
- Save files to user-selected locations
- Open files in other apps
- Import/export files from/to iOS Files app
- List and manage documents
- Read/write file operations
- Move, copy, and delete files
- Create folders
- File sharing via iOS share sheet
- Quick Look preview
- iCloud Drive integration
- File monitoring for changes
- Security-scoped resource access

## Installation

Add the plugin to your Tauri project:

```toml
[dependencies]
tauri-plugin-ios-files = { path = "../path/to/plugin" }
```

## Usage

```rust
use tauri_plugin_ios_files::{FilesExt, FilePickerOptions, FileType, SaveFileOptions, FileData};

#[tauri::command]
async fn pick_documents<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<Vec<PickedFile>, String> {
    let options = FilePickerOptions {
        types: vec![FileType::Pdf, FileType::Text],
        allow_multiple: true,
        starting_directory: None,
    };
    
    app.files()
        .pick_multiple_files(options)
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn save_document<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
    content: String,
) -> Result<String, String> {
    let options = SaveFileOptions {
        suggested_name: "document.txt".to_string(),
        types: vec![FileType::Text],
        data: FileData::Text(content),
    };
    
    app.files()
        .save_file(options)
        .map_err(|e| e.to_string())
}

#[tauri::command]
async fn list_app_documents<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<Vec<DocumentInfo>, String> {
    use tauri_plugin_ios_files::{ListOptions, SortOption};
    
    let options = ListOptions {
        directory_url: None, // Uses app's documents directory
        include_hidden: false,
        include_packages: false,
        sort_by: SortOption::Date,
        filter: None,
    };
    
    app.files()
        .list_documents(options)
        .map_err(|e| e.to_string())
}
```

## File Types

The plugin supports these predefined file types:
- `Image` - Images (JPEG, PNG, etc.)
- `Video` - Video files
- `Audio` - Audio files
- `Pdf` - PDF documents
- `Text` - Plain text files
- `Spreadsheet` - Excel, Numbers, etc.
- `Presentation` - PowerPoint, Keynote, etc.
- `Archive` - ZIP, RAR, etc.
- `Custom(Vec<String>)` - Custom UTI types

## API Methods

### File Picking
- `pick_file(options)` - Pick a single file
- `pick_multiple_files(options)` - Pick multiple files
- `pick_folder()` - Pick a folder

### File Management
- `save_file(options)` - Save file to user-selected location
- `open_in_files(url)` - Open file in iOS Files app
- `import_from_files(options)` - Import files from Files app
- `export_to_files(options)` - Export files to Files app

### Document Operations
- `list_documents(options)` - List documents in directory
- `read_file(url)` - Read file contents
- `write_file(url, data)` - Write data to file
- `delete_file(url)` - Delete a file
- `move_file(operation)` - Move file to new location
- `copy_file(operation)` - Copy file to new location
- `create_folder(url, name)` - Create new folder
- `get_file_info(url)` - Get detailed file information

### Sharing & Preview
- `share_file(options)` - Share files via iOS share sheet
- `preview_file(options)` - Preview file with Quick Look

### iCloud Integration
- `get_cloud_status(url)` - Get iCloud sync status
- `download_from_cloud(url)` - Download file from iCloud
- `evict_from_local(url)` - Remove local copy (keep in iCloud)

### File Monitoring
- `start_monitoring(options)` - Monitor directories for changes
- `stop_monitoring()` - Stop file monitoring

## File Data Types

Files can be handled in three formats:
```rust
pub enum FileData {
    Base64(String),  // Binary data as base64
    Text(String),    // Text content
    Url(String),     // Reference to existing file
}
```

## Cloud Status

Files can have these iCloud states:
- `Current` - File is up to date
- `Downloading` - Currently downloading
- `Downloaded` - Downloaded and available
- `NotDownloaded` - In iCloud but not local
- `NotInCloud` - Local file only

## Events

The plugin emits these events:
- `fileChanged` - File system changes when monitoring

## Security

iOS uses security-scoped bookmarks for persistent file access. The plugin handles:
- Automatic security scope management
- Bookmark creation for persistent access
- Proper resource cleanup

## Example: Document Browser

```rust
use tauri_plugin_ios_files::{FilesExt, ListOptions, FileFilter};
use chrono::{DateTime, Utc, Duration};

#[tauri::command]
async fn get_recent_pdfs<R: tauri::Runtime>(
    app: tauri::AppHandle<R>,
) -> Result<Vec<DocumentInfo>, String> {
    let week_ago = Utc::now() - Duration::days(7);
    
    let options = ListOptions {
        directory_url: None,
        include_hidden: false,
        include_packages: false,
        sort_by: SortOption::Date,
        filter: Some(FileFilter {
            types: Some(vec![FileType::Pdf]),
            name_pattern: None,
            min_size: None,
            max_size: Some(10 * 1024 * 1024), // Max 10MB
            modified_after: Some(week_ago),
            modified_before: None,
        }),
    };
    
    app.files()
        .list_documents(options)
        .map_err(|e| e.to_string())
}
```

## Platform Support

This plugin only supports iOS. Desktop platforms will return `NotSupported` errors.

## Permissions

### iOS

Add to your `Info.plist`:

```xml
<key>UISupportsDocumentBrowser</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>
```

For iCloud support:
```xml
<key>NSUbiquitousContainers</key>
<dict>
    <key>iCloud.com.yourcompany.yourapp</key>
    <dict>
        <key>NSUbiquitousContainerIsDocumentScopePublic</key>
        <true/>
        <key>NSUbiquitousContainerName</key>
        <string>Your App</string>
    </dict>
</dict>
```