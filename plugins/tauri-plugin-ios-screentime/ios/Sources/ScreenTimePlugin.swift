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

class ScreenTimePlugin: Plugin {
    private let authorizationCenter = AuthorizationCenter.shared
    private let deviceActivityCenter = DeviceActivityCenter()
    private let iso8601Formatter = ISO8601DateFormatter()
    
    override init() {
        super.init()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
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
        
        let args = try? invoke.parseArgs(GetSummaryArgs.self)
        let targetDate = args?.date.flatMap { iso8601Formatter.date(from: $0) } ?? Date()
        
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
        
        let args = try? invoke.parseArgs(GetUsageArgs.self)
        
        // Mock app usage data
        let mockUsage: [[String: Any]] = [
            [
                "bundleId": "com.example.app1",
                "displayName": "Social App",
                "duration": 3600,
                "numberOfPickups": 12,
                "numberOfNotifications": 15,
                "category": "social",
                "icon": nil
            ],
            [
                "bundleId": "com.example.app2",
                "displayName": "Game App",
                "duration": 2400,
                "numberOfPickups": 8,
                "numberOfNotifications": 3,
                "category": "games",
                "icon": nil
            ]
        ]
        
        invoke.resolve(mockUsage)
    }
    
    @objc public func getCategoryUsage(_ invoke: Invoke) throws {
        struct GetUsageArgs: Decodable {
            let range: TimeRangeData?
        }
        
        let args = try? invoke.parseArgs(GetUsageArgs.self)
        
        // Mock category usage data
        let mockUsage: [[String: Any]] = [
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
        
        invoke.resolve(mockUsage)
    }
    
    @objc public func getWebUsage(_ invoke: Invoke) throws {
        struct GetUsageArgs: Decodable {
            let range: TimeRangeData?
        }
        
        let args = try? invoke.parseArgs(GetUsageArgs.self)
        
        // Mock web usage data
        let mockUsage: [[String: Any]] = [
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
        
        invoke.resolve(mockUsage)
    }
    
    @objc public func getDeviceActivity(_ invoke: Invoke) throws {
        struct GetActivityArgs: Decodable {
            let range: TimeRangeData?
        }
        
        let args = try? invoke.parseArgs(GetActivityArgs.self)
        
        // Mock device activity data
        let now = Date()
        let mockActivity: [[String: Any]] = [
            [
                "timestamp": iso8601Formatter.string(from: now.addingTimeInterval(-3600)),
                "eventType": "screenOn",
                "associatedApp": nil
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
        
        invoke.resolve(mockActivity)
    }
    
    @objc public func getNotificationsSummary(_ invoke: Invoke) throws {
        struct GetSummaryArgs: Decodable {
            let date: String?
        }
        
        let args = try? invoke.parseArgs(GetSummaryArgs.self)
        
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
        
        let args = try? invoke.parseArgs(GetSummaryArgs.self)
        
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
        let args = try invoke.parseArgs(SetAppLimitData.self)
        
        // In a real implementation, this would use FamilyControls
        // to set app limits. For now, we'll return a mock ID
        let limitId = UUID().uuidString
        invoke.resolve(limitId)
    }
    
    @objc public func getAppLimits(_ invoke: Invoke) throws {
        // Mock app limits data
        let mockLimits: [[String: Any]] = [
            [
                "id": "limit-1",
                "bundleIds": ["com.example.app1", "com.example.app2"],
                "timeLimit": 3600,
                "daysOfWeek": ["monday", "tuesday", "wednesday", "thursday", "friday"],
                "enabled": true
            ]
        ]
        
        invoke.resolve(mockLimits)
    }
    
    @objc public func removeAppLimit(_ invoke: Invoke) throws {
        struct RemoveLimitArgs: Decodable {
            let limitId: String
        }
        
        let args = try invoke.parseArgs(RemoveLimitArgs.self)
        
        // In a real implementation, this would remove the limit
        invoke.resolve()
    }
    
    @objc public func setDowntimeSchedule(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SetDowntimeData.self)
        
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
        
        let args = try invoke.parseArgs(RemoveScheduleArgs.self)
        
        // In a real implementation, this would remove the schedule
        invoke.resolve()
    }
    
    @objc public func blockApp(_ invoke: Invoke) throws {
        struct BlockAppArgs: Decodable {
            let bundleId: String
        }
        
        let args = try invoke.parseArgs(BlockAppArgs.self)
        
        // In a real implementation, this would use FamilyControls
        invoke.resolve()
    }
    
    @objc public func unblockApp(_ invoke: Invoke) throws {
        struct UnblockAppArgs: Decodable {
            let bundleId: String
        }
        
        let args = try invoke.parseArgs(UnblockAppArgs.self)
        
        // In a real implementation, this would use FamilyControls
        invoke.resolve()
    }
    
    @objc public func getBlockedApps(_ invoke: Invoke) throws {
        // Mock blocked apps list
        let blockedApps = ["com.example.blockedapp1", "com.example.blockedapp2"]
        invoke.resolve(blockedApps)
    }
    
    @objc public func setCommunicationSafety(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(CommunicationSafetyData.self)
        
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
    
    @objc public func getScreenDistance(_ invoke: Invoke) throws {
        // Mock screen distance data
        // In iOS 17+, this would use actual screen distance APIs
        let mockDistance: [String: Any] = [
            "currentDistance": 35.5, // cm
            "isTooClose": false,
            "recommendedDistance": 30.0,
            "durationTooClose": 300 // 5 minutes
        ]
        
        invoke.resolve(mockDistance)
    }
    
    @objc public func getUsageTrends(_ invoke: Invoke) throws {
        struct GetTrendsArgs: Decodable {
            let period: String
        }
        
        let args = try invoke.parseArgs(GetTrendsArgs.self)
        
        // Mock usage trends
        let now = Date()
        var dataPoints: [[String: Any]] = []
        
        for i in 0..<7 {
            let date = now.addingTimeInterval(TimeInterval(-i * 86400))
            dataPoints.append([
                "date": iso8601Formatter.string(from: date),
                "screenTime": 14400 - (i * 600), // Decreasing trend
                "pickups": 45 - (i * 2)
            ])
        }
        
        let mockTrends: [String: Any] = [
            "period": args.period,
            "screenTimeTrend": "down",
            "pickupsTrend": "down",
            "screenTimeChange": -15.5,
            "pickupsChange": -20.0,
            "dataPoints": dataPoints.reversed()
        ]
        
        invoke.resolve(mockTrends)
    }
    
    @objc public func exportUsageReport(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(ExportRequestData.self)
        
        // In a real implementation, this would generate an actual report
        // For now, we'll return a mock file path
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName = "screen_time_report_\(Date().timeIntervalSince1970).\(args.format.format.lowercased())"
        let filePath = "\(documentsPath)/\(fileName)"
        
        // Create a mock file
        let mockContent = "Mock Screen Time Report"
        try mockContent.write(toFile: filePath, atomically: true, encoding: .utf8)
        
        invoke.resolve(filePath)
    }
}

@_cdecl("init_plugin_ios_screentime")
func initPlugin() -> Plugin {
    return ScreenTimePlugin()
}