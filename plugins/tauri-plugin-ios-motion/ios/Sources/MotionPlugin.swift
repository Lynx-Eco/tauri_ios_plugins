import Tauri
import UIKit
import CoreMotion

struct AccelerometerData: Codable {
    let x: Double
    let y: Double
    let z: Double
    let timestamp: String
}

struct GyroscopeData: Codable {
    let x: Double
    let y: Double
    let z: Double
    let timestamp: String
}

struct MagnetometerData: Codable {
    let x: Double
    let y: Double
    let z: Double
    let accuracy: String
    let timestamp: String
}

struct Vector3D: Codable {
    let x: Double
    let y: Double
    let z: Double
}

struct Quaternion: Codable {
    let x: Double
    let y: Double
    let z: Double
    let w: Double
}

struct RotationMatrix: Codable {
    let m11: Double
    let m12: Double
    let m13: Double
    let m21: Double
    let m22: Double
    let m23: Double
    let m31: Double
    let m32: Double
    let m33: Double
}

struct Attitude: Codable {
    let roll: Double
    let pitch: Double
    let yaw: Double
    let rotationMatrix: RotationMatrix
    let quaternion: Quaternion
}

struct CalibratedMagneticField: Codable {
    let field: Vector3D
    let accuracy: String
}

struct DeviceMotionData: Codable {
    let attitude: Attitude
    let rotationRate: Vector3D
    let gravity: Vector3D
    let userAcceleration: Vector3D
    let magneticField: CalibratedMagneticField?
    let heading: Double?
    let timestamp: String
}

struct MotionActivity: Codable {
    let stationary: Bool
    let walking: Bool
    let running: Bool
    let automotive: Bool
    let cycling: Bool
    let unknown: Bool
    let startDate: String
    let confidence: String
}

struct PedometerData: Codable {
    let startDate: String
    let endDate: String
    let numberOfSteps: Int
    let distance: Double?
    let floorsAscended: Int?
    let floorsDescended: Int?
    let currentPace: Double?
    let currentCadence: Double?
    let averageActivePace: Double?
}

struct AltimeterData: Codable {
    let relativeAltitude: Double
    let pressure: Double
    let timestamp: String
}

struct MotionUpdateInterval: Codable {
    let accelerometer: Double?
    let gyroscope: Double?
    let magnetometer: Double?
    let deviceMotion: Double?
}

struct ActivityQuery: Codable {
    let startDate: String
    let endDate: String
}

class MotionPlugin: Plugin {
    private let motionManager = CMMotionManager()
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private let altimeter = CMAltimeter()
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    @objc public func startAccelerometerUpdates(_ invoke: Invoke) {
        guard motionManager.isAccelerometerAvailable else {
            invoke.reject("Accelerometer not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        motionManager.startAccelerometerUpdates(to: queue, withHandler: { [weak self] data, error in
            if let error = error {
                self?.trigger("motionError", data: ["eventType": "error", "data": error.localizedDescription])
                return
            }
            
            if let data = data {
                if let accelData = self?.accelerometerDataFromCM(data) {
                    self?.trigger("motionUpdate", data: [
                        "eventType": "accelerometerUpdate",
                        "data": accelData
                    ])
                }
            }
        })
        
        invoke.resolve()
    }
    
    @objc public func stopAccelerometerUpdates(_ invoke: Invoke) {
        motionManager.stopAccelerometerUpdates()
        invoke.resolve()
    }
    
    @objc public func getAccelerometerData(_ invoke: Invoke) {
        guard let data = motionManager.accelerometerData else {
            invoke.reject("No accelerometer data available")
            return
        }
        
        invoke.resolve(accelerometerDataFromCM(data))
    }
    
    @objc public func startGyroscopeUpdates(_ invoke: Invoke) {
        guard motionManager.isGyroAvailable else {
            invoke.reject("Gyroscope not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        motionManager.startGyroUpdates(to: queue, withHandler: { [weak self] data, error in
            if let error = error {
                self?.trigger("motionError", data: ["eventType": "error", "data": error.localizedDescription])
                return
            }
            
            if let data = data {
                if let gyroData = self?.gyroscopeDataFromCM(data) {
                    self?.trigger("motionUpdate", data: [
                        "eventType": "gyroscopeUpdate",
                        "data": gyroData
                    ])
                }
            }
        })
        
        invoke.resolve()
    }
    
