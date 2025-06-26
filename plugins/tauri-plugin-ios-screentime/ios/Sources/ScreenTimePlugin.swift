import Tauri
import DeviceActivity
import FamilyControls
import ManagedSettings
import UIKit

// Request structures
struct TimeRangeData: Decodable {
    let start: String // ISO 8601 date string
    let end: String   // ISO 8601 date string
}

struct SetAppLimitData: Decodable {
    let bundleIds: [String]
    let timeLimit: Int // seconds per day
    let daysOfWeek: [String]
}

struct SetDowntimeData: Decodable {
    let startTime: String // HH:MM format
    let endTime: String   // HH:MM format
    let daysOfWeek: [String]
    let allowedApps: [String]
}

struct CommunicationSafetyData: Decodable {
    let checkPhotosAndVideos: Bool
    let communicationSafetyEnabled: Bool
    let notificationSettings: NotificationSettingsData
}

struct NotificationSettingsData: Decodable {
    let notifyChild: Bool
    let notifyParent: Bool
}

struct ExportFormatData: Decodable {
    let format: String
    let includeCharts: Bool
}

struct ExportRequestData: Decodable {
    let range: TimeRangeData
    let format: ExportFormatData
}

@available(iOS 15.0, *)
class ScreenTimePlugin: Plugin {
    private let authorizationCenter = AuthorizationCenter.shared
    private let deviceActivityCenter = DeviceActivityCenter()
    private let iso8601Formatter = ISO8601DateFormatter()
    
