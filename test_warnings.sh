#!/bin/bash

# Test for warnings in all plugins

echo "Checking for warnings in all iOS plugins..."
echo "=========================================="

PLUGIN_DIRS=$(find /Users/user/dev/test/claude_code/tauri_ios_plugins/plugins -name "tauri-plugin-ios-*" -type d | sort)

for plugin_dir in $PLUGIN_DIRS; do
    plugin_name=$(basename "$plugin_dir")
    
    if [ -d "$plugin_dir/ios/Sources" ]; then
        cd "$plugin_dir/ios"
        
        # Create test file with proper imports
        cat > test_compile.swift << 'EOF'
import UIKit
import Foundation
import WebKit
import AVFoundation
import CoreLocation
import CoreMotion
import CoreBluetooth
import HealthKit
import Photos
import PhotosUI
import CallKit
import PushKit
import Contacts
import ContactsUI
import MessageUI
import Messages
import MessageUI
import Intents
import IntentsUI
import WidgetKit
import DeviceActivity
import FamilyControls
import ManagedSettings

// Tauri mocks
public typealias JSObject = [String: Any]
public typealias JSValue = Any
public typealias JsonObject = [String: Any?]

public enum JsonValue {
    case dictionary(JsonObject)
    case array([JsonValue])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
}

public class Invoke {
    public let callback: String = ""
    public func resolve() {}
    public func resolve(_ data: JsonObject) {}
    public func resolve(_ data: Any) {}
    public func resolve(_ data: JsonValue) {}
    public func reject(_ message: String) {}
    public func parseArgs<T: Decodable>(_ type: T.Type) throws -> T { fatalError() }
    public func sendResponse(_ callback: String, _ response: String?) {}
}

public class Channel {
    public init(_ invoke: Invoke) {}
    public func send(_ data: JSObject) {}
}

public class Plugin {
    public func trigger(_ event: String, data: JSObject) {}
    @objc public func load(webview: WKWebView) {}
    @objc public func checkPermissions(_ invoke: Invoke) {}
    @objc public func requestPermissions(_ invoke: Invoke) {}
}

// Helper to serialize JsonValue
func serialize(_ value: JsonValue) -> String? { return nil }

@_cdecl("init_plugin")
public func initPlugin() -> Plugin { fatalError() }
EOF
        
        swift_files=$(find Sources -name "*.swift" | sort)
        
        # Compile and capture all output
        output=$(xcrun -sdk iphoneos swiftc \
            -target arm64-apple-ios13.0 \
            -parse \
            -suppress-warnings \
            test_compile.swift \
            $swift_files \
            2>&1)
        
        # Check for any issues
        if echo "$output" | grep -qE "(error:|warning:)"; then
            echo -e "\n⚠️  $plugin_name has issues:"
            echo "$output" | grep -E "(error:|warning:)" -A 2 -B 2
        fi
        
        rm -f test_compile.swift
    fi
done

echo -e "\n=========================================="
echo "Detailed check complete"