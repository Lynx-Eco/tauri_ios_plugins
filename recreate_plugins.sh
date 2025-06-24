#!/bin/bash

# Script to recreate iOS plugins with proper structure

PLUGINS_DIR="/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"
cd "$PLUGINS_DIR"

# List of plugins to recreate (excluding healthkit and contacts which are already done)
PLUGINS=(
    "camera"
    "microphone"
    "location"
    "photos"
    "music"
    "keychain"
    "screentime"
    "files"
    "messages"
    "callkit"
    "bluetooth"
    "shortcuts"
    "widgets"
    "motion"
    "barometer"
    "proximity"
)

for plugin in "${PLUGINS[@]}"; do
    echo "Processing plugin: $plugin"
    
    # Create new plugin with v2 suffix
    npx @tauri-apps/cli plugin new "ios-${plugin}-v2" --ios
    
    # Copy Swift implementation
    cp "tauri-plugin-ios-${plugin}/ios/Sources/"*.swift "tauri-plugin-ios-${plugin}-v2/ios/Sources/"
    
    # Copy Rust files
    cp "tauri-plugin-ios-${plugin}/src/"*.rs "tauri-plugin-ios-${plugin}-v2/src/"
    
    # Copy permissions
    cp -r "tauri-plugin-ios-${plugin}/permissions/"* "tauri-plugin-ios-${plugin}-v2/permissions/"
    
    # Remove example Swift file
    rm -f "tauri-plugin-ios-${plugin}-v2/ios/Sources/ExamplePlugin.swift"
    
    echo "Plugin $plugin files copied"
done

echo "All plugins processed!"