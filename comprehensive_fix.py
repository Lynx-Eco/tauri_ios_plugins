#!/usr/bin/env python3

import os
import subprocess
from pathlib import Path

PLUGIN_DIR = "/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"

# Expected Cargo.toml structure for each plugin
def get_expected_cargo_toml(plugin_name, needs_chrono=False, needs_serde_json=False):
    """Generate the expected Cargo.toml content"""
    description = plugin_name.replace("tauri-plugin-ios-", "").replace("-", " ")
    
    deps = [
        'tauri = { version = "2.5.0" }',
        'serde = "1.0"',
        'thiserror = "2"',
    ]
    
    if needs_serde_json:
        deps.append('serde_json = "1.0"')
    
    if needs_chrono:
        deps.append('chrono = { version = "0.4", features = ["serde"] }')
    
    return f'''[package]
name = "{plugin_name}"
version = "0.1.0"
authors = [ "Tauri Plugin iOS" ]
description = "Access {description} APIs on iOS for Tauri applications"
edition = "2021"
rust-version = "1.77.2"
exclude = ["/examples", "/dist-js", "/guest-js", "/node_modules"]
links = "{plugin_name}"

[dependencies]
{chr(10).join(deps)}

[build-dependencies]
tauri-plugin = {{ version = "2.2.0", features = ["build"] }}
'''

def check_needs_dependency(plugin_path, dep_name):
    """Check if a plugin needs a specific dependency based on its source code"""
    src_path = plugin_path / "src"
    if not src_path.exists():
        return False
    
    for rust_file in src_path.glob("*.rs"):
        with open(rust_file, 'r') as f:
            content = f.read()
            
        if dep_name == "chrono":
            if "DateTime<Utc>" in content or "chrono::" in content:
                return True
        elif dep_name == "serde_json":
            if "serde_json::" in content or "json!" in content:
                return True
    
    return False

def fix_plugin(plugin_path):
    """Fix a single plugin's Cargo.toml"""
    plugin_name = plugin_path.name
    cargo_file = plugin_path / "Cargo.toml"
    
    if not cargo_file.exists():
        return False
    
    # Check what dependencies are needed
    needs_chrono = check_needs_dependency(plugin_path, "chrono")
    needs_serde_json = check_needs_dependency(plugin_path, "serde_json")
    
    # Generate the correct Cargo.toml
    expected_content = get_expected_cargo_toml(plugin_name, needs_chrono, needs_serde_json)
    
    # Write the fixed content
    with open(cargo_file, 'w') as f:
        f.write(expected_content)
    
    return True

def check_compilation(plugin_path):
    """Check if a plugin compiles"""
    try:
        result = subprocess.run(
            ["cargo", "check", "--quiet"],
            cwd=plugin_path,
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.returncode == 0, result.stderr
    except Exception as e:
        return False, str(e)

def main():
    print("=== Comprehensive Fix for iOS Plugins ===\n")
    
    plugins = sorted([d for d in Path(PLUGIN_DIR).iterdir() 
                     if d.is_dir() and d.name.startswith("tauri-plugin-ios-")])
    
    print(f"Found {len(plugins)} iOS plugins to fix\n")
    
    # First pass: Fix all Cargo.toml files
    print("Phase 1: Fixing Cargo.toml files...")
    for plugin_path in plugins:
        if fix_plugin(plugin_path):
            print(f"  ✅ Fixed {plugin_path.name}")
        else:
            print(f"  ❌ Failed to fix {plugin_path.name}")
    
    # Second pass: Check compilation
    print("\nPhase 2: Checking compilation...")
    compilation_results = {}
    
    for plugin_path in plugins:
        print(f"\nChecking {plugin_path.name}...")
        compiles, error = check_compilation(plugin_path)
        compilation_results[plugin_path.name] = (compiles, error)
        
        if compiles:
            print(f"  ✅ Compiles successfully")
        else:
            print(f"  ❌ Compilation failed")
            if error:
                # Show first few lines of error
                error_lines = error.strip().split('\n')[:5]
                for line in error_lines:
                    print(f"     {line}")
                if len(error.strip().split('\n')) > 5:
                    print("     ...")
    
    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    
    successful = sum(1 for _, (compiles, _) in compilation_results.items() if compiles)
    failed = len(compilation_results) - successful
    
    print(f"\n✅ Successfully compiling: {successful}/{len(compilation_results)}")
    print(f"❌ Still failing: {failed}/{len(compilation_results)}")
    
    if failed > 0:
        print("\nPlugins still failing:")
        for plugin_name, (compiles, error) in compilation_results.items():
            if not compiles:
                print(f"  - {plugin_name}")

if __name__ == "__main__":
    main()