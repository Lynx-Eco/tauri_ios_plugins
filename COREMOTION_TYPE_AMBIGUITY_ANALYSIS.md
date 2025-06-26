# CoreMotion Type Ambiguity Analysis

## Issue Description
Swift compiler reports "type of expression is ambiguous without a type annotation" for CoreMotion update methods that take closures as parameters.

## Affected Methods
- `motionManager.startAccelerometerUpdates(to:withHandler:)`
- `motionManager.startGyroUpdates(to:withHandler:)`
- `activityManager.startActivityUpdates(to:withHandler:)`
- `pedometer.startUpdates(from:withHandler:)`
- `altimeter.startRelativeAltitudeUpdates(to:withHandler:)`

## Root Causes of Type Ambiguity

### 1. Closure Parameter Type Inference
The Swift compiler struggles to infer the types of closure parameters when:
- The closure has optional parameters (data and error)
- The closure returns Void
- Multiple overloads exist for the method

### 2. Optional Types in Closures
CoreMotion handlers typically have signatures like:
```swift
(CMAccelerometerData?, Error?) -> Void
(CMGyroData?, Error?) -> Void
(CMMotionActivity?) -> Void  // Note: No error parameter
(CMPedometerData?, Error?) -> Void
(CMAltitudeData?, Error?) -> Void
```

The mix of optional types and different parameter counts can confuse type inference.

### 3. OperationQueue Type
Even when explicitly typing the queue as `OperationQueue`, Swift may have trouble with:
```swift
let queue: OperationQueue = OperationQueue.main
// vs
let queue = OperationQueue.main
```

## Solutions

### Solution 1: Explicit Closure Type Annotation
```swift
// Instead of:
motionManager.startAccelerometerUpdates(to: queue) { data, error in
    // ...
}

// Use:
motionManager.startAccelerometerUpdates(to: queue) { (data: CMAccelerometerData?, error: Error?) in
    // ...
}
```

### Solution 2: Separate Closure Declaration
```swift
let handler: (CMAccelerometerData?, Error?) -> Void = { data, error in
    // Handle the data
}
motionManager.startAccelerometerUpdates(to: queue, withHandler: handler)
```

### Solution 3: Use Trailing Closure with Type Annotation
```swift
motionManager.startAccelerometerUpdates(to: queue, withHandler: { (data: CMAccelerometerData?, error: Error?) -> Void in
    // Handle the data
})
```

### Solution 4: For Methods with Single Parameter (like CMMotionActivity)
```swift
// Note: startActivityUpdates has a different signature - only one parameter
activityManager.startActivityUpdates(to: queue) { (activity: CMMotionActivity?) in
    // Handle activity
}
```

## Current Implementation Analysis

Looking at the existing code in the project:

### MotionPlugin.swift (Lines 135, 175, 215, 255, 364, 423, 514, 542)
The code uses implicit type inference:
```swift
motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
    // ...
}
```

### BarometerPlugin.swift (Lines 82, 116, 210, 250)
Similar pattern:
```swift
altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
    // ...
}
```

## Recommended Fix

To resolve the type ambiguity, modify all CoreMotion update method calls to include explicit type annotations:

### For Accelerometer:
```swift
motionManager.startAccelerometerUpdates(to: queue) { [weak self] (data: CMAccelerometerData?, error: Error?) in
    // existing code
}
```

### For Gyroscope:
```swift
motionManager.startGyroUpdates(to: queue) { [weak self] (data: CMGyroData?, error: Error?) in
    // existing code
}
```

### For Activity Manager (Different signature!):
```swift
activityManager.startActivityUpdates(to: queue) { [weak self] (activity: CMMotionActivity?) in
    // existing code
}
```

### For Pedometer:
```swift
pedometer.startUpdates(from: startDate) { [weak self] (data: CMPedometerData?, error: Error?) in
    // existing code
}
```

### For Altimeter:
```swift
altimeter.startRelativeAltitudeUpdates(to: queue) { [weak self] (data: CMAltitudeData?, error: Error?) in
    // existing code
}
```

## Special Cases

### 1. CMMotionActivityManager
This API has a unique signature without an error parameter:
```swift
func startActivityUpdates(to queue: OperationQueue, withHandler handler: @escaping CMMotionActivityHandler)
// where CMMotionActivityHandler = (CMMotionActivity?) -> Void
```

### 2. CMPedometer
Uses `from:` instead of `to:` for the first parameter:
```swift
func startUpdates(from start: Date, withHandler handler: @escaping CMPedometerHandler)
```

## Additional Considerations

1. **Swift Version**: Different Swift versions may have different type inference capabilities
2. **Xcode Version**: The IDE's error reporting may vary
3. **Build Settings**: Strict type checking settings can affect this
4. **Module Imports**: Ensure `import CoreMotion` is properly declared

## Testing the Fix

After applying explicit type annotations, test each sensor individually:
1. Build the project
2. Run on a physical iOS device (simulators don't support all sensors)
3. Verify no runtime crashes
4. Check that data is properly received in the handlers