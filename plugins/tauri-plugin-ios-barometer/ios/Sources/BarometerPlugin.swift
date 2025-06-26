import Tauri
import UIKit
import CoreMotion

struct PressureData: Codable {
    let pressure: Double
    let relativeAltitude: Double?
    let temperature: Double?
    let timestamp: String
}

struct AltitudeData: Codable {
    let altitude: Double
    let pressure: Double
    let referencePressure: Double
    let timestamp: String
}

struct WeatherData: Codable {
    let pressure: Double
    let pressureTrend: String
    let altitude: Double?
    let temperature: Double?
    let humidity: Double?
    let weatherCondition: String
    let timestamp: String
}

struct BarometerCalibration: Codable {
    let referencePressure: Double
    let referenceAltitude: Double
    let calibrationDate: String
}

class BarometerPlugin: Plugin {
    private let altimeter = CMAltimeter()
    private var updateInterval: TimeInterval = 1.0
    private var referencePressure: Double = 101.325 // Standard atmospheric pressure at sea level (kPa)
    private var pressureHistory: [(pressure: Double, timestamp: Date)] = []
    private let maxHistoryCount = 100
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private func convertToJSObject(_ dict: [String: Any]) -> JSObject {
        var jsObject: JSObject = [:]
        for (key, value) in dict {
            if let str = value as? String {
                jsObject[key] = str
            } else if let num = value as? NSNumber {
                if num == kCFBooleanTrue || num == kCFBooleanFalse {
                    jsObject[key] = num.boolValue
                } else {
                    jsObject[key] = num.doubleValue
                }
            } else if let int = value as? Int {
                jsObject[key] = Double(int)
            } else if let double = value as? Double {
                jsObject[key] = double
            } else if let bool = value as? Bool {
                jsObject[key] = bool
            } else if let array = value as? [Any] {
                jsObject[key] = array
            } else if let dict = value as? [String: Any] {
                jsObject[key] = convertToJSObject(dict)
            } else if value is NSNull {
                jsObject[key] = nil
            }
        }
        return jsObject
    }
    
    @objc public func startPressureUpdates(_ invoke: Invoke) {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            invoke.reject("Barometer not available")
            return
        }
        
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            if let error = error {
                let errorData: [String: Any] = ["eventType": "error", "data": error.localizedDescription]
                self?.trigger("barometerError", data: self?.convertToJSObject(errorData) ?? [:] as JSObject)
                return
            }
            
