#!/bin/bash

# Script to update plugin configurations

PLUGINS_DIR="/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"
cd "$PLUGINS_DIR"

# Function to update a plugin
update_plugin() {
    local plugin=$1
    local plugin_dir="tauri-plugin-ios-${plugin}-v2"
    
    echo "Updating plugin: $plugin"
    
    # Update Cargo.toml
    sed -i '' "s/tauri-plugin-ios-${plugin}-v2/tauri-plugin-ios-${plugin}/g" "${plugin_dir}/Cargo.toml"
    sed -i '' 's/authors = \[ "You" \]/authors = \[ "Tauri Plugin iOS" \]/g' "${plugin_dir}/Cargo.toml"
    sed -i '' "s/description = \"\"/description = \"Access ${plugin} APIs on iOS for Tauri applications\"/g" "${plugin_dir}/Cargo.toml"
    
    # Update package.json
    sed -i '' "s/tauri-plugin-ios-${plugin}-v2-api/@tauri-plugin\/ios-${plugin}/g" "${plugin_dir}/package.json"
    sed -i '' 's/"author": "You"/"author": "Tauri Plugin iOS"/g' "${plugin_dir}/package.json"
    sed -i '' "s/\"description\": \"\"/\"description\": \"Access ${plugin} APIs on iOS for Tauri applications\"/g" "${plugin_dir}/package.json"
    
    # Update iOS Package.swift
    sed -i '' "s/tauri-plugin-ios-${plugin}-v2/tauri-plugin-ios-${plugin}/g" "${plugin_dir}/ios/Package.swift"
    
    echo "Plugin $plugin configurations updated"
}

# List of plugins to update
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
    update_plugin "$plugin"
done

echo "All plugin configurations updated!"