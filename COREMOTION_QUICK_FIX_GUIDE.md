# Quick Fix Guide for CoreMotion Type Ambiguity

## Overview
The Swift compiler cannot infer the types of closure parameters in CoreMotion API calls. This guide shows the exact changes needed.

## Files to Fix

### 1. `/plugins/tauri-plugin-ios-motion/ios/Sources/MotionPlugin.swift`

**Line 135** - startAccelerometerUpdates:
```swift
// Change from:
motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in

// To:
motionManager.startAccelerometerUpdates(to: queue) { [weak self] (data: CMAccelerometerData?, error: Error?) in
```

**Line 175** - startGyroUpdates:
```swift
// Change from:
motionManager.startGyroUpdates(to: queue) { [weak self] data, error in

// To:
motionManager.startGyroUpdates(to: queue) { [weak self] (data: CMGyroData?, error: Error?) in
```

**Line 215** - startMagnetometerUpdates:
```swift
// Change from:
motionManager.startMagnetometerUpdates(to: queue) { [weak self] data, error in

// To:
motionManager.startMagnetometerUpdates(to: queue) { [weak self] (data: CMMagnetometerData?, error: Error?) in
```

**Line 255** - startDeviceMotionUpdates:
```swift
// Change from:
motionManager.startDeviceMotionUpdates(to: queue) { [weak self] data, error in

// To:
motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (data: CMDeviceMotion?, error: Error?) in
```

**Line 338** - queryActivityStarting (first occurrence):
```swift
// Change from:
to: queue) { [weak self] activities, error in

// To:
to: queue) { [weak self] (activities: [CMMotionActivity]?, error: Error?) in
```

**Line 364** - startActivityUpdates (SPECIAL - single parameter):
```swift
// Change from:
activityManager.startActivityUpdates(to: queue) { [weak self] activity in

// To:
activityManager.startActivityUpdates(to: queue) { [weak self] (activity: CMMotionActivity?) in
```

**Line 405** - queryActivityStarting (second occurrence):
```swift
// Change from:
to: queue) { [weak self] activities, error in

// To:
to: queue) { [weak self] (activities: [CMMotionActivity]?, error: Error?) in
```

**Line 423** - pedometer startUpdates:
```swift
// Change from:
pedometer.startUpdates(from: startDate) { [weak self] data, error in

// To:
pedometer.startUpdates(from: startDate) { [weak self] (data: CMPedometerData?, error: Error?) in
```

**Line 472** - queryPedometerData:
```swift
// Change from:
pedometer.queryPedometerData(from: startDate, to: endDate) { [weak self] data, error in

// To:
pedometer.queryPedometerData(from: startDate, to: endDate) { [weak self] (data: CMPedometerData?, error: Error?) in
```

**Line 514** - startRelativeAltitudeUpdates (first occurrence):
```swift
// Change from:
altimeter.startRelativeAltitudeUpdates(to: queue) { [weak self] data, error in

// To:
altimeter.startRelativeAltitudeUpdates(to: queue) { [weak self] (data: CMAltitudeData?, error: Error?) in
```

**Line 542** - startRelativeAltitudeUpdates (second occurrence):
```swift
// Change from:
altimeter.startRelativeAltitudeUpdates(to: queue) { [weak self] data, error in

// To:
altimeter.startRelativeAltitudeUpdates(to: queue) { [weak self] (data: CMAltitudeData?, error: Error?) in
```

### 2. `/plugins/tauri-plugin-ios-barometer/ios/Sources/BarometerPlugin.swift`

**Line 82** - startRelativeAltitudeUpdates:
```swift
// Change from:
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in

// To:
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] (data: CMAltitudeData?, error: Error?) in
```

**Line 116** - startRelativeAltitudeUpdates:
```swift
// Change from:
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in

// To:
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] (data: CMAltitudeData?, error: Error?) in
```

**Line 210** - startRelativeAltitudeUpdates:
```swift
// Change from:
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in

// To:
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] (data: CMAltitudeData?, error: Error?) in
```

**Line 250** - startRelativeAltitudeUpdates:
```swift
// Change from:
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in

// To:
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] (data: CMAltitudeData?, error: Error?) in
```

## Important Notes

1. **CMMotionActivity is Different**: The `startActivityUpdates` method only has ONE parameter (activity), not two (data, error).

2. **Parameter Names Matter**: Make sure to use the exact parameter names as shown above.

3. **Keep [weak self]**: The `[weak self]` capture list should remain where it is - just add the type annotations after it.

4. **Build After Changes**: After making these changes, build the project to ensure all type ambiguity errors are resolved.

## Automated Fix

You can also use the provided Python script:
```bash
python3 fix_coremotion_types.py
```

This will automatically apply all the fixes shown above.