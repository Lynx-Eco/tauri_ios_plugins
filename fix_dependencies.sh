#!/bin/bash

# Script to fix missing dependencies in iOS plugins

PLUGIN_DIR="/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"

echo "=== Fixing Missing Dependencies in iOS Plugins ==="
echo ""

# Function to add dependency if missing
add_dependency() {
    local cargo_file=$1
    local dep_name=$2
    local dep_spec=$3
    
    if ! grep -q "^$dep_name" "$cargo_file"; then
        echo "  Adding $dep_name to $(basename $(dirname "$cargo_file"))"
        # Find the [dependencies] section and add after it
        sed -i.bak "/^\[dependencies\]/a\\
$dep_name = $dep_spec" "$cargo_file"
    fi
}

# Plugins that need chrono
chrono_plugins=(
    "tauri-plugin-ios-barometer"
    "tauri-plugin-ios-bluetooth"
    "tauri-plugin-ios-files"
    "tauri-plugin-ios-messages"
    "tauri-plugin-ios-motion"
    "tauri-plugin-ios-proximity"
    "tauri-plugin-ios-screentime"
    "tauri-plugin-ios-widgets"
)

# Plugins that need serde_json
serde_json_plugins=(
    "tauri-plugin-ios-barometer"
    "tauri-plugin-ios-bluetooth"
    "tauri-plugin-ios-location"
    "tauri-plugin-ios-microphone"
    "tauri-plugin-ios-motion"
    "tauri-plugin-ios-photos"
    "tauri-plugin-ios-shortcuts"
    "tauri-plugin-ios-widgets"
)

echo "Fixing chrono dependencies..."
for plugin in "${chrono_plugins[@]}"; do
    cargo_file="$PLUGIN_DIR/$plugin/Cargo.toml"
    if [ -f "$cargo_file" ]; then
        add_dependency "$cargo_file" "chrono" '{ version = "0.4", features = ["serde"] }'
    fi
done

echo ""
echo "Fixing serde_json dependencies..."
for plugin in "${serde_json_plugins[@]}"; do
    cargo_file="$PLUGIN_DIR/$plugin/Cargo.toml"
    if [ -f "$cargo_file" ]; then
        add_dependency "$cargo_file" "serde_json" '"1.0"'
    fi
done

echo ""
echo "Cleaning up backup files..."
find "$PLUGIN_DIR" -name "*.bak" -delete

echo ""
echo "✅ Dependencies fixed! Now checking compilation status..."
echo ""

# Quick compilation check
for plugin in "$PLUGIN_DIR"/tauri-plugin-ios-*/; do
    if [ -d "$plugin" ]; then
        plugin_name=$(basename "$plugin")
        echo -n "Checking $plugin_name... "
        cd "$plugin" 2>/dev/null
        if cargo check --quiet 2>/dev/null; then
            echo "✅ Compiles"
        else
            echo "❌ Still has errors"
        fi
        cd - >/dev/null 2>&1
    fi
done