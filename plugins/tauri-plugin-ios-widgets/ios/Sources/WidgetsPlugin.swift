import Tauri
import UIKit
import WidgetKit

struct WidgetConfiguration: Codable {
    let kind: String
    let family: String
    let intentConfiguration: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case kind
        case family
        case intentConfiguration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(String.self, forKey: .kind)
        family = try container.decode(String.self, forKey: .family)
        intentConfiguration = try container.decodeIfPresent([String: Any].self, forKey: .intentConfiguration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(family, forKey: .family)
        try container.encodeIfPresent(intentConfiguration, forKey: .intentConfiguration)
    }
}

struct WidgetContent: Codable {
    let title: String?
    let subtitle: String?
    let body: String?
    let image: String?
    let backgroundImage: String?
    let tintColor: String?
    let font: WidgetFont?
    let customData: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case title, subtitle, body, image, backgroundImage, tintColor, font, customData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        backgroundImage = try container.decodeIfPresent(String.self, forKey: .backgroundImage)
        tintColor = try container.decodeIfPresent(String.self, forKey: .tintColor)
        font = try container.decodeIfPresent(WidgetFont.self, forKey: .font)
        customData = try container.decode([String: Any].self, forKey: .customData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(backgroundImage, forKey: .backgroundImage)
        try container.encodeIfPresent(tintColor, forKey: .tintColor)
        try container.encodeIfPresent(font, forKey: .font)
        try container.encode(customData, forKey: .customData)
    }
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
        guard let widgetKinds = invoke.getArray("widgetKinds", String.self) else {
            invoke.reject("Invalid widget kinds")
            return
        }
        
        if #available(iOS 14.0, *) {
            widgetKinds.forEach { kind in
                WidgetCenter.shared.reloadTimelines(ofKind: kind)
            }
            invoke.resolve()
        } else {
            invoke.reject("Widgets require iOS 14.0 or later")
        }
    }
    
    @objc public func getCurrentConfigurations(_ invoke: Invoke) {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let widgetInfos):
                    let configurations = widgetInfos.map { info -> [String: Any] in
                        return [
                            "kind": info.kind,
                            "family": self.widgetFamilyToString(info.family),
                            "intentConfiguration": info.configuration?.description ?? ""
                        ]
                    }
                    invoke.resolve(configurations)
                case .failure(let error):
                    invoke.reject(error.localizedDescription)
                }
            }
        } else {
            invoke.reject("Widgets require iOS 14.0 or later")
        }
    }
    
    @objc public func setWidgetData(_ invoke: Invoke) {
        guard let data = invoke.getObject("data", WidgetData.self) else {
            invoke.reject("Invalid widget data")
            return
        }
        
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
    }
    
    @objc public func getWidgetData(_ invoke: Invoke) {
        guard let kind = invoke.getString("kind") else {
            invoke.reject("Invalid kind")
            return
        }
        
        let family = invoke.getString("family")
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        let key = "widget_\(kind)_\(family ?? "default")"
        
        if let data = sharedDefaults.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let widgetData = try decoder.decode(WidgetData.self, from: data)
                invoke.resolve(widgetData)
            } catch {
                invoke.reject("Failed to decode widget data: \(error)")
            }
        } else {
            invoke.resolve(nil)
        }
    }
    
    @objc public func clearWidgetData(_ invoke: Invoke) {
        guard let kind = invoke.getString("kind") else {
            invoke.reject("Invalid kind")
            return
        }
        
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
    }
    
    @objc public func requestWidgetUpdate(_ invoke: Invoke) {
        guard let kind = invoke.getString("kind") else {
            invoke.reject("Invalid kind")
            return
        }
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
            invoke.resolve()
        } else {
            invoke.reject("Widgets require iOS 14.0 or later")
        }
    }
    
    @objc public func getWidgetInfo(_ invoke: Invoke) {
        guard let kind = invoke.getString("kind") else {
            invoke.reject("Invalid kind")
            return
        }
        
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
        
        invoke.resolve(info)
    }
    
    @objc public func setWidgetUrl(_ invoke: Invoke) {
        guard let kind = invoke.getString("kind"),
              let url = invoke.getObject("url", WidgetUrl.self) else {
            invoke.reject("Invalid parameters")
            return
        }
        
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
    }
    
    @objc public func getWidgetUrl(_ invoke: Invoke) {
        guard let kind = invoke.getString("kind") else {
            invoke.reject("Invalid kind")
            return
        }
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        if let data = sharedDefaults.data(forKey: "widget_url_\(kind)") {
            do {
                let decoder = JSONDecoder()
                let url = try decoder.decode(WidgetUrl.self, from: data)
                invoke.resolve(url)
            } catch {
                invoke.reject("Failed to decode URL: \(error)")
            }
        } else {
            invoke.resolve(nil)
        }
    }
    
    @objc public func previewWidgetData(_ invoke: Invoke) {
        guard let data = invoke.getObject("data", WidgetData.self) else {
            invoke.reject("Invalid widget data")
            return
        }
        
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
        
        invoke.resolve(previews)
    }
    
    @objc public func getWidgetFamilies(_ invoke: Invoke) {
        guard let kind = invoke.getString("kind") else {
            invoke.reject("Invalid kind")
            return
        }
        
        // Return supported families for the widget
        let families = ["systemSmall", "systemMedium", "systemLarge", "systemExtraLarge"]
        invoke.resolve(families)
    }
    
    @objc public func scheduleWidgetRefresh(_ invoke: Invoke) {
        guard let schedule = invoke.getObject("schedule", WidgetRefreshSchedule.self) else {
            invoke.reject("Invalid schedule")
            return
        }
        
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
            
            invoke.resolve(scheduleId)
        } catch {
            invoke.reject("Failed to encode schedule: \(error)")
        }
    }
    
    @objc public func cancelWidgetRefresh(_ invoke: Invoke) {
        guard let scheduleId = invoke.getString("scheduleId") else {
            invoke.reject("Invalid schedule ID")
            return
        }
        
        guard let sharedDefaults = sharedDefaults else {
            invoke.reject("Shared container not available")
            return
        }
        
        sharedDefaults.removeObject(forKey: "widget_schedule_\(scheduleId)")
        
        // In a real implementation, this would cancel the background tasks
        
        invoke.resolve()
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
    private func emitWidgetEvent(type: String, data: Any) {
        trigger([
            "eventType": type,
            "widgetKind": data,
            "timestamp": dateFormatter.string(from: Date())
        ])
    }
}

