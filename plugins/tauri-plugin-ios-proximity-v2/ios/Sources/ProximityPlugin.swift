import Tauri
import UIKit

struct ProximityState: Codable {
    let isClose: Bool
    let timestamp: String
}

struct ProximityConfiguration: Codable {
    let enabled: Bool
    let autoLockDisplay: Bool
}

struct DisplayAutoLockState: Codable {
    let enabled: Bool
    let proximityMonitoringEnabled: Bool
}

struct ProximityStatistics: Codable {
    let totalDetections: Int
    let currentSessionDetections: Int
    let lastDetection: String?
    let averageProximityDuration: Double?
    let monitoringDuration: Double
}

class ProximityPlugin: Plugin {
    private var isMonitoring = false
    private var monitoringStartTime: Date?
    private var totalDetections = 0
    private var sessionDetections = 0
    private var lastDetectionTime: Date?
    private var proximityStartTime: Date?
    private var totalProximityDuration: TimeInterval = 0
    private var proximityDetectionCount = 0
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    override func load() {
        // Set up notification observer for proximity state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(proximityStateChanged),
            name: UIDevice.proximityStateDidChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if UIDevice.current.isProximityMonitoringEnabled {
            UIDevice.current.isProximityMonitoringEnabled = false
        }
    }
    
    @objc public func startProximityMonitoring(_ invoke: Invoke) {
        guard UIDevice.current.isProximityMonitoringEnabled else {
            invoke.reject("Proximity monitoring not enabled")
            return
        }
        
        if isMonitoring {
            invoke.reject("Proximity monitoring already active")
            return
        }
        
        isMonitoring = true
        monitoringStartTime = Date()
        sessionDetections = 0
        
        trigger([
            "eventType": "monitoringStarted",
            "state": ProximityState(
                isClose: UIDevice.current.proximityState,
                timestamp: dateFormatter.string(from: Date())
            )
        ])
        
        invoke.resolve()
    }
    
    @objc public func stopProximityMonitoring(_ invoke: Invoke) {
        if !isMonitoring {
            invoke.reject("Proximity monitoring not active")
            return
        }
        
        isMonitoring = false
        
        // If proximity was detected when stopping, add to duration
        if UIDevice.current.proximityState, let startTime = proximityStartTime {
            totalProximityDuration += Date().timeIntervalSince(startTime)
            proximityStartTime = nil
        }
        
        trigger([
            "eventType": "monitoringStopped",
            "state": ProximityState(
                isClose: false,
                timestamp: dateFormatter.string(from: Date())
            )
        ])
        
        invoke.resolve()
    }
    
    @objc public func getProximityState(_ invoke: Invoke) {
        guard UIDevice.current.isProximityMonitoringEnabled else {
            invoke.reject("Proximity monitoring not enabled")
            return
        }
        
        let state = ProximityState(
            isClose: UIDevice.current.proximityState,
            timestamp: dateFormatter.string(from: Date())
        )
        
        invoke.resolve(state)
    }
    
    @objc public func isProximityAvailable(_ invoke: Invoke) {
        // Proximity sensor is available on all iPhones
        invoke.resolve(true)
    }
    
    @objc public func enableProximityMonitoring(_ invoke: Invoke) {
        UIDevice.current.isProximityMonitoringEnabled = true
        
        if UIDevice.current.isProximityMonitoringEnabled {
            invoke.resolve()
        } else {
            invoke.reject("Failed to enable proximity monitoring")
        }
    }
    
    @objc public func disableProximityMonitoring(_ invoke: Invoke) {
        // Stop monitoring if active
        if isMonitoring {
            isMonitoring = false
            
            // If proximity was detected when disabling, add to duration
            if UIDevice.current.proximityState, let startTime = proximityStartTime {
                totalProximityDuration += Date().timeIntervalSince(startTime)
                proximityStartTime = nil
            }
        }
        
        UIDevice.current.isProximityMonitoringEnabled = false
        
        if !UIDevice.current.isProximityMonitoringEnabled {
            invoke.resolve()
        } else {
            invoke.reject("Failed to disable proximity monitoring")
        }
    }
    
    @objc public func setDisplayAutoLock(_ invoke: Invoke) {
        guard let enabled = invoke.getBool("enabled") else {
            invoke.reject("Invalid parameter")
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = !enabled
            invoke.resolve()
        }
    }
    
    @objc public func getDisplayAutoLockState(_ invoke: Invoke) {
        let state = DisplayAutoLockState(
            enabled: !UIApplication.shared.isIdleTimerDisabled,
            proximityMonitoringEnabled: UIDevice.current.isProximityMonitoringEnabled
        )
        
        invoke.resolve(state)
    }
    
    @objc private func proximityStateChanged() {
        guard isMonitoring else { return }
        
        let isClose = UIDevice.current.proximityState
        let now = Date()
        
        if isClose {
            // Object detected
            proximityStartTime = now
            sessionDetections += 1
            totalDetections += 1
            lastDetectionTime = now
            proximityDetectionCount += 1
            
            trigger([
                "eventType": "proximityDetected",
                "state": ProximityState(
                    isClose: true,
                    timestamp: dateFormatter.string(from: now)
                )
            ])
        } else {
            // Object removed
            if let startTime = proximityStartTime {
                totalProximityDuration += now.timeIntervalSince(startTime)
                proximityStartTime = nil
            }
            
            trigger([
                "eventType": "proximityCleared",
                "state": ProximityState(
                    isClose: false,
                    timestamp: dateFormatter.string(from: now)
                )
            ])
        }
    }
    
    // Helper method to get statistics
    private func getStatistics() -> ProximityStatistics {
        let monitoringDuration = monitoringStartTime?.timeIntervalSinceNow ?? 0
        let averageDuration = proximityDetectionCount > 0 ? totalProximityDuration / Double(proximityDetectionCount) : nil
        
        return ProximityStatistics(
            totalDetections: totalDetections,
            currentSessionDetections: sessionDetections,
            lastDetection: lastDetectionTime.map { dateFormatter.string(from: $0) },
            averageProximityDuration: averageDuration,
            monitoringDuration: abs(monitoringDuration)
        )
    }
}

@_cdecl("init_plugin_ios_proximity")
func initPlugin() -> Plugin {
    return ProximityPlugin()
}