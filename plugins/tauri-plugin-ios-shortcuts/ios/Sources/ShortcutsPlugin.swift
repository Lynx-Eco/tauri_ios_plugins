import Tauri
import Intents
import IntentsUI
import CoreSpotlight
import UIKit

// Helper for decoding [String: Any]
struct JSONAny: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([JSONAny].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: JSONAny].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
}

// Request structures
struct ShortcutData: Decodable {
    let identifier: String
    let title: String
    let suggestedInvocationPhrase: String?
    let isEligibleForSearch: Bool
    let isEligibleForPrediction: Bool
    let userActivityType: String
    let userInfo: [String: JSONAny]?
    let persistentIdentifier: String?
}

struct InteractionData: Decodable {
    let intent: IntentData
    let donationDate: String?
    let shortcut: ShortcutData?
}

struct IntentData: Decodable {
    let identifier: String
    let displayName: String
    let category: String
    let parameters: [String: JSONAny]?
    let suggestedInvocationPhrase: String?
    let image: IntentImageData?
}

struct IntentImageData: Decodable {
    let systemName: String?
    let templateName: String?
    let data: String?
}

struct UserActivityData: Decodable {
    let activityType: String
    let title: String
    let userInfo: [String: JSONAny]?
    let keywords: [String]
    let persistentIdentifier: String?
    let isEligibleForSearch: Bool
    let isEligibleForPublicIndexing: Bool
    let isEligibleForHandoff: Bool
    let isEligibleForPrediction: Bool
    let contentAttributes: ContentAttributesData?
    let requiredUserInfoKeys: [String]
}

struct ContentAttributesData: Decodable {
    let title: String?
    let contentDescription: String?
    let thumbnailData: String?
    let thumbnailUrl: String?
    let keywords: [String]
}

struct ShortcutSuggestionData: Decodable {
    let intent: IntentData
    let suggestedPhrase: String
}

struct AppIntentData: Decodable {
    let identifier: String
    let displayName: String
    let description: String
    let category: String
    let parameterDefinitions: [ParameterDefinitionData]
    let responseTemplate: String?
}

struct ParameterDefinitionData: Decodable {
    let name: String
    let displayName: String
    let description: String
    let parameterType: String
    let isRequired: Bool
    let defaultValue: JSONAny?
    let options: [ParameterOptionData]
}

struct ParameterOptionData: Decodable {
    let identifier: String
    let displayName: String
    let synonyms: [String]
}

class ShortcutsPlugin: Plugin {
    private var donatedShortcuts: [String: INShortcut] = [:]
    private var registeredIntents: [String: AppIntentData] = [:]
    private var addShortcutDelegates: [String: AddShortcutDelegate] = [:]
    
