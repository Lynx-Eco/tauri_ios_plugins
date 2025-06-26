#!/usr/bin/env python3

import os
import re
from pathlib import Path

PLUGIN_DIR = "/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"

# Plugins that need chrono
chrono_plugins = [
    "tauri-plugin-ios-barometer",
    "tauri-plugin-ios-bluetooth",
    "tauri-plugin-ios-files",
    "tauri-plugin-ios-messages",
    "tauri-plugin-ios-motion",
    "tauri-plugin-ios-proximity",
    "tauri-plugin-ios-screentime",
    "tauri-plugin-ios-widgets"
]

# Plugins that need serde_json
serde_json_plugins = [
    "tauri-plugin-ios-barometer",
    "tauri-plugin-ios-bluetooth",
    "tauri-plugin-ios-location",
    "tauri-plugin-ios-microphone",
    "tauri-plugin-ios-motion",
    "tauri-plugin-ios-photos",
    "tauri-plugin-ios-shortcuts",
    "tauri-plugin-ios-widgets"
]

def fix_cargo_toml(file_path, dependencies_to_add):
    """Fix Cargo.toml by adding missing dependencies"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Find the [dependencies] section
    deps_match = re.search(r'\[dependencies\]\n((?:.*\n)*?)(?=\n\[|$)', content, re.MULTILINE)
    
    if deps_match:
        deps_section = deps_match.group(1)
        deps_start = deps_match.start(1)
        deps_end = deps_match.end(1)
        
        new_deps = []
        for dep_name, dep_spec in dependencies_to_add.items():
            # Check if dependency already exists
            if not re.search(f'^{dep_name}\\s*=', deps_section, re.MULTILINE):
                new_deps.append(f'{dep_name} = {dep_spec}')
        
        if new_deps:
            # Add new dependencies
            new_deps_str = '\n'.join(new_deps) + '\n'
            new_content = content[:deps_end] + new_deps_str + content[deps_end:]
            
            with open(file_path, 'w') as f:
                f.write(new_content)
            
            return True
    return False

def main():
    print("=== Fixing Missing Dependencies in iOS Plugins ===\n")
    
    fixed_count = 0
    
    # Fix chrono dependencies
    print("Fixing chrono dependencies...")
    for plugin in chrono_plugins:
        cargo_file = os.path.join(PLUGIN_DIR, plugin, "Cargo.toml")
        if os.path.exists(cargo_file):
            if fix_cargo_toml(cargo_file, {"chrono": '{ version = "0.4", features = ["serde"] }'}):
                print(f"  ✅ Added chrono to {plugin}")
                fixed_count += 1
    
    # Fix serde_json dependencies
    print("\nFixing serde_json dependencies...")
    for plugin in serde_json_plugins:
        cargo_file = os.path.join(PLUGIN_DIR, plugin, "Cargo.toml")
        if os.path.exists(cargo_file):
            if fix_cargo_toml(cargo_file, {"serde_json": '"1.0"'}):
                print(f"  ✅ Added serde_json to {plugin}")
                fixed_count += 1
    
    print(f"\n✅ Fixed {fixed_count} dependency issues!")
    
    # Check for any malformed Cargo.toml files from previous attempt
    print("\nChecking for malformed Cargo.toml files...")
    for plugin_path in Path(PLUGIN_DIR).glob("tauri-plugin-ios-*/"):
        cargo_file = plugin_path / "Cargo.toml"
        if cargo_file.exists():
            with open(cargo_file, 'r') as f:
                content = f.read()
            
            # Look for lines where dependencies got concatenated
            if re.search(r'^\w+ = .*\w+ = ', content, re.MULTILINE):
                print(f"  ⚠️  Found malformed dependencies in {plugin_path.name}, fixing...")
                
                # Fix the malformed line
                lines = content.split('\n')
                fixed_lines = []
                for line in lines:
                    # Check if this is a malformed dependency line
                    if '=' in line and line.strip() and not line.strip().startswith('['):
                        # Split multiple dependencies on same line
                        parts = re.findall(r'(\w+)\s*=\s*([^=]+?)(?=\w+\s*=|$)', line)
                        if len(parts) > 1:
                            for name, value in parts:
                                fixed_lines.append(f"{name} = {value.strip()}")
                        else:
                            fixed_lines.append(line)
                    else:
                        fixed_lines.append(line)
                
                with open(cargo_file, 'w') as f:
                    f.write('\n'.join(fixed_lines))
                print(f"    ✅ Fixed {plugin_path.name}")

if __name__ == "__main__":
    main()