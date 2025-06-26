import Tauri
import UIKit
import WidgetKit

struct WidgetConfiguration: Codable {
    let kind: String
    let family: String
    let intentConfiguration: String?
}

struct WidgetContent: Codable {
    let title: String?
    let subtitle: String?
    let body: String?
    let image: String?
    let backgroundImage: String?
    let tintColor: String?
    let font: WidgetFont?
    let customData: [String: String]?
}

struct WidgetFont: Codable {
    let size: Double
    let weight: String
    let design: String
}

struct WidgetRelevance: Codable {
    let score: Double
    let duration: Int
}

struct WidgetData: Codable {
    let kind: String
    let family: String?
    let content: WidgetContent
    let refreshDate: String?
    let expirationDate: String?
    let relevance: WidgetRelevance?
}

struct WidgetInfo: Codable {
    let bundleIdentifier: String
    let displayName: String
    let description: String
    let supportedFamilies: [String]
    let configurationDisplayName: String?
    let customIntents: [String]
}

struct WidgetUrl: Codable {
    let scheme: String
    let host: String?
    let path: String?
    let queryParameters: [String: String]
}

struct WidgetPreview: Codable {
    let family: String
    let displayName: String
    let description: String
    let previewImage: String
}

struct WidgetRefreshSchedule: Codable {
    let widgetKind: String
    let refreshIntervals: [RefreshInterval]
}

struct RefreshInterval: Codable {
    let startDate: String
    let intervalSeconds: Int
    let repeatCount: Int?
}