            if let data = data {
                if let pressureData = self?.pressureDataFromCM(data) {
                    self?.updatePressureHistory(data.pressure.doubleValue)
                    let updateData: [String: Any] = [
                        "eventType": "pressureUpdate",
                        "data": pressureData
                    ]
                    self?.trigger("pressureUpdate", data: self?.convertToJSObject(updateData) ?? [:] as JSObject)
                }
            }
        }
        
        invoke.resolve()
    }
    
    @objc public func stopPressureUpdates(_ invoke: Invoke) {
        altimeter.stopRelativeAltitudeUpdates()
        invoke.resolve()
    }
    
    @objc public func getPressureData(_ invoke: Invoke) {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            invoke.reject("Barometer not available")
            return
        }
        
        // Get a single reading
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            self?.altimeter.stopRelativeAltitudeUpdates()
            
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                invoke.reject("No pressure data available")
                return
            }
            
            if let pressureData = self?.pressureDataFromCM(data) {
                invoke.resolve(pressureData)
            } else {
                invoke.reject("Failed to process pressure data")
            }
        }
    }
    
    @objc public func isBarometerAvailable(_ invoke: Invoke) {
        invoke.resolve(CMAltimeter.isRelativeAltitudeAvailable())
    }
    
    @objc public func setUpdateInterval(_ invoke: Invoke) {
        struct UpdateIntervalArgs: Decodable {
            let interval: Double
        }
        
        guard let args = try? invoke.parseArgs(UpdateIntervalArgs.self) else {
            invoke.reject("Invalid interval")
            return
        }
        
        let interval = args.interval
        
        if interval < 0.1 || interval > 60.0 {
            invoke.reject("Invalid update interval: \(interval)")
            return
        }
        
        updateInterval = interval
        invoke.resolve()
    }
    
    @objc public func getReferencePressure(_ invoke: Invoke) {
        invoke.resolve(referencePressure)
    }
    
    @objc public func setReferencePressure(_ invoke: Invoke) {
        struct ReferencePressureArgs: Decodable {
            let pressure: Double
        }
        
        guard let args = try? invoke.parseArgs(ReferencePressureArgs.self) else {
            invoke.reject("Invalid pressure")
            return
        }
        
        let pressure = args.pressure
        
        if pressure < 80.0 || pressure > 120.0 {
            invoke.reject("Invalid reference pressure: \(pressure)")
            return
        }
        
        referencePressure = pressure
        invoke.resolve()
    }
    
    @objc public func getAltitudeFromPressure(_ invoke: Invoke) {
        struct AltitudeArgs: Decodable {
            let pressure: Double
        }
        
        guard let args = try? invoke.parseArgs(AltitudeArgs.self) else {
            invoke.reject("Invalid pressure")
            return
        }
        
        let pressure = args.pressure
        
        // Calculate altitude using the barometric formula
        let altitude = calculateAltitude(pressure: pressure, referencePressure: referencePressure)
        invoke.resolve(altitude)
    }
    
    @objc public func startAltitudeUpdates(_ invoke: Invoke) {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            invoke.reject("Barometer not available")
            return
        }
        
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            if let error = error {
                let errorData: [String: Any] = ["eventType": "error", "data": error.localizedDescription]
                self?.trigger("barometerError", data: self?.convertToJSObject(errorData) ?? [:] as JSObject)
                return
            }
            
            if let data = data {
                let pressure = data.pressure.doubleValue
                let altitude = self?.calculateAltitude(pressure: pressure, referencePressure: self?.referencePressure ?? 101.325) ?? 0
                
                let altitudeData = AltitudeData(
                    altitude: altitude,
                    pressure: pressure,
                    referencePressure: self?.referencePressure ?? 101.325,
                    timestamp: self?.dateFormatter.string(from: Date()) ?? ""
                )
                
                let updateData: [String: Any] = [
                    "eventType": "altitudeUpdate",
                    "data": altitudeData
                ]
                self?.trigger("altitudeUpdate", data: self?.convertToJSObject(updateData) ?? [:] as JSObject)
            }
        }
        
        invoke.resolve()
    }
    
    @objc public func stopAltitudeUpdates(_ invoke: Invoke) {
        altimeter.stopRelativeAltitudeUpdates()
        invoke.resolve()
    }
    
    @objc public func getWeatherData(_ invoke: Invoke) {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            invoke.reject("Barometer not available")
            return
        }
        
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            self?.altimeter.stopRelativeAltitudeUpdates()
            
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                invoke.reject("No pressure data available")
                return
            }
            
            let pressure = data.pressure.doubleValue
            self?.updatePressureHistory(pressure)
            
            let trend = self?.calculatePressureTrend() ?? "steady"
            let condition = self?.predictWeatherCondition(pressure: pressure, trend: trend) ?? "unknown"
            let altitude = self?.calculateAltitude(pressure: pressure, referencePressure: self?.referencePressure ?? 101.325)
            
            let weatherData = WeatherData(
                pressure: pressure,
                pressureTrend: trend,
                altitude: altitude,
                temperature: nil, // iOS doesn't provide temperature from barometer
                humidity: nil, // iOS doesn't provide humidity from barometer
                weatherCondition: condition,
                timestamp: self?.dateFormatter.string(from: Date()) ?? ""
            )
            
            invoke.resolve(weatherData)
        }
    }
    
    @objc public func calibrateBarometer(_ invoke: Invoke) {
        struct CalibrationArgs: Decodable {
            let calibration: BarometerCalibration
        }
        
        guard let args = try? invoke.parseArgs(CalibrationArgs.self) else {
            invoke.reject("Invalid calibration data")
            return
        }
        
        let calibration = args.calibration
        
        if calibration.referencePressure < 80.0 || calibration.referencePressure > 120.0 {
            invoke.reject("Invalid reference pressure: \(calibration.referencePressure)")
            return
        }
        
        referencePressure = calibration.referencePressure
        
        let calibrationData: [String: Any] = [
            "eventType": "calibrationComplete",
            "data": calibration
        ]
        trigger("calibrationComplete", data: convertToJSObject(calibrationData))
        
        invoke.resolve()
    }
    
    // Helper methods
    private func pressureDataFromCM(_ data: CMAltitudeData) -> PressureData {
        return PressureData(
            pressure: data.pressure.doubleValue,
            relativeAltitude: data.relativeAltitude.doubleValue,
            temperature: nil, // iOS doesn't provide temperature
            timestamp: dateFormatter.string(from: Date())
        )
    }
    
    private func calculateAltitude(pressure: Double, referencePressure: Double) -> Double {
        // Barometric formula
        let temperature = 288.15 // Standard temperature (15°C)
        let lapseRate = 0.0065 // Temperature lapse rate (K/m)
        let gasConstant = 8.31432 // Universal gas constant
        let gravity = 9.80665 // Acceleration due to gravity
        let molarMass = 0.0289644 // Molar mass of Earth's air
        
        let exponent = (gasConstant * temperature) / (gravity * molarMass)
        let ratio = pressure / referencePressure
        
        return temperature / lapseRate * (1 - pow(ratio, 1 / exponent))
    }
    
    private func updatePressureHistory(_ pressure: Double) {
        pressureHistory.append((pressure: pressure, timestamp: Date()))
        
        // Keep only recent history
        if pressureHistory.count > maxHistoryCount {
            pressureHistory.removeFirst()
        }
    }
    
    private func calculatePressureTrend() -> String {
        guard pressureHistory.count >= 10 else {
            return "steady"
        }
        
        let recentCount = min(10, pressureHistory.count)
        let recentPressures = pressureHistory.suffix(recentCount)
        
        guard let firstPressure = recentPressures.first?.pressure,
              let lastPressure = recentPressures.last?.pressure else {
            return "steady"
        }
        
        let change = lastPressure - firstPressure
        
        if change > 0.1 {
            return "rising"
        } else if change < -0.1 {
            return "falling"
        } else {
            return "steady"
        }
    }
    
    private func predictWeatherCondition(pressure: Double, trend: String) -> String {
        // Simple weather prediction based on pressure
        if pressure > 102.5 {
            return "fair"
        } else if pressure < 100.5 {
            return "stormy"
        } else if trend == "falling" {
            return "changing"
        } else {
            return "fair"
        }
    }
}

@_cdecl("init_plugin_ios_barometer")
func initPlugin() -> Plugin {
    return BarometerPlugin()
}