// Extension to handle dictionary encoding/decoding
extension KeyedDecodingContainer {
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary = [String: Any]()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension KeyedEncodingContainer {
    mutating func encode(_ value: [String: Any], forKey key: K) throws {
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        try container.encode(value)
    }
    
    mutating func encode(_ value: [String: Any]) throws {
        for (key, val) in value {
            let key = JSONCodingKeys(stringValue: key)!
            if let boolValue = val as? Bool {
                try encode(boolValue, forKey: key as! K)
            } else if let stringValue = val as? String {
                try encode(stringValue, forKey: key as! K)
            } else if let intValue = val as? Int {
                try encode(intValue, forKey: key as! K)
            } else if let doubleValue = val as? Double {
                try encode(doubleValue, forKey: key as! K)
            } else if let dictValue = val as? [String: Any] {
                try encode(dictValue, forKey: key as! K)
            } else if let arrayValue = val as? [Any] {
                var container = self.nestedUnkeyedContainer(forKey: key as! K)
                try container.encode(arrayValue)
            }
        }
    }
}

extension UnkeyedEncodingContainer {
    mutating func encode(_ value: [Any]) throws {
        for val in value {
            if let boolValue = val as? Bool {
                try encode(boolValue)
            } else if let stringValue = val as? String {
                try encode(stringValue)
            } else if let intValue = val as? Int {
                try encode(intValue)
            } else if let doubleValue = val as? Double {
                try encode(doubleValue)
            } else if let dictValue = val as? [String: Any] {
                var container = self.nestedContainer(keyedBy: JSONCodingKeys.self)
                try container.encode(dictValue)
            } else if let arrayValue = val as? [Any] {
                var container = self.nestedUnkeyedContainer()
                try container.encode(arrayValue)
            }
        }
    }
}

struct JSONCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
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