@available(iOS 14.0, *)
class WidgetsPlugin: Plugin {
    private let sharedDefaults = UserDefaults(suiteName: "group.com.app.widgets")
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    @objc public func reloadAllTimelines(_ invoke: Invoke) {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
            invoke.resolve()
        } else {
            invoke.reject("Widgets require iOS 14.0 or later")
        }
    }
    
    @objc public func reloadTimelines(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(ReloadTimelinesArgs.self)
            
            if #available(iOS 14.0, *) {
                args.widgetKinds.forEach { kind in
                    WidgetCenter.shared.reloadTimelines(ofKind: kind)
                }
                invoke.resolve()
            } else {
                invoke.reject("Widgets require iOS 14.0 or later")
            }
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func getCurrentConfigurations(_ invoke: Invoke) {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let widgetInfos):
                    let configurations = widgetInfos.map { info -> WidgetConfiguration in
                        return WidgetConfiguration(
                            kind: info.kind,
                            family: self.widgetFamilyToString(info.family),
                            intentConfiguration: info.configuration?.description
                        )
                    }
                    invoke.resolve(["configurations": configurations])
                case .failure(let error):
                    invoke.reject(error.localizedDescription)
                }
            }
        } else {
            invoke.reject("Widgets require iOS 14.0 or later")
        }
    }
    
    @objc public func setWidgetData(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(SetWidgetDataArgs.self)
            let data = args.data
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(data)
            let key = "widget_\(data.kind)_\(data.family ?? "default")"
            sharedDefaults.set(encoded, forKey: key)
            
            // Reload the specific widget timeline
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadTimelines(ofKind: data.kind)
            }
            
            invoke.resolve()
        } catch {
            invoke.reject("Failed to encode widget data: \(error)")
        }
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func getWidgetData(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(GetWidgetDataArgs.self)
            let kind = args.kind
            let family = args.family
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        let key = "widget_\(kind)_\(family ?? "default")"
        
        if let data = sharedDefaults.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let widgetData = try decoder.decode(WidgetData.self, from: data)
                invoke.resolve(["data": widgetData])
            } catch {
                invoke.reject("Failed to decode widget data: \(error)")
            }
        } else {
            invoke.resolve()
        }
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func clearWidgetData(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(ClearWidgetDataArgs.self)
            let kind = args.kind
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        // Clear all data for this widget kind
        let keys = sharedDefaults.dictionaryRepresentation().keys
        keys.filter { $0.hasPrefix("widget_\(kind)_") }.forEach { key in
            sharedDefaults.removeObject(forKey: key)
        }
        
        // Reload the widget timeline
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }
        
        invoke.resolve()
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func requestWidgetUpdate(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(RequestWidgetUpdateArgs.self)
            let kind = args.kind
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
            invoke.resolve()
        } else {
            invoke.reject("Widgets require iOS 14.0 or later")
        }
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func getWidgetInfo(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(GetWidgetInfoArgs.self)
            let kind = args.kind
        
        // This would normally fetch from widget extension info
        // For now, return mock data
        let info = WidgetInfo(
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            displayName: kind,
            description: "Widget for \(kind)",
            supportedFamilies: ["systemSmall", "systemMedium", "systemLarge"],
            configurationDisplayName: nil,
            customIntents: []
        )
        
        invoke.resolve(["info": info])
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func setWidgetUrl(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(SetWidgetUrlArgs.self)
            let kind = args.kind
            let url = args.url
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(url)
            sharedDefaults.set(encoded, forKey: "widget_url_\(kind)")
            invoke.resolve()
        } catch {
            invoke.reject("Failed to encode URL: \(error)")
        }
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func getWidgetUrl(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(GetWidgetUrlArgs.self)
            let kind = args.kind
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        if let data = sharedDefaults.data(forKey: "widget_url_\(kind)") {
            do {
                let decoder = JSONDecoder()
                let url = try decoder.decode(WidgetUrl.self, from: data)
                invoke.resolve(["url": url])
            } catch {
                invoke.reject("Failed to decode URL: \(error)")
            }
        } else {
            invoke.resolve()
        }
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func previewWidgetData(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(PreviewWidgetDataArgs.self)
            let data = args.data
        
        // Generate preview images for each supported family
        var previews: [WidgetPreview] = []
        
        let families = ["systemSmall", "systemMedium", "systemLarge"]
        for family in families {
            // In a real implementation, this would generate actual preview images
            let preview = WidgetPreview(
                family: family,
                displayName: data.content.title ?? "Widget",
                description: data.content.subtitle ?? "",
                previewImage: "" // Base64 encoded preview image would go here
            )
            previews.append(preview)
        }
        
        invoke.resolve(["previews": previews])
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func getWidgetFamilies(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(GetWidgetFamiliesArgs.self)
            let kind = args.kind
        
        // Return supported families for the widget
        let families = ["systemSmall", "systemMedium", "systemLarge", "systemExtraLarge"]
        invoke.resolve(["families": families])
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func scheduleWidgetRefresh(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(ScheduleWidgetRefreshArgs.self)
            let schedule = args.schedule
        
        // Generate a unique schedule ID
        let scheduleId = UUID().uuidString
        
        // Store the schedule
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(schedule)
            sharedDefaults.set(encoded, forKey: "widget_schedule_\(scheduleId)")
            
            // In a real implementation, this would set up background tasks
            // or notifications to trigger widget updates
            
            invoke.resolve(["scheduleId": scheduleId])
        } catch {
            invoke.reject("Failed to encode schedule: \(error)")
        }
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    @objc public func cancelWidgetRefresh(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(CancelWidgetRefreshArgs.self)
            let scheduleId = args.scheduleId
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        sharedDefaults.removeObject(forKey: "widget_schedule_\(scheduleId)")
        
        // In a real implementation, this would cancel the background tasks
        
        invoke.resolve()
        } catch {
            invoke.reject("Invalid arguments: \(error)")
        }
    }
    
    // Helper method to convert WidgetFamily to string
    @available(iOS 14.0, *)
    private func widgetFamilyToString(_ family: WidgetFamily) -> String {
        switch family {
        case .systemSmall:
            return "systemSmall"
        case .systemMedium:
            return "systemMedium"
        case .systemLarge:
            return "systemLarge"
        case .systemExtraLarge:
            if #available(iOS 15.0, *) {
                return "systemExtraLarge"
            } else {
                return "systemLarge"
            }
        case .accessoryCircular:
            if #available(iOS 16.0, *) {
                return "accessoryCircular"
            } else {
                return "systemSmall"
            }
        case .accessoryRectangular:
            if #available(iOS 16.0, *) {
                return "accessoryRectangular"
            } else {
                return "systemMedium"
            }
        case .accessoryInline:
            if #available(iOS 16.0, *) {
                return "accessoryInline"
            } else {
                return "systemSmall"
            }
        @unknown default:
            return "unknown"
        }
    }
    
    // Emit widget events
    private func emitWidgetEvent(type: String, widgetKind: String) {
        let event = WidgetEvent(
            eventType: type,
            widgetKind: widgetKind,
            timestamp: dateFormatter.string(from: Date())
        )
        trigger("widget:event", data: [
            "eventType": event.eventType,
            "widgetKind": event.widgetKind,
            "timestamp": event.timestamp
        ] as JSObject)
    }
}

// Argument structures for parseArgs
struct ReloadTimelinesArgs: Decodable {
    let widgetKinds: [String]
}

struct SetWidgetDataArgs: Decodable {
    let data: WidgetData
}

struct GetWidgetDataArgs: Decodable {
    let kind: String
    let family: String?
}

struct ClearWidgetDataArgs: Decodable {
    let kind: String
}

struct RequestWidgetUpdateArgs: Decodable {
    let kind: String
}

struct GetWidgetInfoArgs: Decodable {
    let kind: String
}

struct SetWidgetUrlArgs: Decodable {
    let kind: String
    let url: WidgetUrl
}

struct GetWidgetUrlArgs: Decodable {
    let kind: String
}

struct PreviewWidgetDataArgs: Decodable {
    let data: WidgetData
}

struct GetWidgetFamiliesArgs: Decodable {
    let kind: String
}

struct ScheduleWidgetRefreshArgs: Decodable {
    let schedule: WidgetRefreshSchedule
}

struct CancelWidgetRefreshArgs: Decodable {
    let scheduleId: String
}

struct WidgetEvent: Encodable {
    let eventType: String
    let widgetKind: String
    let timestamp: String
}

@_cdecl("init_plugin_ios_widgets")
func initPlugin() -> Plugin {
    if #available(iOS 14.0, *) {
        return WidgetsPlugin()
    } else {
        // Return a stub plugin for older iOS versions
        return Plugin()
    }
}