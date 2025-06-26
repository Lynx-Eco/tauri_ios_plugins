#!/usr/bin/env python3
"""
Fix CoreMotion type ambiguity issues in Swift files.
This script adds explicit type annotations to CoreMotion closure parameters.
"""

import re
import os
from pathlib import Path

# Define patterns for each CoreMotion method and their corresponding types
COREMOTION_PATTERNS = [
    # Accelerometer
    {
        'pattern': r'(motionManager\.startAccelerometerUpdates\(to:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+),\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (data: CMAccelerometerData?, error: Error?) \5',
        'description': 'startAccelerometerUpdates'
    },
    # Gyroscope
    {
        'pattern': r'(motionManager\.startGyroUpdates\(to:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+),\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (data: CMGyroData?, error: Error?) \5',
        'description': 'startGyroUpdates'
    },
    # Magnetometer
    {
        'pattern': r'(motionManager\.startMagnetometerUpdates\(to:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+),\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (data: CMMagnetometerData?, error: Error?) \5',
        'description': 'startMagnetometerUpdates'
    },
    # Device Motion
    {
        'pattern': r'(motionManager\.startDeviceMotionUpdates\(to:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+),\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (data: CMDeviceMotion?, error: Error?) \5',
        'description': 'startDeviceMotionUpdates'
    },
    # Activity Manager (different signature - only one parameter)
    {
        'pattern': r'(activityManager\.startActivityUpdates\(to:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (activity: CMMotionActivity?) \4',
        'description': 'startActivityUpdates'
    },
    # Pedometer
    {
        'pattern': r'(pedometer\.startUpdates\(from:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+),\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (data: CMPedometerData?, error: Error?) \5',
        'description': 'startUpdates (pedometer)'
    },
    # Altimeter
    {
        'pattern': r'(altimeter\.startRelativeAltitudeUpdates\(to:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+),\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (data: CMAltitudeData?, error: Error?) \5',
        'description': 'startRelativeAltitudeUpdates'
    },
    # Query methods with different patterns
    {
        'pattern': r'(activityManager\.queryActivityStarting\(from:.*?to:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+),\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (activities: [CMMotionActivity]?, error: Error?) \5',
        'description': 'queryActivityStarting'
    },
    {
        'pattern': r'(pedometer\.queryPedometerData\(from:.*?to:\s*[^)]+\)\s*\{)(\s*\[[^\]]*\])?\s*(\w+),\s*(\w+)\s*(in)',
        'replacement': r'\1\2 (data: CMPedometerData?, error: Error?) \5',
        'description': 'queryPedometerData'
    }
]

def fix_swift_file(file_path):
    """Fix type ambiguity issues in a Swift file."""
    print(f"\nProcessing: {file_path}")
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    original_content = content
    changes_made = []
    
    for pattern_info in COREMOTION_PATTERNS:
        pattern = pattern_info['pattern']
        replacement = pattern_info['replacement']
        description = pattern_info['description']
        
        # Check if pattern exists in file
        matches = re.findall(pattern, content)
        if matches:
            # Apply the fix
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                content = new_content
                changes_made.append(f"  - Fixed {description} ({len(matches)} occurrence(s))")
    
    # Check for already typed closures to avoid double-typing
    already_typed_patterns = [
        r'(data:\s*CM\w+Data\?)',
        r'(error:\s*Error\?)',
        r'(activity:\s*CMMotionActivity\?)',
        r'(activities:\s*\[CMMotionActivity\]\?)'
    ]
    
    for pattern in already_typed_patterns:
        if re.search(pattern, content):
            print(f"  Note: Some closures already have type annotations")
            break
    
    if content != original_content:
        # Write the fixed content back
        with open(file_path, 'w') as f:
            f.write(content)
        
        print(f"  Fixed {len(changes_made)} type ambiguity issue(s):")
        for change in changes_made:
            print(change)
        return True
    else:
        print("  No type ambiguity issues found or all are already fixed")
        return False

def find_swift_files(root_dir):
    """Find all Swift files in the project."""
    swift_files = []
    for path in Path(root_dir).rglob('*.swift'):
        # Skip build directories and generated files
        if any(skip in str(path) for skip in ['/build/', '/.build/', '/DerivedData/', '.swiftpm']):
            continue
        swift_files.append(path)
    return swift_files

def main():
    """Main function to fix CoreMotion type ambiguity issues."""
    print("CoreMotion Type Ambiguity Fixer")
    print("================================")
    
    # Find the project root (current directory)
    project_root = os.getcwd()
    print(f"Project root: {project_root}")
    
    # Find all Swift files
    swift_files = find_swift_files(project_root)
    print(f"\nFound {len(swift_files)} Swift file(s)")
    
    # Filter for files that might use CoreMotion
    coremotion_files = []
    for file_path in swift_files:
        with open(file_path, 'r') as f:
            content = f.read()
            if 'CoreMotion' in content or 'CMMotion' in content or 'CMAltimeter' in content:
                coremotion_files.append(file_path)
    
    print(f"Found {len(coremotion_files)} file(s) using CoreMotion")
    
    if not coremotion_files:
        print("\nNo files using CoreMotion found.")
        return
    
    # Process each file
    fixed_count = 0
    for file_path in coremotion_files:
        if fix_swift_file(file_path):
            fixed_count += 1
    
    print(f"\n{'='*50}")
    print(f"Summary: Fixed type ambiguity in {fixed_count} file(s)")
    
    if fixed_count > 0:
        print("\nRecommendations:")
        print("1. Build the project to verify the fixes")
        print("2. Test on a physical iOS device (simulators don't support all sensors)")
        print("3. Check that all sensor data is properly received")
        print("\nNote: If you still see type ambiguity errors, they might be in different patterns")
        print("      not covered by this script. Please check COREMOTION_TYPE_AMBIGUITY_ANALYSIS.md")

if __name__ == "__main__":
    main()