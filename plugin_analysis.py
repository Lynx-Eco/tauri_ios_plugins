#!/usr/bin/env python3

import os
import re
import subprocess
from pathlib import Path

PLUGIN_DIR = "/Users/user/dev/test/claude_code/tauri_ios_plugins/plugins"

def check_missing_dependencies(plugin_path):
    """Check for missing dependencies based on code usage"""
    issues = []
    
    # Read all Rust source files
    src_content = ""
    src_path = os.path.join(plugin_path, "src")
    if os.path.exists(src_path):
        for file in Path(src_path).glob("*.rs"):
            with open(file, 'r') as f:
                src_content += f.read()
    
    # Read Cargo.toml
    cargo_path = os.path.join(plugin_path, "Cargo.toml")
    cargo_content = ""
    if os.path.exists(cargo_path):
        with open(cargo_path, 'r') as f:
            cargo_content = f.read()
    
    # Check for chrono
    if ("DateTime<Utc>" in src_content or "chrono::" in src_content) and "chrono" not in cargo_content:
        issues.append("chrono")
    
    # Check for serde_json
    if ("serde_json::" in src_content or "json!" in src_content) and "serde_json" not in cargo_content:
        issues.append("serde_json")
    
    # Check for uuid
    if "Uuid" in src_content and "uuid" not in cargo_content and "type Uuid = String" not in src_content:
        issues.append("uuid")
    
    return issues

def extract_functions(file_path, include_crate_visibility=False):
    """Extract function names from a Rust file"""
    functions = []
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            content = f.read()
            # Match public functions (including pub(crate) if specified)
            if include_crate_visibility:
                pattern = r'^\s*pub(?:\(crate\))?\s+(?:async\s+)?fn\s+([a-zA-Z0-9_]+)'
            else:
                pattern = r'^\s*pub\s+(?:async\s+)?fn\s+([a-zA-Z0-9_]+)'
            functions = re.findall(pattern, content, re.MULTILINE)
    return functions

def check_command_implementation(plugin_path):
    """Compare commands.rs and mobile.rs functions"""
    commands_file = os.path.join(plugin_path, "src", "commands.rs")
    mobile_file = os.path.join(plugin_path, "src", "mobile.rs")
    
    commands_funcs = set(extract_functions(commands_file, include_crate_visibility=True))
    mobile_funcs = set(extract_functions(mobile_file))
    
    missing = commands_funcs - mobile_funcs
    return list(missing)

def check_typescript_bindings(plugin_path):
    """Check TypeScript bindings"""
    issues = []
    ts_file = os.path.join(plugin_path, "guest-js", "index.ts")
    commands_file = os.path.join(plugin_path, "src", "commands.rs")
    
    if os.path.exists(ts_file):
        with open(ts_file, 'r') as f:
            ts_content = f.read()
            
        # Check for invoke import
        if "import" in ts_content and "invoke" in ts_content and "@tauri-apps/api" in ts_content:
            pass
        else:
            issues.append("Missing 'invoke' import from @tauri-apps/api/core")
        
        # Count functions
        ts_func_count = len(re.findall(r'^export\s+(?:async\s+)?function', ts_content, re.MULTILINE))
        cmd_func_count = len(extract_functions(commands_file, include_crate_visibility=True))
        
        if ts_func_count != cmd_func_count:
            issues.append(f"Function count mismatch: {ts_func_count} TS exports vs {cmd_func_count} Rust commands")
    
    return issues

def check_compilation(plugin_path):
    """Check if the plugin compiles"""
    try:
        result = subprocess.run(
            ["cargo", "check", "--quiet"],
            cwd=plugin_path,
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.returncode == 0
    except:
        return False

def analyze_plugins():
    """Analyze all iOS plugins"""
    results = {}
    
    # Get all iOS plugins
    plugins = [d for d in os.listdir(PLUGIN_DIR) if d.startswith("tauri-plugin-ios-") and os.path.isdir(os.path.join(PLUGIN_DIR, d))]
    plugins.sort()
    
    print(f"Found {len(plugins)} iOS plugins to analyze\n")
    
    for plugin in plugins:
        plugin_path = os.path.join(PLUGIN_DIR, plugin)
        print(f"Analyzing {plugin}...")
        
        results[plugin] = {
            "missing_deps": check_missing_dependencies(plugin_path),
            "missing_mobile_impl": check_command_implementation(plugin_path),
            "ts_issues": check_typescript_bindings(plugin_path),
            "compiles": check_compilation(plugin_path)
        }
    
    return results

def print_summary(results):
    """Print analysis summary"""
    print("\n" + "="*80)
    print("SUMMARY OF ISSUES")
    print("="*80 + "\n")
    
    total_issues = 0
    plugins_with_issues = 0
    
    for plugin, issues in results.items():
        has_issues = False
        issue_list = []
        
        if issues["missing_deps"]:
            has_issues = True
            issue_list.append(f"Missing dependencies: {', '.join(issues['missing_deps'])}")
        
        if issues["missing_mobile_impl"]:
            has_issues = True
            issue_list.append(f"Missing mobile.rs implementations: {', '.join(issues['missing_mobile_impl'])}")
        
        if issues["ts_issues"]:
            has_issues = True
            for ts_issue in issues["ts_issues"]:
                issue_list.append(f"TypeScript: {ts_issue}")
        
        if not issues["compiles"]:
            has_issues = True
            issue_list.append("Compilation failed")
        
        if has_issues:
            plugins_with_issues += 1
            total_issues += len(issue_list)
            print(f"## {plugin}")
            for issue in issue_list:
                print(f"  - ❌ {issue}")
            print()
    
    # Print plugins without issues
    print("\n## Plugins without issues:")
    for plugin, issues in results.items():
        if not any([issues["missing_deps"], issues["missing_mobile_impl"], issues["ts_issues"], not issues["compiles"]]):
            print(f"  - ✅ {plugin}")
    
    print(f"\n{'='*80}")
    print(f"Total: {plugins_with_issues}/{len(results)} plugins have issues")
    print(f"Total issues found: {total_issues}")
    print("="*80)

if __name__ == "__main__":
    results = analyze_plugins()
    print_summary(results)