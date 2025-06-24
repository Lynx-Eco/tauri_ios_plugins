#!/bin/bash

# Script to process all iOS plugins
set -e

WORKSPACE_DIR="/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins-workspace"
PLUGINS_DIR="/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"

# List of plugins to process
PLUGINS=(
    "ios-camera"
    "ios-microphone"
    "ios-location"
    "ios-photos"
    "ios-music"
    "ios-keychain"
    "ios-screentime"
    "ios-files"
    "ios-messages"
    "ios-callkit"
    "ios-bluetooth"
    "ios-shortcuts"
    "ios-widgets"
    "ios-motion"
    "ios-barometer"
    "ios-proximity"
)

process_plugin() {
    local plugin=$1
    echo "Processing $plugin..."
    
    local OLD_PLUGIN_DIR="$PLUGINS_DIR/$plugin"
    local NEW_PLUGIN_DIR="$WORKSPACE_DIR/tauri-plugin-$plugin"
    
    # Check if old plugin exists
    if [ ! -d "$OLD_PLUGIN_DIR" ]; then
        echo "Warning: Old plugin $plugin not found at $OLD_PLUGIN_DIR"
        return
    fi
    
    # 1. Copy Swift implementation
    if [ -d "$OLD_PLUGIN_DIR/ios/Sources" ]; then
        echo "  Copying Swift implementation..."
        cp -r "$OLD_PLUGIN_DIR/ios/Sources/"*.swift "$NEW_PLUGIN_DIR/ios/Sources/" 2>/dev/null || true
    fi
    
    # 2. Copy Rust files
    if [ -d "$OLD_PLUGIN_DIR/src" ]; then
        echo "  Copying Rust implementation..."
        cp -r "$OLD_PLUGIN_DIR/src/"* "$NEW_PLUGIN_DIR/src/" 2>/dev/null || true
    fi
    
    # 3. Copy permissions
    if [ -f "$OLD_PLUGIN_DIR/permissions/schemas/schema.json" ]; then
        echo "  Copying permissions..."
        mkdir -p "$NEW_PLUGIN_DIR/permissions/schemas"
        cp "$OLD_PLUGIN_DIR/permissions/schemas/schema.json" "$NEW_PLUGIN_DIR/permissions/schemas/"
    fi
    
    # 4. Remove ExamplePlugin.swift
    echo "  Removing ExamplePlugin.swift..."
    rm -f "$NEW_PLUGIN_DIR/ios/Sources/ExamplePlugin.swift"
    
    # 5. Update Cargo.toml
    echo "  Updating Cargo.toml..."
    # This will be done separately with sed commands
    
    # 6. Update package.json
    echo "  Updating package.json..."
    # This will be done separately with sed commands
    
    # 7. Update Package.swift
    echo "  Updating Package.swift..."
    # This will be done separately
    
    # 8. Create TypeScript bindings
    echo "  Creating TypeScript bindings..."
    # This will be done separately
    
    echo "  $plugin processing complete!"
}

# Process all plugins
for plugin in "${PLUGINS[@]}"; do
    process_plugin "$plugin"
done

echo "All plugins processed!"