    @objc public func stopGyroscopeUpdates(_ invoke: Invoke) {
        motionManager.stopGyroUpdates()
        invoke.resolve()
    }
    
    @objc public func getGyroscopeData(_ invoke: Invoke) {
        guard let data = motionManager.gyroData else {
            invoke.reject("No gyroscope data available")
            return
        }
        
        invoke.resolve(gyroscopeDataFromCM(data))
    }
    
    @objc public func startMagnetometerUpdates(_ invoke: Invoke) {
        guard motionManager.isMagnetometerAvailable else {
            invoke.reject("Magnetometer not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        motionManager.startMagnetometerUpdates(to: queue, withHandler: { [weak self] data, error in
            if let error = error {
                self?.trigger("motionError", data: ["eventType": "error", "data": error.localizedDescription])
                return
            }
            
            if let data = data {
                if let magData = self?.magnetometerDataFromCM(data) {
                    self?.trigger("motionUpdate", data: [
                        "eventType": "magnetometerUpdate",
                        "data": magData
                    ])
                }
            }
        })
        
        invoke.resolve()
    }
    
    @objc public func stopMagnetometerUpdates(_ invoke: Invoke) {
        motionManager.stopMagnetometerUpdates()
        invoke.resolve()
    }
    
    @objc public func getMagnetometerData(_ invoke: Invoke) {
        guard let data = motionManager.magnetometerData else {
            invoke.reject("No magnetometer data available")
            return
        }
        
        invoke.resolve(magnetometerDataFromCM(data))
    }
    
    @objc public func startDeviceMotionUpdates(_ invoke: Invoke) {
        guard motionManager.isDeviceMotionAvailable else {
            invoke.reject("Device motion not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        motionManager.startDeviceMotionUpdates(to: queue, withHandler: { [weak self] data, error in
            if let error = error {
                self?.trigger("motionError", data: ["eventType": "error", "data": error.localizedDescription])
                return
            }
            
            if let data = data {
                if let deviceData = self?.deviceMotionDataFromCM(data) {
                    self?.trigger("motionUpdate", data: [
                        "eventType": "deviceMotionUpdate",
                        "data": deviceData
                    ])
                }
            }
        })
        
        invoke.resolve()
    }
    
    @objc public func stopDeviceMotionUpdates(_ invoke: Invoke) {
        motionManager.stopDeviceMotionUpdates()
        invoke.resolve()
    }
    
    @objc public func getDeviceMotionData(_ invoke: Invoke) {
        guard let data = motionManager.deviceMotion else {
            invoke.reject("No device motion data available")
            return
        }
        
        invoke.resolve(deviceMotionDataFromCM(data))
    }
    
    @objc public func setUpdateInterval(_ invoke: Invoke) {
        let intervals: MotionUpdateInterval
        do {
            intervals = try invoke.parseArgs(MotionUpdateInterval.self)
        } catch {
            invoke.reject("Invalid update intervals")
            return
        }
        
        if let accel = intervals.accelerometer {
            motionManager.accelerometerUpdateInterval = accel
        }
        if let gyro = intervals.gyroscope {
            motionManager.gyroUpdateInterval = gyro
        }
        if let mag = intervals.magnetometer {
            motionManager.magnetometerUpdateInterval = mag
        }
        if let device = intervals.deviceMotion {
            motionManager.deviceMotionUpdateInterval = device
        }
        
        invoke.resolve()
    }
    
    @objc public func isAccelerometerAvailable(_ invoke: Invoke) {
        invoke.resolve(motionManager.isAccelerometerAvailable)
    }
    
    @objc public func isGyroscopeAvailable(_ invoke: Invoke) {
        invoke.resolve(motionManager.isGyroAvailable)
    }
    
