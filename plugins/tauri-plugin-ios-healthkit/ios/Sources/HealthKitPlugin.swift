import Tauri
import WebKit
import HealthKit
import UIKit

struct HealthKitPermissionRequest: Decodable {
    let read: [String]
    let write: [String]
}

struct QuantityQuery: Decodable {
    let dataType: String
    let startDate: String
    let endDate: String
    let limit: Int?
}

struct QuantitySample: Codable {
    let dataType: String
    let value: Double
    let unit: String
    let startDate: String
    let endDate: String
    let metadata: [String: String]?
}

class HealthKitPlugin: Plugin {
    private let healthStore = HKHealthStore()
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    @objc public override func load(webview: WKWebView) {
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
    }
    
    @objc public func checkPermissions(_ invoke: Invoke) throws {
        var permissions: [String: Any] = [:]
        var readPermissions: [String: String] = [:]
        var writePermissions: [String: String] = [:]
        
        // Check common data types
        let dataTypes = [
            "steps": HKQuantityType.quantityType(forIdentifier: .stepCount),
            "heartRate": HKQuantityType.quantityType(forIdentifier: .heartRate),
            "activeEnergyBurned": HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            "distanceWalkingRunning": HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            "flightsClimbed": HKQuantityType.quantityType(forIdentifier: .flightsClimbed),
            "height": HKQuantityType.quantityType(forIdentifier: .height),
            "weight": HKQuantityType.quantityType(forIdentifier: .bodyMass),
            "bodyMassIndex": HKQuantityType.quantityType(forIdentifier: .bodyMassIndex),
            "bodyFatPercentage": HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage),
            "sleepAnalysis": HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        ]
        
        for (key, type) in dataTypes {
            if let objectType = type {
                let readStatus = healthStore.authorizationStatus(for: objectType)
                let writeStatus = healthStore.authorizationStatus(for: objectType)
                
                readPermissions[key] = authorizationStatusToString(readStatus)
                writePermissions[key] = authorizationStatusToString(writeStatus)
            } else {
                readPermissions[key] = "denied"
                writePermissions[key] = "denied"
            }
        }
        
        permissions["read"] = readPermissions
        permissions["write"] = writePermissions
        
        invoke.resolve(permissions)
    }
    
    @objc public func requestPermissions(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(HealthKitPermissionRequest.self)
        
        var readTypes = Set<HKObjectType>()
        var writeTypes = Set<HKSampleType>()
        
        // Parse read types
        for typeString in args.read {
            if let type = parseHealthKitType(typeString) {
                readTypes.insert(type)
            }
        }
        
        // Parse write types
        for typeString in args.write {
            if let type = parseHealthKitType(typeString) as? HKSampleType {
                writeTypes.insert(type)
            }
        }
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { [weak self] success, error in
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            // Check permissions after request
            do {
                try self?.checkPermissions(invoke)
            } catch {
                invoke.reject(error.localizedDescription)
            }
        }
    }
    
    @objc public func queryQuantitySamples(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(QuantityQuery.self)
        
        guard let quantityType = parseHealthKitType(args.dataType) as? HKQuantityType else {
            invoke.reject("Invalid data type")
            return
        }
        
        guard let startDate = dateFormatter.date(from: args.startDate),
              let endDate = dateFormatter.date(from: args.endDate) else {
            invoke.reject("Invalid date format")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: quantityType,
            predicate: predicate,
            limit: args.limit ?? HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            let results = (samples as? [HKQuantitySample] ?? []).map { sample in
                [
                    "dataType": args.dataType,
                    "value": sample.quantity.doubleValue(for: self.getUnit(for: quantityType)),
                    "unit": self.getUnitString(for: quantityType),
                    "startDate": self.dateFormatter.string(from: sample.startDate),
                    "endDate": self.dateFormatter.string(from: sample.endDate),
                    "metadata": sample.metadata
                ]
            }
            
            invoke.resolve(results)
        }
        
        healthStore.execute(query)
    }
    
    @objc public func writeQuantitySample(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(QuantitySample.self)
        
        guard let quantityType = parseHealthKitType(args.dataType) as? HKQuantityType else {
            invoke.reject("Invalid data type")
            return
        }
        
        guard let startDate = dateFormatter.date(from: args.startDate),
              let endDate = dateFormatter.date(from: args.endDate) else {
            invoke.reject("Invalid date format")
            return
        }
        
        let unit = getUnit(for: quantityType)
        let quantity = HKQuantity(unit: unit, doubleValue: args.value)
        
        let sample = HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: startDate,
            end: endDate,
            metadata: args.metadata
        )
        
        healthStore.save(sample) { success, error in
            if let error = error {
                invoke.reject(error.localizedDescription)
            } else {
                invoke.resolve()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseHealthKitType(_ typeString: String) -> HKObjectType? {
        switch typeString.lowercased() {
        case "steps":
            return HKQuantityType.quantityType(forIdentifier: .stepCount)
        case "heartrate":
            return HKQuantityType.quantityType(forIdentifier: .heartRate)
        case "activeenergyburned":
            return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        case "distancewalkingrunning":
            return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        case "flightsclimbed":
            return HKQuantityType.quantityType(forIdentifier: .flightsClimbed)
        case "height":
            return HKQuantityType.quantityType(forIdentifier: .height)
        case "weight":
            return HKQuantityType.quantityType(forIdentifier: .bodyMass)
        case "bodymassindex":
            return HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)
        case "bodyfatpercentage":
            return HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)
        case "sleepanalysis":
            return HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        default:
            return nil
        }
    }
    
    private func getUnit(for type: HKQuantityType) -> HKUnit {
        switch type.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return .count()
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return .count().unitDivided(by: .minute())
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            return .kilocalorie()
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            return .meter()
        case HKQuantityTypeIdentifier.flightsClimbed.rawValue:
            return .count()
        case HKQuantityTypeIdentifier.height.rawValue:
            return .meter()
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            return .gramUnit(with: .kilo)
        case HKQuantityTypeIdentifier.bodyMassIndex.rawValue:
            return .count()
        case HKQuantityTypeIdentifier.bodyFatPercentage.rawValue:
            return .percent()
        default:
            return .count()
        }
    }
    
    private func getUnitString(for type: HKQuantityType) -> String {
        switch type.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return "count"
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return "count/min"
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            return "kcal"
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            return "m"
        case HKQuantityTypeIdentifier.flightsClimbed.rawValue:
            return "count"
        case HKQuantityTypeIdentifier.height.rawValue:
            return "m"
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            return "kg"
        case HKQuantityTypeIdentifier.bodyMassIndex.rawValue:
            return "count"
        case HKQuantityTypeIdentifier.bodyFatPercentage.rawValue:
            return "%"
        default:
            return "count"
        }
    }
    
    private func authorizationStatusToString(_ status: HKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "prompt"
        case .sharingDenied:
            return "denied"
        case .sharingAuthorized:
            return "granted"
        @unknown default:
            return "denied"
        }
    }
}

@_cdecl("init_plugin_ios_healthkit")
func initPlugin() -> Plugin {
    return HealthKitPlugin()
}