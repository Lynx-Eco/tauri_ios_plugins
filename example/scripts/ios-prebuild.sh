#!/bin/bash

# This script ensures assets are properly copied for iOS builds

echo "Copying assets for iOS build..."

# Ensure the assets directory exists
mkdir -p src-tauri/gen/apple/assets

# Copy the dist folder contents to the iOS assets folder
cp -r dist/* src-tauri/gen/apple/assets/

echo "Assets copied successfully!"

# List the contents to verify
echo "Contents of src-tauri/gen/apple/assets/:"
ls -la src-tauri/gen/apple/assets/