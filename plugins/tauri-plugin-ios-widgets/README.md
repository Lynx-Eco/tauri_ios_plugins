# Tauri Plugin iOS Widgets

A Tauri plugin for creating and managing iOS home screen widgets using WidgetKit.

## Features

- **Widget Creation**: Build interactive home screen widgets
- **Timeline Management**: Control widget content updates
- **Multiple Families**: Support all widget sizes (small, medium, large, extra large)
- **Accessory Widgets**: Lock screen and complication widgets
- **Deep Linking**: Handle widget tap interactions
- **Preview Generation**: Generate widget previews
- **Refresh Scheduling**: Schedule automatic updates

## Installation

Add the plugin to your Tauri project:

```bash
cargo add tauri-plugin-ios-widgets
```

## Configuration

### iOS

1. Add a Widget Extension target to your iOS app in Xcode
2. Configure app groups for data sharing between app and widget
3. Add to your `Info.plist`:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>
```

### Rust

Register the plugin in your Tauri app:

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_ios_widgets::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Usage

### JavaScript/TypeScript

```typescript
import { widgets } from 'tauri-plugin-ios-widgets-api';

// Reload all widget timelines
await widgets.reloadAllTimelines();

// Reload specific widget kinds
await widgets.reloadTimelines(['weather', 'calendar']);

// Get current widget configurations
const configs = await widgets.getCurrentConfigurations();
configs.forEach(config => {
    console.log(`Widget: ${config.kind}, Family: ${config.family}`);
});

// Set widget data
await widgets.setWidgetData({
    kind: 'weather',
    family: 'systemMedium',
    content: {
        title: 'Weather',
        subtitle: 'San Francisco',
        body: '72°F Sunny',
        image: 'weather-sunny', // SF Symbol or base64
        backgroundColor: '#4A90E2',
        customData: {
            temperature: 72,
            condition: 'sunny'
        }
    },
    refreshDate: new Date(Date.now() + 3600000), // Refresh in 1 hour
    relevance: {
        score: 0.8,
        duration: 3600 // seconds
    }
});

// Get widget data
const data = await widgets.getWidgetData('weather', 'systemMedium');

// Request immediate widget update
await widgets.requestWidgetUpdate('weather');

// Get widget information
const info = await widgets.getWidgetInfo('weather');
console.log(`Supported families: ${info.supportedFamilies}`);

// Set widget URL for deep linking
await widgets.setWidgetUrl('weather', {
    scheme: 'myapp',
    host: 'weather',
    path: '/details',
    queryParameters: {
        city: 'San Francisco'
    }
});

// Preview widget with data
const previews = await widgets.previewWidgetData({
    kind: 'weather',
    content: {
        title: 'Weather Preview',
        subtitle: 'Test City',
        body: '75°F'
    }
});

// Schedule widget refresh
const scheduleId = await widgets.scheduleWidgetRefresh({
    widgetKind: 'weather',
    refreshIntervals: [{
        startDate: new Date(),
        intervalSeconds: 1800, // Every 30 minutes
        repeatCount: 48 // For 24 hours
    }]
});

// Cancel scheduled refresh
await widgets.cancelWidgetRefresh(scheduleId);

// Listen for widget events
await widgets.onWidgetEvent((event) => {
    switch (event.eventType) {
        case 'appeared':
            console.log('Widget appeared on screen');
            break;
        case 'disappeared':
            console.log('Widget removed from screen');
            break;
        case 'tapped':
            console.log('Widget was tapped');
            break;
        case 'timelineReloaded':
            console.log('Timeline was reloaded');
            break;
    }
});
```

### Rust

```rust
use tauri_plugin_ios_widgets::{WidgetsExt, WidgetData, WidgetContent};
use std::collections::HashMap;

// Get widgets instance
let widgets = app.widgets();

// Reload all timelines
widgets.reload_all_timelines()?;

// Set widget data
let mut custom_data = HashMap::new();
custom_data.insert("temperature".to_string(), serde_json::json!(72));

