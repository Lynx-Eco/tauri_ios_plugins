#!/bin/bash

# Detailed plugin checking script

PLUGIN_DIR="/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"

echo "=== Detailed iOS Plugin Analysis ==="
echo ""

check_plugin() {
    local plugin_path=$1
    local plugin_name=$(basename "$plugin_path")
    
    echo "## $plugin_name"
    echo ""
    
    # 1. Check for missing dependencies
    echo "### Checking dependencies:"
    
    # Check for chrono usage
    if grep -r "DateTime<Utc>" "$plugin_path/src" >/dev/null 2>&1 || grep -r "chrono::" "$plugin_path/src" >/dev/null 2>&1; then
        if ! grep -q "chrono" "$plugin_path/Cargo.toml" 2>/dev/null; then
            echo "- ❌ Missing 'chrono' dependency (uses DateTime<Utc>)"
        fi
    fi
    
    # Check for serde_json usage
    if grep -r "serde_json::" "$plugin_path/src" >/dev/null 2>&1 || grep -r "json!" "$plugin_path/src" >/dev/null 2>&1; then
        if ! grep -q "serde_json" "$plugin_path/Cargo.toml" 2>/dev/null; then
            echo "- ❌ Missing 'serde_json' dependency"
        fi
    fi
    
    # Check for uuid usage
    if grep -r "Uuid" "$plugin_path/src" >/dev/null 2>&1 && ! grep -r "type Uuid = String" "$plugin_path/src" >/dev/null 2>&1; then
        if ! grep -q "uuid" "$plugin_path/Cargo.toml" 2>/dev/null; then
            echo "- ❌ Missing 'uuid' dependency"
        fi
    fi
    
    # 2. Compare commands.rs and mobile.rs functions
    if [ -f "$plugin_path/src/commands.rs" ] && [ -f "$plugin_path/src/mobile.rs" ]; then
        echo ""
        echo "### Command implementation check:"
        
        # Extract function names from commands.rs
        commands_funcs=$(grep -E "^\s*pub\s*(async\s+)?fn\s+" "$plugin_path/src/commands.rs" 2>/dev/null | \
                        sed -E 's/^\s*pub\s*(async\s+)?fn\s+([a-zA-Z0-9_]+).*/\2/' | sort)
        
        # Extract function names from mobile.rs impl block
        mobile_funcs=$(grep -E "^\s*pub\s+fn\s+" "$plugin_path/src/mobile.rs" 2>/dev/null | \
                      sed -E 's/^\s*pub\s+fn\s+([a-zA-Z0-9_]+).*/\1/' | sort)
        
        missing=""
        for func in $commands_funcs; do
            if [[ ! " $mobile_funcs " =~ " $func " ]]; then
                missing="$missing $func"
            fi
        done
        
        if [ -n "$missing" ]; then
            echo "- ❌ Missing in mobile.rs:$missing"
        else
            echo "- ✅ All commands implemented in mobile.rs"
        fi
    fi
    
    # 3. Check TypeScript bindings
    if [ -f "$plugin_path/guest-js/index.ts" ]; then
        echo ""
        echo "### TypeScript bindings check:"
        
        # Check if invoke is imported
        if ! grep -q "import.*invoke.*from.*@tauri-apps/api" "$plugin_path/guest-js/index.ts" 2>/dev/null; then
            echo "- ❌ Missing 'invoke' import from @tauri-apps/api/core"
        fi
        
        # Count exported functions
        ts_func_count=$(grep -cE "^export\s+(async\s+)?function" "$plugin_path/guest-js/index.ts" 2>/dev/null || echo "0")
        cmd_func_count=$(grep -cE "^\s*pub\s*(async\s+)?fn\s+" "$plugin_path/src/commands.rs" 2>/dev/null || echo "0")
        
        if [ "$ts_func_count" -ne "$cmd_func_count" ]; then
            echo "- ⚠️  Function count mismatch: $ts_func_count TS exports vs $cmd_func_count Rust commands"
        else
            echo "- ✅ Function count matches"
        fi
    fi
    
    echo ""
    echo "---"
    echo ""
}

# Check each iOS plugin
for plugin in "$PLUGIN_DIR"/tauri-plugin-ios-*/; do
    if [ -d "$plugin" ]; then
        check_plugin "$plugin"
    fi
done