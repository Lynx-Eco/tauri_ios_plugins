#!/bin/bash

# Script to check iOS plugins for common errors

PLUGIN_DIR="/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"
ISSUES_FOUND=0

echo "=== Checking iOS Plugins for Common Errors ==="
echo ""

# Function to extract function names from Rust files
extract_functions() {
    local file=$1
    # Extract pub fn names, handling multiline function signatures
    grep -E "^\s*pub\s+(async\s+)?fn\s+" "$file" 2>/dev/null | sed -E 's/^\s*pub\s+(async\s+)?fn\s+([a-zA-Z0-9_]+).*/\2/' | sort | uniq
}

# Function to check if serde_json is in Cargo.toml when json! is used
check_serde_json_dependency() {
    local plugin_path=$1
    local plugin_name=$(basename "$plugin_path")
    
    # Check if json! macro is used in any Rust file
    if grep -r "json!" "$plugin_path/src" >/dev/null 2>&1; then
        # Check if serde_json is in Cargo.toml
        if ! grep -q "serde_json" "$plugin_path/Cargo.toml" 2>/dev/null; then
            echo "  ⚠️  Missing serde_json dependency (uses json! macro)"
            return 1
        fi
    fi
    return 0
}

# Iterate through all iOS plugins
for plugin in "$PLUGIN_DIR"/tauri-plugin-ios-*/; do
    if [ -d "$plugin" ]; then
        plugin_name=$(basename "$plugin")
        echo "Checking $plugin_name:"
        
        issues_for_plugin=0
        
        # 1. Check if mobile.rs has all methods from commands.rs
        if [ -f "$plugin/src/commands.rs" ] && [ -f "$plugin/src/mobile.rs" ]; then
            commands_functions=$(extract_functions "$plugin/src/commands.rs")
            mobile_functions=$(extract_functions "$plugin/src/mobile.rs")
            
            # Find functions in commands.rs that are not in mobile.rs
            missing_functions=""
            for func in $commands_functions; do
                if [[ ! " $mobile_functions " =~ " $func " ]]; then
                    missing_functions="$missing_functions $func"
                fi
            done
            
            if [ -n "$missing_functions" ]; then
                echo "  ⚠️  Missing in mobile.rs:$missing_functions"
                ((issues_for_plugin++))
            fi
        fi
        
        # 2. Check for serde_json dependency
        if ! check_serde_json_dependency "$plugin"; then
            ((issues_for_plugin++))
        fi
        
        # 3. Check if TypeScript exports match Rust commands
        if [ -f "$plugin/guest-js/index.ts" ] && [ -f "$plugin/src/commands.rs" ]; then
            # Extract exported functions from TypeScript
            ts_functions=$(grep -E "^export\s+(async\s+)?function\s+" "$plugin/guest-js/index.ts" 2>/dev/null | sed -E 's/^export\s+(async\s+)?function\s+([a-zA-Z0-9_]+).*/\2/' | sort | uniq)
            
            # Compare with Rust commands (convert snake_case to camelCase for comparison)
            for rust_func in $commands_functions; do
                # Convert snake_case to camelCase
                camel_func=$(echo "$rust_func" | sed -E 's/_([a-z])/\U\1/g')
                if [[ ! " $ts_functions " =~ " $camel_func " ]] && [[ ! " $ts_functions " =~ " $rust_func " ]]; then
                    echo "  ⚠️  TypeScript missing export for: $rust_func"
                    ((issues_for_plugin++))
                fi
            done
        fi
        
        # 4. Try to compile and check for errors
        echo "  Checking compilation..."
        cd "$plugin" 2>/dev/null
        if ! cargo check --quiet 2>/dev/null; then
            echo "  ❌ Compilation errors found"
            ((issues_for_plugin++))
        fi
        cd - >/dev/null 2>&1
        
        if [ $issues_for_plugin -eq 0 ]; then
            echo "  ✅ No issues found"
        else
            ((ISSUES_FOUND++))
        fi
        
        echo ""
    fi
done

echo "=== Summary ==="
echo "Total plugins with issues: $ISSUES_FOUND"