let widget_data = WidgetData {
    kind: "weather".to_string(),
    family: Some(WidgetFamily::SystemMedium),
    content: WidgetContent {
        title: Some("Weather".to_string()),
        subtitle: Some("San Francisco".to_string()),
        body: Some("72°F Sunny".to_string()),
        image: None,
        background_image: None,
        tint_color: Some("#4A90E2".to_string()),
        font: None,
        custom_data,
    },
    refresh_date: Some(Utc::now() + Duration::hours(1)),
    expiration_date: None,
    relevance: None,
};

widgets.set_widget_data(widget_data)?;
```

## API Reference

### Timeline Management

- `reloadAllTimelines()` - Reload all widget timelines
- `reloadTimelines(widgetKinds)` - Reload specific widget timelines

### Configuration

- `getCurrentConfigurations()` - Get active widget configurations
- `getWidgetFamilies(kind)` - Get supported families for widget kind
- `getWidgetInfo(kind)` - Get widget information

### Data Management

- `setWidgetData(data)` - Set widget content data
- `getWidgetData(kind, family)` - Get widget data
- `clearWidgetData(kind)` - Clear widget data
- `requestWidgetUpdate(kind)` - Request immediate update

### URL Handling

- `setWidgetUrl(kind, url)` - Set widget tap URL
- `getWidgetUrl(kind)` - Get widget URL

### Preview

- `previewWidgetData(data)` - Generate widget previews

### Scheduling

- `scheduleWidgetRefresh(schedule)` - Schedule automatic refresh
- `cancelWidgetRefresh(scheduleId)` - Cancel scheduled refresh

## Data Types

### WidgetConfiguration
```typescript
{
    kind: string;                    // Widget identifier
    family: WidgetFamily;            // Widget size
    intentConfiguration?: object;    // Siri intent config
}
```

### WidgetFamily
```typescript
type WidgetFamily = 
    | 'systemSmall'       // 2x2 grid
    | 'systemMedium'      // 4x2 grid
    | 'systemLarge'       // 4x4 grid
    | 'systemExtraLarge'  // iPad only
    | 'accessoryCircular' // Lock screen
    | 'accessoryRectangular'
    | 'accessoryInline';
```

### WidgetContent
```typescript
{
    title?: string;
    subtitle?: string;
    body?: string;
    image?: string;           // SF Symbol name or base64
    backgroundImage?: string;
    tintColor?: string;      // Hex color
    font?: WidgetFont;
    customData: object;      // Custom data for widget
}
```

### WidgetData
```typescript
{
    kind: string;
    family?: WidgetFamily;
    content: WidgetContent;
    refreshDate?: Date;      // When to refresh
    expirationDate?: Date;   // When data expires
    relevance?: {
        score: number;       // 0-1, for Smart Stacks
        duration: number;    // Seconds
    };
}
```

## Widget Extension

Create a Widget Extension in Xcode:

```swift
import WidgetKit
import SwiftUI

struct WeatherWidget: Widget {
    let kind: String = "weather"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetView(entry: entry)
        }
        .configurationDisplayName("Weather")
        .description("Current weather conditions")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

## Events

Widget events:
- `widget://appeared` - Widget shown on screen
- `widget://disappeared` - Widget removed
- `widget://tapped` - User tapped widget
- `widget://timeline-reloaded` - Timeline refreshed
- `widget://configuration-changed` - Config changed
- `widget://error` - Error occurred

## Best Practices

1. **Update Frequency**: Don't update too frequently to save battery
2. **Data Size**: Keep widget data small and efficient
3. **Relevance**: Use relevance scores for Smart Stack priority
4. **Images**: Use SF Symbols when possible for better performance
5. **Timeline**: Provide future entries to reduce reload frequency

## Platform Support

This plugin only works on iOS 14+ devices with WidgetKit support. Desktop platforms will return `NotSupported` errors.

## License

This plugin is licensed under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.