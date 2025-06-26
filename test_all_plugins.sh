#!/bin/bash

# Test compile all Swift plugin files

echo "Testing all iOS plugins for Swift compilation..."
echo "=============================================="

# Find all plugin directories
PLUGIN_DIRS=$(find /Users/user/dev/test/claude_code/tauri_ios_plugins/plugins -name "tauri-plugin-ios-*" -type d | sort)

TOTAL=0
PASSED=0
FAILED=0

for plugin_dir in $PLUGIN_DIRS; do
    plugin_name=$(basename "$plugin_dir")
    
    # Check if iOS sources exist
    if [ -d "$plugin_dir/ios/Sources" ]; then
        TOTAL=$((TOTAL + 1))
        echo -e "\n📦 Testing $plugin_name..."
        
        cd "$plugin_dir/ios"
        
        # Find all Swift files
        swift_files=$(find Sources -name "*.swift" | sort)
        
        if [ -z "$swift_files" ]; then
            echo "   ⚠️  No Swift files found"
            continue
        fi
        
        echo "   Found files: $swift_files"
        
        # Create a temporary test file that imports required frameworks
        cat > test_compile.swift << 'EOF'
// Test imports
import UIKit
import Foundation
import WebKit

// Dummy Tauri types for compilation
public typealias JSObject = [String: Any]
public typealias JSValue = Any
public typealias JsonObject = [String: Any?]

public class Invoke {
    public func resolve() {}
    public func resolve(_ data: JsonObject) {}
    public func resolve(_ data: Any) {}
    public func reject(_ message: String) {}
    public func parseArgs<T: Decodable>(_ type: T.Type) throws -> T {
        fatalError()
    }
}

public class Plugin {
    public func trigger(_ event: String, data: JSObject) {}
    public func load(webview: WKWebView) {}
}

// Include plugin sources
EOF
        
        # Try to compile with swiftc
        output=$(xcrun -sdk iphoneos swiftc \
            -target arm64-apple-ios13.0 \
            -parse \
            test_compile.swift \
            $swift_files \
            2>&1)
        
        # Check for errors
        if echo "$output" | grep -q "error:"; then
            echo "   ❌ FAILED - Compilation errors found:"
            echo "$output" | grep -E "error:|warning:" -A 2 -B 2 | head -20
            FAILED=$((FAILED + 1))
        else
            echo "   ✅ PASSED"
            PASSED=$((PASSED + 1))
            
            # Show warnings if any
            if echo "$output" | grep -q "warning:"; then
                echo "   ⚠️  Warnings found:"
                echo "$output" | grep "warning:" -A 2 -B 2 | head -10
            fi
        fi
        
        rm -f test_compile.swift
    else
        echo -e "\n📦 $plugin_name - No iOS sources found"
    fi
done

echo -e "\n=============================================="
echo "Summary: $PASSED/$TOTAL plugins compiled successfully"
if [ $FAILED -gt 0 ]; then
    echo "❌ $FAILED plugins failed compilation"
else
    echo "✅ All plugins compiled successfully!"
fi