    @objc public func donateInteraction(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(InteractionData.self)
        
        // Create a generic intent for demonstration
        let intent = INIntent()
        
        let interaction = INInteraction(intent: intent, response: nil)
        
        interaction.donate { error in
            if let error = error {
                invoke.reject("Failed to donate interaction: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func donateShortcut(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(ShortcutData.self)
        
        let userActivity = NSUserActivity(activityType: args.userActivityType)
        userActivity.title = args.title
        userActivity.isEligibleForSearch = args.isEligibleForSearch
        userActivity.isEligibleForPrediction = args.isEligibleForPrediction
        
        if let phrase = args.suggestedInvocationPhrase {
            userActivity.suggestedInvocationPhrase = phrase
        }
        
        if let persistentId = args.persistentIdentifier {
            userActivity.persistentIdentifier = persistentId
        }
        
        // Convert userInfo
        if let userInfo = args.userInfo {
            var convertedUserInfo: [String: Any] = [:]
            for (key, jsonAny) in userInfo {
                convertedUserInfo[key] = jsonAny.value
            }
            userActivity.userInfo = convertedUserInfo
        }
        
        let shortcut = INShortcut(userActivity: userActivity)
        
        // Present the add shortcut view controller
        DispatchQueue.main.async {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.delegate = AddShortcutDelegate(plugin: self, invoke: invoke, identifier: args.identifier)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                var topController = rootViewController
                while let presented = topController.presentedViewController {
                    topController = presented
                }
                topController.present(viewController, animated: true)
            }
        }
    }
    
    @objc public func getAllShortcuts(_ invoke: Invoke) throws {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { shortcuts, error in
            if let error = error {
                invoke.reject("Failed to get shortcuts: \(error.localizedDescription)")
                return
            }
            
            let shortcutData = shortcuts?.compactMap { voiceShortcut -> [String: Any]? in
                guard let userActivity = voiceShortcut.shortcut.userActivity else { return nil }
                
                return [
                    "identifier": voiceShortcut.identifier.uuidString,
                    "title": userActivity.title ?? "",
                    "suggestedInvocationPhrase": userActivity.suggestedInvocationPhrase ?? "",
                    "isEligibleForSearch": userActivity.isEligibleForSearch,
                    "isEligibleForPrediction": userActivity.isEligibleForPrediction,
                    "userActivityType": userActivity.activityType,
                    "userInfo": userActivity.userInfo ?? [:],
                    "persistentIdentifier": userActivity.persistentIdentifier ?? ""
                ]
            } ?? []
            
            invoke.resolve(["shortcuts": shortcutData])
        }
    }
    
    @objc public func deleteShortcut(_ invoke: Invoke) throws {
        struct DeleteArgs: Decodable {
            let identifier: String
        }
        
        let args = try invoke.parseArgs(DeleteArgs.self)
        
        guard let uuid = UUID(uuidString: args.identifier) else {
            invoke.reject("Invalid shortcut identifier")
            return
        }
        
        // deleteVoiceShortcut is not available, use delete with identifiers
        INInteraction.delete(with: [args.identifier]) { error in
            if let error = error {
                invoke.reject("Failed to delete shortcut: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func deleteAllShortcuts(_ invoke: Invoke) throws {
        INInteraction.deleteAll { error in
            if let error = error {
                invoke.reject("Failed to delete all shortcuts: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func getVoiceShortcuts(_ invoke: Invoke) throws {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { shortcuts, error in
            if let error = error {
                invoke.reject("Failed to get voice shortcuts: \(error.localizedDescription)")
                return
            }
            
            let voiceShortcuts = shortcuts?.compactMap { voiceShortcut -> [String: Any]? in
                guard let userActivity = voiceShortcut.shortcut.userActivity else { return nil }
                
                return [
                    "identifier": voiceShortcut.identifier.uuidString,
                    "invocationPhrase": voiceShortcut.invocationPhrase,
                    "shortcut": [
                        "identifier": voiceShortcut.identifier.uuidString,
                        "title": userActivity.title ?? "",
                        "suggestedInvocationPhrase": userActivity.suggestedInvocationPhrase ?? "",
                        "isEligibleForSearch": userActivity.isEligibleForSearch,
                        "isEligibleForPrediction": userActivity.isEligibleForPrediction,
                        "userActivityType": userActivity.activityType,
                        "userInfo": userActivity.userInfo ?? [:],
                        "persistentIdentifier": userActivity.persistentIdentifier ?? ""
                    ]
                ]
            } ?? []
            
            invoke.resolve(["shortcuts": voiceShortcuts])
        }
    }
    
    @objc public func suggestPhrase(_ invoke: Invoke) throws {
        struct SuggestArgs: Decodable {
            let shortcutIdentifier: String
        }
        
        let args = try invoke.parseArgs(SuggestArgs.self)
        
        // Generate a suggested phrase based on the shortcut identifier
        let suggestedPhrase = "Run \(args.shortcutIdentifier)"
        invoke.resolve(suggestedPhrase)
    }
    
    @objc public func handleUserActivity(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(UserActivityData.self)
        
        let userActivity = NSUserActivity(activityType: args.activityType)
        userActivity.title = args.title
        userActivity.userInfo = args.userInfo
        userActivity.keywords = Set(args.keywords)
        userActivity.persistentIdentifier = args.persistentIdentifier
        userActivity.isEligibleForSearch = args.isEligibleForSearch
        userActivity.isEligibleForPublicIndexing = args.isEligibleForPublicIndexing
        userActivity.isEligibleForHandoff = args.isEligibleForHandoff
        userActivity.isEligibleForPrediction = args.isEligibleForPrediction
        userActivity.requiredUserInfoKeys = Set(args.requiredUserInfoKeys)
        
        if let contentAttrs = args.contentAttributes {
            let searchableAttributes = CSSearchableItemAttributeSet(itemContentType: "public.content")
            searchableAttributes.title = contentAttrs.title
            searchableAttributes.contentDescription = contentAttrs.contentDescription
            searchableAttributes.keywords = contentAttrs.keywords
            
            if let thumbnailBase64 = contentAttrs.thumbnailData,
               let thumbnailData = Data(base64Encoded: thumbnailBase64) {
                searchableAttributes.thumbnailData = thumbnailData
            }
            
            userActivity.contentAttributeSet = searchableAttributes
        }
        
        userActivity.becomeCurrent()
        invoke.resolve()
    }
    
    @objc public func updateShortcut(_ invoke: Invoke) throws {
        let _ = try invoke.parseArgs(ShortcutData.self)
        
        // In a real implementation, this would update an existing shortcut
        // For now, we'll just resolve
        invoke.resolve()
    }
    
    @objc public func getShortcutSuggestions(_ invoke: Invoke) throws {
        // Return mock suggestions
        let suggestions: [[String: Any]] = [
            [
                "intent": [
                    "identifier": "open-app",
                    "displayName": "Open App",
                    "category": "information",
                    "parameters": [:],
                    "suggestedInvocationPhrase": "Open my app"
                ],
                "suggestedPhrase": "Open my app"
            ]
        ]
        
        invoke.resolve(["suggestions": suggestions])
    }
    
    @objc public func setShortcutSuggestions(_ invoke: Invoke) throws {
        struct SetSuggestionsArgs: Decodable {
            let suggestions: [ShortcutSuggestionData]
        }
        
        let args = try invoke.parseArgs(SetSuggestionsArgs.self)
        
        // Store suggestions for later use
        invoke.resolve()
    }
    
    @objc public func createAppIntent(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(AppIntentData.self)
        
        let intentId = UUID().uuidString
        registeredIntents[intentId] = args
        
        invoke.resolve(intentId)
    }
    
    @objc public func registerAppIntents(_ invoke: Invoke) throws {
        struct RegisterIntentsArgs: Decodable {
            let intents: [AppIntentData]
        }
        
        let args = try invoke.parseArgs(RegisterIntentsArgs.self)
        
        for intent in args.intents {
            registeredIntents[intent.identifier] = intent
        }
        
        invoke.resolve()
    }
    
    @objc public func handleIntent(_ invoke: Invoke) throws {
        struct HandleIntentArgs: Decodable {
            let intentId: String
            let parameters: [String: JSONAny]?
        }
        
        let args = try invoke.parseArgs(HandleIntentArgs.self)
        
        // Mock intent handling
        let response: [String: Any] = [
            "success": true,
            "userActivity": NSNull(),
            "output": ["result": "Intent handled successfully"],
            "error": NSNull()
        ]
        
        invoke.resolve(response)
    }
    
    @objc public func getDonatedIntents(_ invoke: Invoke) throws {
        // Return mock donated intents
        let donatedIntents: [[String: Any]] = []
        invoke.resolve(["intents": donatedIntents])
    }
    
    @objc public func deleteDonatedIntents(_ invoke: Invoke) throws {
        struct DeleteIntentsArgs: Decodable {
            let identifiers: [String]
        }
        
        let args = try invoke.parseArgs(DeleteIntentsArgs.self)
        
        INInteraction.delete(with: args.identifiers) { error in
            if let error = error {
                invoke.reject("Failed to delete intents: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func setEligibleForPrediction(_ invoke: Invoke) throws {
        struct SetEligibleArgs: Decodable {
            let intentIds: [String]
            let eligible: Bool
        }
        
        let args = try invoke.parseArgs(SetEligibleArgs.self)
        
        // This would be implemented with actual intent handling
        invoke.resolve()
    }
    
    @objc public func getPredictions(_ invoke: Invoke) throws {
        struct GetPredictionsArgs: Decodable {
            let limit: Int?
        }
        
        let args = try? invoke.parseArgs(GetPredictionsArgs.self)
        
        // Return mock predictions
        let predictions: [[String: Any]] = []
        invoke.resolve(["predictions": predictions])
    }
}

// MARK: - Voice Shortcut Delegate

class AddShortcutDelegate: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
    weak var plugin: ShortcutsPlugin?
    let invoke: Invoke
    let identifier: String
    
    init(plugin: ShortcutsPlugin?, invoke: Invoke, identifier: String) {
        self.plugin = plugin
        self.invoke = invoke
        self.identifier = identifier
    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true)
        
        if let error = error {
            invoke.reject("Failed to add shortcut: \(error.localizedDescription)")
        } else if let voiceShortcut = voiceShortcut {
            // Store the shortcut
            invoke.resolve()
        } else {
            invoke.reject("Shortcut creation cancelled")
        }
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
        invoke.reject("User cancelled shortcut creation")
    }
}

@_cdecl("init_plugin_ios_shortcuts")
func initPlugin() -> Plugin {
    return ShortcutsPlugin()
}