    override init() {
        super.init()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
    @available(iOS 16.0, *)
    @objc public func requestAuthorization(_ invoke: Invoke) throws {
        Task {
            do {
                try await authorizationCenter.requestAuthorization(for: .individual)
                
                await MainActor.run {
                    switch authorizationCenter.authorizationStatus {
                    case .approved:
                        invoke.resolve(true)
                    case .denied:
                        invoke.reject("Screen Time authorization denied")
                    case .notDetermined:
                        invoke.reject("Screen Time authorization not determined")
                    @unknown default:
                        invoke.reject("Unknown authorization status")
                    }
                }
            } catch {
                await MainActor.run {
                    invoke.reject("Failed to request authorization: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc public func getScreenTimeSummary(_ invoke: Invoke) throws {
        struct GetSummaryArgs: Decodable {
            let date: String? // ISO 8601 date string
        }
        
        let _ = try? invoke.parseArgs(GetSummaryArgs.self)
        let targetDate = Date()
        
        // Note: Real implementation would use DeviceActivity framework
        // This is a mock response as Screen Time data access is restricted
        let mockSummary: [String: Any] = [
            "date": iso8601Formatter.string(from: targetDate),
            "totalScreenTime": 14400, // 4 hours in seconds
            "totalPickups": 45,
            "firstPickup": iso8601Formatter.string(from: targetDate.addingTimeInterval(28800)), // 8 AM
            "mostUsedApp": [
                "bundleId": "com.example.app",
                "displayName": "Example App",
                "duration": 3600,
                "numberOfPickups": 12,
                "numberOfNotifications": 8,
                "category": "social"
            ],
            "mostUsedCategory": [
                "category": "social",
                "duration": 7200,
                "numberOfApps": 3,
                "apps": ["com.example.app", "com.example.app2", "com.example.app3"]
            ]
        ]
        
        invoke.resolve(mockSummary)
    }
    
    @objc public func getAppUsage(_ invoke: Invoke) throws {
        struct GetUsageArgs: Decodable {
            let range: TimeRangeData?
        }
        
        let _ = try? invoke.parseArgs(GetUsageArgs.self)
        
        // Mock app usage data - wrap in a dictionary to satisfy resolve()
        let mockUsage: [String: Any] = [
            "apps": [
                [
                    "bundleId": "com.example.app1",
                    "displayName": "Social App",
                    "duration": 3600,
                    "numberOfPickups": 12,
                    "numberOfNotifications": 15,
                    "category": "social",
                    "icon": NSNull()
                ],
                [
                    "bundleId": "com.example.app2",
                    "displayName": "Game App",
                    "duration": 2400,
                    "numberOfPickups": 8,
                    "numberOfNotifications": 3,
                    "category": "games",
                    "icon": NSNull()
                ]
            ]
        ]
        
        invoke.resolve(mockUsage)
    }
    
    @objc public func getCategoryUsage(_ invoke: Invoke) throws {
        struct GetUsageArgs: Decodable {
            let range: TimeRangeData?
        }
        
        let _ = try? invoke.parseArgs(GetUsageArgs.self)
        
        // Mock category usage data - wrap in a dictionary
        let mockUsage: [String: Any] = [
            "categories": [
                [
                    "category": "social",
                    "duration": 7200,
                    "numberOfApps": 3,
                    "apps": ["com.example.social1", "com.example.social2", "com.example.social3"]
                ],
                [
                    "category": "games",
                    "duration": 3600,
                    "numberOfApps": 2,
                    "apps": ["com.example.game1", "com.example.game2"]
                ]
            ]
        ]
        
        invoke.resolve(mockUsage)
    }
    
    @objc public func getWebUsage(_ invoke: Invoke) throws {
        struct GetUsageArgs: Decodable {
            let range: TimeRangeData?
        }
        
        let _ = try? invoke.parseArgs(GetUsageArgs.self)
        
        // Mock web usage data - wrap in a dictionary
        let mockUsage: [String: Any] = [
            "domains": [
                [
                    "domain": "example.com",
                    "duration": 1800,
                    "numberOfVisits": 25
                ],
                [
                    "domain": "news.example.com",
                    "duration": 1200,
                    "numberOfVisits": 10
                ]
            ]
        ]
        
        invoke.resolve(mockUsage)
    }
    
    @objc public func getDeviceActivity(_ invoke: Invoke) throws {
        struct GetActivityArgs: Decodable {
            let range: TimeRangeData?
        }
        
        let _ = try? invoke.parseArgs(GetActivityArgs.self)
        
        // Mock device activity data - wrap in a dictionary
        let now = Date()
        let mockActivity: [String: Any] = [
            "activities": [
                [
                    "timestamp": iso8601Formatter.string(from: now.addingTimeInterval(-3600)),
                    "eventType": "screenOn",
                    "associatedApp": NSNull()
                ],
                [
                    "timestamp": iso8601Formatter.string(from: now.addingTimeInterval(-3000)),
                    "eventType": "appOpen",
                    "associatedApp": "com.example.app"
                ],
                [
                    "timestamp": iso8601Formatter.string(from: now.addingTimeInterval(-1800)),
                    "eventType": "notificationReceived",
                    "associatedApp": "com.example.app"
                ]
            ]
        ]
        
        invoke.resolve(mockActivity)
    }
    
    @objc public func getNotificationsSummary(_ invoke: Invoke) throws {
        struct GetSummaryArgs: Decodable {
            let date: String?
        }
        
        let _ = try? invoke.parseArgs(GetSummaryArgs.self)
        
        // Mock notifications summary
        let mockSummary: [String: Any] = [
            "totalNotifications": 87,
            "notificationsByApp": [
                "com.example.app1": 45,
                "com.example.app2": 22,
                "com.example.app3": 20
            ],
            "notificationsByHour": [
                "8": 12,
                "9": 15,
                "10": 8,
                "11": 10,
                "12": 14,
                "13": 7,
                "14": 9,
                "15": 12
            ]
        ]
        
        invoke.resolve(mockSummary)
    }
    
    @objc public func getPickupsSummary(_ invoke: Invoke) throws {
        struct GetSummaryArgs: Decodable {
            let date: String?
        }
        
        let _ = try? invoke.parseArgs(GetSummaryArgs.self)
        
        // Mock pickups summary
        let mockSummary: [String: Any] = [
            "totalPickups": 45,
            "pickupsByHour": [
                "8": 5,
                "9": 7,
                "10": 3,
                "11": 4,
                "12": 6,
                "13": 3,
                "14": 4,
                "15": 5,
                "16": 4,
                "17": 4
            ],
            "averageTimeBetweenPickups": 960, // 16 minutes
            "longestSession": 3600 // 1 hour
        ]
        
        invoke.resolve(mockSummary)
    }
    
    @objc public func setAppLimit(_ invoke: Invoke) throws {
        let _ = try invoke.parseArgs(SetAppLimitData.self)
        
        // In a real implementation, this would use FamilyControls
        // to set app limits. For now, we'll return a mock ID
        let limitId = UUID().uuidString
        invoke.resolve(limitId)
    }
    
    @objc public func getAppLimits(_ invoke: Invoke) throws {
        // Mock app limits data - wrap in a dictionary
        let mockLimits: [String: Any] = [
            "limits": [
                [
                    "id": "limit-1",
                    "bundleIds": ["com.example.app1", "com.example.app2"],
                    "timeLimit": 3600,
                    "daysOfWeek": ["monday", "tuesday", "wednesday", "thursday", "friday"],
                    "enabled": true
                ]
            ]
        ]
        
        invoke.resolve(mockLimits)
    }
    
    @objc public func removeAppLimit(_ invoke: Invoke) throws {
        struct RemoveLimitArgs: Decodable {
            let limitId: String
        }
        
        let _ = try invoke.parseArgs(RemoveLimitArgs.self)
        
        // In a real implementation, this would remove the limit
        invoke.resolve()
    }
    
    @objc public func setDowntimeSchedule(_ invoke: Invoke) throws {
        let _ = try invoke.parseArgs(SetDowntimeData.self)
        
        // In a real implementation, this would use FamilyControls
        // to set downtime schedule. For now, we'll return a mock ID
        let scheduleId = UUID().uuidString
        invoke.resolve(scheduleId)
    }
    
    @objc public func getDowntimeSchedule(_ invoke: Invoke) throws {
        // Mock downtime schedule
        let mockSchedule: [String: Any] = [
            "id": "schedule-1",
            "startTime": "22:00",
            "endTime": "07:00",
            "daysOfWeek": ["sunday", "monday", "tuesday", "wednesday", "thursday"],
            "allowedApps": ["com.apple.mobilesafari"],
            "enabled": true
        ]
        
        invoke.resolve(mockSchedule)
    }
    
    @objc public func removeDowntimeSchedule(_ invoke: Invoke) throws {
        struct RemoveScheduleArgs: Decodable {
            let scheduleId: String
        }
        
        let _ = try invoke.parseArgs(RemoveScheduleArgs.self)
        
        // In a real implementation, this would remove the schedule
        invoke.resolve()
    }
    
    @objc public func blockApp(_ invoke: Invoke) throws {
        struct BlockAppArgs: Decodable {
            let bundleId: String
        }
        
        let _ = try invoke.parseArgs(BlockAppArgs.self)
        
        // In a real implementation, this would use FamilyControls
        invoke.resolve()
    }
    
    @objc public func unblockApp(_ invoke: Invoke) throws {
        struct UnblockAppArgs: Decodable {
            let bundleId: String
        }
        
        let _ = try invoke.parseArgs(UnblockAppArgs.self)
        
        // In a real implementation, this would use FamilyControls
        invoke.resolve()
    }
    
    @objc public func getBlockedApps(_ invoke: Invoke) throws {
        // Mock blocked apps list
        let blockedApps = ["com.example.blockedapp1", "com.example.blockedapp2"]
        invoke.resolve(blockedApps)
    }
    
    @objc public func setCommunicationSafety(_ invoke: Invoke) throws {
        let _ = try invoke.parseArgs(CommunicationSafetyData.self)
        
        // In a real implementation, this would configure communication safety
        invoke.resolve()
    }
    
    @objc public func getCommunicationSafetySettings(_ invoke: Invoke) throws {
        // Mock communication safety settings
        let mockSettings: [String: Any] = [
            "checkPhotosAndVideos": true,
            "communicationSafetyEnabled": true,
            "notificationSettings": [
                "notifyChild": true,
                "notifyParent": true
            ]
        ]
        
        invoke.resolve(mockSettings)
    }
    
    @objc public func exportData(_ invoke: Invoke) throws {
        let _ = try invoke.parseArgs(ExportRequestData.self)
        
        // Mock exported data
        let mockExport: [String: Any] = [
            "format": "json",
            "createdAt": iso8601Formatter.string(from: Date()),
            "dataUrl": "https://example.com/export/screentime-data.json"
        ]
        
        invoke.resolve(mockExport)
    }
    
    @objc public func isScreenTimeAvailable(_ invoke: Invoke) throws {
        // Check if Screen Time is available
        if #available(iOS 16.0, *) {
            invoke.resolve(AuthorizationCenter.shared.authorizationStatus != .notDetermined)
        } else {
            invoke.resolve(false)
        }
    }
    
    @objc public override func checkPermissions(_ invoke: Invoke) {
        // Check current authorization status
        let status: String
        switch authorizationCenter.authorizationStatus {
        case .approved:
            status = "granted"
        case .denied:
            status = "denied"
        case .notDetermined:
            status = "prompt"
        @unknown default:
            status = "unknown"
        }
        
        invoke.resolve(status)
    }
}

@_cdecl("init_plugin_ios_screentime")
func initPlugin() -> Plugin {
    if #available(iOS 15.0, *) {
        return ScreenTimePlugin()
    } else {
        // Return a stub plugin for older iOS versions
        return Plugin()
    }
}