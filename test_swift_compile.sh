#!/bin/bash

# Test compile individual Swift plugin files

PLUGINS=(
    "tauri-plugin-ios-music"
    "tauri-plugin-ios-bluetooth"
    "tauri-plugin-ios-callkit"
    "tauri-plugin-ios-proximity"
    "tauri-plugin-ios-motion"
)

for plugin in "${PLUGINS[@]}"; do
    echo "Testing $plugin..."
    cd "/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins/$plugin/ios"
    
    # Create a temporary file that imports the plugin
    cat > test_compile.swift << EOF
import UIKit
import Tauri
import WebKit

// Import the plugin source
#sourceLocation(file: "Sources/${plugin/tauri-plugin-ios-/}.swift", line: 1)
EOF
    
    # Try to compile with swiftc directly
    xcrun -sdk iphoneos swiftc \
        -target arm64-apple-ios13.0 \
        -parse \
        -I .tauri/tauri-api/Sources \
        Sources/*.swift \
        2>&1 | grep -E "error:|warning:" -A 2 -B 2 | head -20
    
    rm -f test_compile.swift
    echo "---"
done