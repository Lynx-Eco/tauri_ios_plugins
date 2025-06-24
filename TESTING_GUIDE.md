# Tauri iOS Plugins Testing Guide

## Quick Start

The example app in `/example` is fully configured to test all 18 iOS plugins.

### 1. Test on Desktop (Quick Verification)

```bash
cd example
pnpm install
pnpm tauri dev
```

- All plugins should return "Not supported on desktop" errors
- Verifies the error handling works correctly

### 2. Test on iOS Simulator

```bash
# First time setup
pnpm tauri ios init

# Run on simulator
pnpm tauri ios dev
```

- Opens iOS Simulator with the test app
- Most plugins work with some limitations
- Good for development and debugging

### 3. Test on Physical Device

```bash
# Open in Xcode
open src-tauri/gen/apple/example.xcodeproj
```

1. Connect your iPhone/iPad
2. Select your device as target
3. Configure code signing
4. Build and run (⌘R)

## What to Test

The example app provides a comprehensive UI with:

- **Run All Tests** button - Tests all plugins automatically
- **Individual plugin buttons** - Test specific plugins
- **Real-time results** - Shows success/failure with details
- **Filter dropdown** - View results by plugin

## Expected Results

### Desktop
✗ All plugins return "Not supported on desktop"

### iOS Simulator
✓ Most plugins work with limitations:
- Camera: UI only, no real capture
- Sensors: Limited or unavailable
- Contacts/Photos: Test data only

### Physical Device
✓ Full functionality:
- Real sensor data
- Actual permissions dialogs
- Access to user data (with permission)

## Verification Checklist

- [ ] Workspace builds: `cargo build --workspace`
- [ ] Desktop shows proper error messages
- [ ] iOS Simulator runs without crashes
- [ ] Permission dialogs appear correctly
- [ ] API calls return expected data
- [ ] Events fire properly (for plugins with events)
- [ ] No memory leaks with repeated calls
- [ ] Proper cleanup when stopping monitors

## Common Commands

```bash
# Build everything
cargo build --workspace

# Run desktop tests
cd example && pnpm tauri dev

# Run iOS simulator
cd example && pnpm tauri ios dev

# Check for issues
cargo clippy --all

# View documentation
cargo doc --no-deps --open
```

## Debugging

### Console Logs
- **JavaScript**: Safari Web Inspector (Develop menu)
- **Native iOS**: Xcode console
- **Rust**: Terminal output

### Permission Issues
Settings > Privacy & Security > [Permission Type] > Enable for test app

### Build Issues
```bash
cargo clean
rm -rf example/src-tauri/target
pnpm tauri ios init --reinstall-deps
```

## Success Criteria

1. ✓ All plugins compile without errors
2. ✓ Desktop returns appropriate errors
3. ✓ iOS Simulator shows basic functionality
4. ✓ Physical device accesses real data/sensors
5. ✓ Permission handling works correctly
6. ✓ No crashes or memory leaks

The plugins are ready for use when all criteria are met!