    @objc public func isMagnetometerAvailable(_ invoke: Invoke) {
        invoke.resolve(motionManager.isMagnetometerAvailable)
    }
    
    @objc public func isDeviceMotionAvailable(_ invoke: Invoke) {
        invoke.resolve(motionManager.isDeviceMotionAvailable)
    }
    
    @objc public func getMotionActivity(_ invoke: Invoke) {
        guard CMMotionActivityManager.isActivityAvailable() else {
            invoke.reject("Motion activity not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        activityManager.queryActivityStarting(from: Date(timeIntervalSinceNow: -60),
                                               to: Date(),
                                               to: queue) { [weak self]
            (activities: [CMMotionActivity]?, error: Swift.Error?) in
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            guard let activity = activities?.last else {
                invoke.reject("No activity data available")
                return
            }
            
            if let activityData = self?.motionActivityFromCM(activity) {
                invoke.resolve(activityData)
            } else {
                invoke.reject("Failed to process activity data")
            }
        }
    }
    
    @objc public func startActivityUpdates(_ invoke: Invoke) {
        guard CMMotionActivityManager.isActivityAvailable() else {
            invoke.reject("Motion activity not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        activityManager.startActivityUpdates(to: queue, withHandler: { [weak self] activity in
            if let activity = activity,
               let activityData = self?.motionActivityFromCM(activity) {
                self?.trigger("motionUpdate", data: [
                    "eventType": "activityUpdate",
                    "data": activityData
                ])
            }
        })
        
        invoke.resolve()
    }
    
    @objc public func stopActivityUpdates(_ invoke: Invoke) {
        activityManager.stopActivityUpdates()
        invoke.resolve()
    }
    
    @objc public func queryActivityHistory(_ invoke: Invoke) {
        let query: ActivityQuery
        do {
            query = try invoke.parseArgs(ActivityQuery.self)
        } catch {
            invoke.reject("Invalid query parameters")
            return
        }
        
        guard let startDate = dateFormatter.date(from: query.startDate),
              let endDate = dateFormatter.date(from: query.endDate) else {
            invoke.reject("Invalid date format")
            return
        }
        
        guard CMMotionActivityManager.isActivityAvailable() else {
            invoke.reject("Motion activity not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        activityManager.queryActivityStarting(from: startDate,
                                               to: endDate,
                                               to: queue) { [weak self]
            (activities: [CMMotionActivity]?, error: Swift.Error?) in
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            let activityData = activities?.compactMap { self?.motionActivityFromCM($0) } ?? []
            invoke.resolve(activityData)
        }
    }
    
    @objc public func startPedometerUpdates(_ invoke: Invoke) {
        guard CMPedometer.isStepCountingAvailable() else {
            invoke.reject("Step counting not available")
            return
        }
        
        let startDate = Date()
        pedometer.startUpdates(from: startDate, withHandler: { [weak self] data, error in
            if let error = error {
                self?.trigger("motionError", data: ["eventType": "error", "data": error.localizedDescription])
                return
            }
            
            if let data = data {
                if let pedometerData = self?.pedometerDataFromCM(data, endDate: Date()) {
                    self?.trigger("motionUpdate", data: [
                        "eventType": "pedometerUpdate",
                        "data": pedometerData
                    ])
                }
            }
        })
        
        invoke.resolve()
    }
    
    @objc public func stopPedometerUpdates(_ invoke: Invoke) {
        pedometer.stopUpdates()
        invoke.resolve()
    }
    
    @objc public func getPedometerData(_ invoke: Invoke) {
        struct PedometerQuery: Codable {
            let startDate: String
            let endDate: String
        }
        
        let query: PedometerQuery
        do {
            query = try invoke.parseArgs(PedometerQuery.self)
        } catch {
            invoke.reject("Invalid query parameters")
            return
        }
        
        guard let startDate = dateFormatter.date(from: query.startDate),
              let endDate = dateFormatter.date(from: query.endDate) else {
            invoke.reject("Invalid date format")
            return
        }
        
        guard CMPedometer.isStepCountingAvailable() else {
            invoke.reject("Step counting not available")
            return
        }
        
        pedometer.queryPedometerData(from: startDate, to: endDate) { [weak self]
            (data: CMPedometerData?, error: Swift.Error?) in
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                invoke.reject("No pedometer data available")
                return
            }
            
            if let pedometerData = self?.pedometerDataFromCM(data, endDate: endDate) {
                invoke.resolve(pedometerData)
            } else {
                invoke.reject("Failed to process pedometer data")
            }
        }
    }
    
    @objc public func isPedometerAvailable(_ invoke: Invoke) {
        invoke.resolve(CMPedometer.isPedometerEventTrackingAvailable())
    }
    
    @objc public func isStepCountingAvailable(_ invoke: Invoke) {
        invoke.resolve(CMPedometer.isStepCountingAvailable())
    }
    
    @objc public func isDistanceAvailable(_ invoke: Invoke) {
        invoke.resolve(CMPedometer.isDistanceAvailable())
    }
    
    @objc public func isFloorCountingAvailable(_ invoke: Invoke) {
        invoke.resolve(CMPedometer.isFloorCountingAvailable())
    }
    
    @objc public func getAltimeterData(_ invoke: Invoke) {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            invoke.reject("Relative altitude not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        altimeter.startRelativeAltitudeUpdates(to: queue, withHandler: { [weak self] data, error in
            self?.altimeter.stopRelativeAltitudeUpdates()
            
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                invoke.reject("No altimeter data available")
                return
            }
            
            if let altimeterData = self?.altimeterDataFromCM(data) {
                invoke.resolve(altimeterData)
            } else {
                invoke.reject("Failed to process altimeter data")
            }
        })
    }
    
    @objc public func startAltimeterUpdates(_ invoke: Invoke) {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            invoke.reject("Relative altitude not available")
            return
        }
        
        let queue: OperationQueue = OperationQueue.main
        altimeter.startRelativeAltitudeUpdates(to: queue, withHandler: { [weak self] data, error in
            if let error = error {
                self?.trigger("motionError", data: ["eventType": "error", "data": error.localizedDescription])
                return
            }
            
            if let data = data {
                if let altimeterData = self?.altimeterDataFromCM(data) {
                    self?.trigger("motionUpdate", data: [
                        "eventType": "altimeterUpdate",
                        "data": altimeterData
                    ])
                }
            }
        })
        
        invoke.resolve()
    }
    
    @objc public func stopAltimeterUpdates(_ invoke: Invoke) {
        altimeter.stopRelativeAltitudeUpdates()
        invoke.resolve()
    }
    
    @objc public func isRelativeAltitudeAvailable(_ invoke: Invoke) {
        invoke.resolve(CMAltimeter.isRelativeAltitudeAvailable())
    }
    
    // Helper methods
    private func accelerometerDataFromCM(_ data: CMAccelerometerData) -> AccelerometerData {
        return AccelerometerData(
            x: data.acceleration.x,
            y: data.acceleration.y,
            z: data.acceleration.z,
            timestamp: dateFormatter.string(from: Date(timeIntervalSince1970: data.timestamp))
        )
    }
    
    private func gyroscopeDataFromCM(_ data: CMGyroData) -> GyroscopeData {
        return GyroscopeData(
            x: data.rotationRate.x,
            y: data.rotationRate.y,
            z: data.rotationRate.z,
            timestamp: dateFormatter.string(from: Date(timeIntervalSince1970: data.timestamp))
        )
    }
    
    private func magnetometerDataFromCM(_ data: CMMagnetometerData) -> MagnetometerData {
        // CMMagnetometerData doesn't have accuracy information in the raw magnetometer readings
        // The accuracy is only available in CMDeviceMotion's calibrated magnetic field
        return MagnetometerData(
            x: data.magneticField.x,
            y: data.magneticField.y,
            z: data.magneticField.z,
            accuracy: "unknown",
            timestamp: dateFormatter.string(from: Date(timeIntervalSince1970: data.timestamp))
        )
    }
    
    private func deviceMotionDataFromCM(_ data: CMDeviceMotion) -> DeviceMotionData {
        let attitude = Attitude(
            roll: data.attitude.roll,
            pitch: data.attitude.pitch,
            yaw: data.attitude.yaw,
            rotationMatrix: RotationMatrix(
                m11: data.attitude.rotationMatrix.m11,
                m12: data.attitude.rotationMatrix.m12,
                m13: data.attitude.rotationMatrix.m13,
                m21: data.attitude.rotationMatrix.m21,
                m22: data.attitude.rotationMatrix.m22,
                m23: data.attitude.rotationMatrix.m23,
                m31: data.attitude.rotationMatrix.m31,
                m32: data.attitude.rotationMatrix.m32,
                m33: data.attitude.rotationMatrix.m33
            ),
            quaternion: Quaternion(
                x: data.attitude.quaternion.x,
                y: data.attitude.quaternion.y,
                z: data.attitude.quaternion.z,
                w: data.attitude.quaternion.w
            )
        )
        
        let rotationRate = Vector3D(
            x: data.rotationRate.x,
            y: data.rotationRate.y,
            z: data.rotationRate.z
        )
        
        let gravity = Vector3D(
            x: data.gravity.x,
            y: data.gravity.y,
            z: data.gravity.z
        )
        
        let userAcceleration = Vector3D(
            x: data.userAcceleration.x,
            y: data.userAcceleration.y,
            z: data.userAcceleration.z
        )
        
        var magneticField: CalibratedMagneticField? = nil
        if data.magneticField.accuracy != .uncalibrated {
            let field = data.magneticField
            let accuracy: String
            switch field.accuracy {
            case .uncalibrated:
                accuracy = "uncalibrated"
            case .low:
                accuracy = "low"
            case .medium:
                accuracy = "medium"
            case .high:
                accuracy = "high"
            @unknown default:
                accuracy = "uncalibrated"
            }
            
            magneticField = CalibratedMagneticField(
                field: Vector3D(x: field.field.x, y: field.field.y, z: field.field.z),
                accuracy: accuracy
            )
        }
        
        return DeviceMotionData(
            attitude: attitude,
            rotationRate: rotationRate,
            gravity: gravity,
            userAcceleration: userAcceleration,
            magneticField: magneticField,
            heading: data.heading >= 0 ? data.heading : nil,
            timestamp: dateFormatter.string(from: Date(timeIntervalSince1970: data.timestamp))
        )
    }
    
    private func motionActivityFromCM(_ activity: CMMotionActivity) -> MotionActivity {
        let confidence: String
        switch activity.confidence {
        case .low:
            confidence = "low"
        case .medium:
            confidence = "medium"
        case .high:
            confidence = "high"
        default:
            confidence = "low"
        }
        
        return MotionActivity(
            stationary: activity.stationary,
            walking: activity.walking,
            running: activity.running,
            automotive: activity.automotive,
            cycling: activity.cycling,
            unknown: activity.unknown,
            startDate: dateFormatter.string(from: activity.startDate),
            confidence: confidence
        )
    }
    
    private func pedometerDataFromCM(_ data: CMPedometerData, endDate: Date) -> PedometerData {
        return PedometerData(
            startDate: dateFormatter.string(from: data.startDate),
            endDate: dateFormatter.string(from: endDate),
            numberOfSteps: data.numberOfSteps.intValue,
            distance: data.distance?.doubleValue,
            floorsAscended: data.floorsAscended?.intValue,
            floorsDescended: data.floorsDescended?.intValue,
            currentPace: data.currentPace?.doubleValue,
            currentCadence: data.currentCadence?.doubleValue,
            averageActivePace: data.averageActivePace?.doubleValue
        )
    }
    
    private func altimeterDataFromCM(_ data: CMAltitudeData) -> AltimeterData {
        return AltimeterData(
            relativeAltitude: data.relativeAltitude.doubleValue,
            pressure: data.pressure.doubleValue,
            timestamp: dateFormatter.string(from: Date())
        )
    }
}

@_cdecl("init_plugin_ios_motion")
func initPlugin() -> Plugin {
    return MotionPlugin()
}