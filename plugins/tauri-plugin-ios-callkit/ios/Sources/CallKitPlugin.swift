import Tauri
import CallKit
import AVFoundation
import PushKit
import UIKit

// Request structures
struct ProviderConfigData: Decodable {
    let localizedName: String
    let ringtoneSound: String?
    let iconTemplateImage: String?
    let maximumCallGroups: Int
    let maximumCallsPerGroup: Int
    let supportsVideo: Bool
    let includeCallsInRecents: Bool
    let supportedHandleTypes: [String]
}

struct CallHandleData: Decodable {
    let handleType: String
    let value: String
}

struct IncomingCallData: Decodable {
    let uuid: String
    let handle: CallHandleData
    let hasVideo: Bool
    let callerName: String?
    let supportsDtmf: Bool
    let supportsHolding: Bool
    let supportsGrouping: Bool
    let supportsUngrouping: Bool
}

struct OutgoingCallData: Decodable {
    let uuid: String
    let handle: CallHandleData
    let hasVideo: Bool
    let contactIdentifier: String?
}

struct CallUpdateData: Decodable {
    let remoteHandle: CallHandleData?
    let localizedCallerName: String?
    let supportsDtmf: Bool?
    let supportsHolding: Bool?
    let supportsGrouping: Bool?
    let supportsUngrouping: Bool?
    let hasVideo: Bool?
}

struct AudioSessionConfigData: Decodable {
    let category: String
    let mode: String
    let options: [String]
}

struct TransactionData: Decodable {
    let action: String
    let callUuid: String
    let timestamp: String
}

struct VoipPushData: Decodable {
    let uuid: String
    let handle: String
    let hasVideo: Bool
    let callerName: String?
    let customData: [String: String]
}

class CallKitPlugin: Plugin, CXProviderDelegate, PKPushRegistryDelegate {
    
    // Helper to convert [String: Any] to JSObject
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
    private var provider: CXProvider?
    private var callController = CXCallController()
    private var activeCalls: [UUID: CallInfo] = [:]
    private var voipRegistry: PKPushRegistry?
    private let iso8601Formatter = ISO8601DateFormatter()
    
    struct CallInfo {
        let uuid: UUID
        let handle: CXHandle
        let outgoing: Bool
        var hasConnected: Bool = false
        var hasEnded: Bool = false
        var onHold: Bool = false
        var isMuted: Bool = false
        var startTime: Date?
        var endTime: Date?
    }
    
    override init() {
        super.init()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
    @objc public func setProviderConfiguration(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(ProviderConfigData.self)
        
        let config = CXProviderConfiguration(localizedName: args.localizedName)
        config.maximumCallGroups = args.maximumCallGroups
        config.maximumCallsPerCallGroup = args.maximumCallsPerGroup
        config.supportsVideo = args.supportsVideo
        // includeCallsInRecents is deprecated/not available
        // config.includeCallsInRecents = args.includeCallsInRecents
        
        if let ringtone = args.ringtoneSound {
            config.ringtoneSound = ringtone
        }
        
        if let iconBase64 = args.iconTemplateImage,
           let iconData = Data(base64Encoded: iconBase64),
           let icon = UIImage(data: iconData) {
            config.iconTemplateImageData = icon.pngData()
        }
        
        var handleTypes: Set<CXHandle.HandleType> = []
        for type in args.supportedHandleTypes {
            switch type {
            case "phoneNumber":
                handleTypes.insert(.phoneNumber)
            case "emailAddress":
                handleTypes.insert(.emailAddress)
            default:
                handleTypes.insert(.generic)
            }
        }
        config.supportedHandleTypes = handleTypes
        
        provider = CXProvider(configuration: config)
        provider?.setDelegate(self, queue: nil)
        
        invoke.resolve()
    }
    
    @objc public func configureAudioSession(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(AudioSessionConfigData.self)
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            let category = parseAudioCategory(args.category)
            let mode = parseAudioMode(args.mode)
            let options = parseAudioOptions(args.options)
            
            try session.setCategory(category, mode: mode, options: options)
            try session.setActive(true)
            
            invoke.resolve()
        } catch {
            invoke.reject("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    @objc public func reportIncomingCall(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(IncomingCallData.self)
        
        guard let provider = provider else {
            invoke.reject("Provider not configured")
            return
        }
        
        guard let uuid = UUID(uuidString: args.uuid) else {
            invoke.reject("Invalid UUID")
            return
        }
        
        let handle = CXHandle(type: parseHandleType(args.handle.handleType), value: args.handle.value)
        
        let update = CXCallUpdate()
        update.remoteHandle = handle
        update.hasVideo = args.hasVideo
        update.localizedCallerName = args.callerName
        update.supportsDTMF = args.supportsDtmf
        update.supportsHolding = args.supportsHolding
        update.supportsGrouping = args.supportsGrouping
        update.supportsUngrouping = args.supportsUngrouping
        
        provider.reportNewIncomingCall(with: uuid, update: update) { [weak self] error in
            if let error = error {
                invoke.reject("Failed to report incoming call: \(error.localizedDescription)")
            } else {
                self?.activeCalls[uuid] = CallInfo(
                    uuid: uuid,
                    handle: handle,
                    outgoing: false
                )
                invoke.resolve()
            }
        }
    }
    
    @objc public func reportOutgoingCall(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(OutgoingCallData.self)
        
        guard let uuid = UUID(uuidString: args.uuid) else {
            invoke.reject("Invalid UUID")
            return
        }
        
        let handle = CXHandle(type: parseHandleType(args.handle.handleType), value: args.handle.value)
        
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = args.hasVideo
        startCallAction.contactIdentifier = args.contactIdentifier
        
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                invoke.reject("Failed to start outgoing call: \(error.localizedDescription)")
            } else {
                self?.activeCalls[uuid] = CallInfo(
                    uuid: uuid,
                    handle: handle,
                    outgoing: true
                )
                invoke.resolve()
            }
        }
    }
    
    @objc public func endCall(_ invoke: Invoke) throws {
        struct EndCallArgs: Decodable {
            let uuid: String
            let reason: String?
        }
        
        let args = try invoke.parseArgs(EndCallArgs.self)
        
        guard let uuid = UUID(uuidString: args.uuid) else {
            invoke.reject("Invalid UUID")
            return
        }
        
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                invoke.reject("Failed to end call: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func setHeld(_ invoke: Invoke) throws {
        struct SetHeldArgs: Decodable {
            let uuid: String
            let onHold: Bool
        }
        
        let args = try invoke.parseArgs(SetHeldArgs.self)
        
        guard let uuid = UUID(uuidString: args.uuid) else {
            invoke.reject("Invalid UUID")
            return
        }
        
        let setHeldAction = CXSetHeldCallAction(call: uuid, onHold: args.onHold)
        let transaction = CXTransaction(action: setHeldAction)
        
        callController.request(transaction) { error in
            if let error = error {
                invoke.reject("Failed to set call held state: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func setMuted(_ invoke: Invoke) throws {
        struct SetMutedArgs: Decodable {
            let uuid: String
            let muted: Bool
        }
        
        let args = try invoke.parseArgs(SetMutedArgs.self)
        
        guard let uuid = UUID(uuidString: args.uuid) else {
            invoke.reject("Invalid UUID")
            return
        }
        
        let setMutedAction = CXSetMutedCallAction(call: uuid, muted: args.muted)
        let transaction = CXTransaction(action: setMutedAction)
        
        callController.request(transaction) { error in
            if let error = error {
                invoke.reject("Failed to set mute state: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func answerCall(_ invoke: Invoke) throws {
        struct AnswerCallArgs: Decodable {
            let uuid: String
        }
        
        let args = try invoke.parseArgs(AnswerCallArgs.self)
        
        guard let uuid = UUID(uuidString: args.uuid) else {
            invoke.reject("Invalid UUID")
            return
        }
        
        let answerAction = CXAnswerCallAction(call: uuid)
        let transaction = CXTransaction(action: answerAction)
        
        callController.request(transaction) { error in
            if let error = error {
                invoke.reject("Failed to answer call: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func reportCallUpdate(_ invoke: Invoke) throws {
        struct UpdateArgs: Decodable {
            let uuid: String
            let update: CallUpdateData
        }
        
        let args = try invoke.parseArgs(UpdateArgs.self)
        
        guard let provider = provider else {
            invoke.reject("Provider not configured")
            return
        }
        
        guard let uuid = UUID(uuidString: args.uuid) else {
            invoke.reject("Invalid UUID")
            return
        }
        
        let update = CXCallUpdate()
        
        if let handleData = args.update.remoteHandle {
            update.remoteHandle = CXHandle(
                type: parseHandleType(handleData.handleType),
                value: handleData.value
            )
        }
        
        if let callerName = args.update.localizedCallerName {
            update.localizedCallerName = callerName
        }
        
        if let dtmf = args.update.supportsDtmf {
            update.supportsDTMF = dtmf
        }
        
        if let holding = args.update.supportsHolding {
            update.supportsHolding = holding
        }
        
        if let grouping = args.update.supportsGrouping {
            update.supportsGrouping = grouping
        }
        
        if let ungrouping = args.update.supportsUngrouping {
            update.supportsUngrouping = ungrouping
        }
        
        if let video = args.update.hasVideo {
            update.hasVideo = video
        }
        
        provider.reportCall(with: uuid, updated: update)
        invoke.resolve()
    }
    
    @objc public func getActiveCalls(_ invoke: Invoke) throws {
        var calls: [[String: Any]] = []
        
        for (uuid, callInfo) in activeCalls {
            var call: [String: Any] = [
                "uuid": uuid.uuidString,
                "handle": [
                    "handleType": handleTypeToString(callInfo.handle.type),
                    "value": callInfo.handle.value
                ],
                "outgoing": callInfo.outgoing,
                "hasConnected": callInfo.hasConnected,
                "hasEnded": callInfo.hasEnded,
                "onHold": callInfo.onHold,
                "isMuted": callInfo.isMuted
            ]
            
            if let startTime = callInfo.startTime {
                call["startTime"] = iso8601Formatter.string(from: startTime)
            }
            
            if let endTime = callInfo.endTime {
                call["endTime"] = iso8601Formatter.string(from: endTime)
            }
            
            calls.append(call)
        }
        
        invoke.resolve(["calls": calls])
    }
    
    @objc public func registerForVoipNotifications(_ invoke: Invoke) throws {
        voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry?.delegate = self
        voipRegistry?.desiredPushTypes = [.voIP]
        
        // Return dummy token for now
        invoke.resolve("voip-push-token-placeholder")
    }
    
    @objc public func checkCallCapability(_ invoke: Invoke) throws {
        let capability: [String: Any] = [
            "canMakeCalls": true,
            "canReceiveCalls": true,
            "supportsVideo": true,
            "supportsVoip": true,
            "cellularProvider": NSNull()
        ]
        
        invoke.resolve(capability)
    }
    
    @objc public func getAudioRoutes(_ invoke: Invoke) throws {
        let session = AVAudioSession.sharedInstance()
        let currentRoute = session.currentRoute
        
        var routes: [[String: Any]] = []
        
        for output in currentRoute.outputs {
            let route: [String: Any] = [
                "name": output.portName,
                "routeType": portTypeToString(output.portType),
                "isSelected": true
            ]
            routes.append(route)
        }
        
        invoke.resolve(["routes": routes])
    }
    
    @objc public func setAudioRoute(_ invoke: Invoke) throws {
        struct SetRouteArgs: Decodable {
            let routeType: String
        }
        
        let args = try invoke.parseArgs(SetRouteArgs.self)
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            switch args.routeType {
            case "builtInSpeaker":
                try session.overrideOutputAudioPort(.speaker)
            case "builtInReceiver":
                try session.overrideOutputAudioPort(.none)
            default:
                // Other routes handled by system
                break
            }
            
            invoke.resolve()
        } catch {
            invoke.reject("Failed to set audio route: \(error.localizedDescription)")
        }
    }
    
    @objc public func startCallAudio(_ invoke: Invoke) throws {
        struct StartAudioArgs: Decodable {
            let uuid: String
        }
        
        let _ = try invoke.parseArgs(StartAudioArgs.self)
        
        // Audio is typically started automatically
        invoke.resolve()
    }
    
    @objc public func setGroup(_ invoke: Invoke) throws {
        struct SetGroupArgs: Decodable {
            let uuid: String
            let groupUuid: String?
        }
        
        let args = try invoke.parseArgs(SetGroupArgs.self)
        
        guard let uuid = UUID(uuidString: args.uuid) else {
            invoke.reject("Invalid UUID")
            return
        }
        
        let groupUuid = args.groupUuid.flatMap { UUID(uuidString: $0) }
        
        let action = CXSetGroupCallAction(call: uuid, callUUIDToGroupWith: groupUuid)
        let transaction = CXTransaction(action: action)
        
        callController.request(transaction) { error in
            if let error = error {
                invoke.reject("Failed to set group: \(error.localizedDescription)")
            } else {
                invoke.resolve()
            }
        }
    }
    
    @objc public func setOnHold(_ invoke: Invoke) throws {
        // Alias for setHeld
        try setHeld(invoke)
    }
    
    @objc public func getCallState(_ invoke: Invoke) throws {
        struct GetStateArgs: Decodable {
            let uuid: String
        }
        
        let args = try invoke.parseArgs(GetStateArgs.self)
        
        guard let uuid = UUID(uuidString: args.uuid),
              let callInfo = activeCalls[uuid] else {
            invoke.reject("Call not found")
            return
        }
        
        let state: String
        if callInfo.hasEnded {
            state = "disconnected"
        } else if callInfo.onHold {
            state = "held"
        } else if callInfo.hasConnected {
            state = "connected"
        } else if callInfo.outgoing {
            state = "dialing"
        } else {
            state = "incoming"
        }
        
        invoke.resolve(state)
    }
    
    @objc public func requestTransaction(_ invoke: Invoke) throws {
        let _ = try invoke.parseArgs(TransactionData.self)
        
        // Transaction handling would be implemented based on action type
        invoke.resolve()
    }
    
    @objc public func reportAudioRouteChange(_ invoke: Invoke) throws {
        // Audio route changes are handled by the system
        invoke.resolve()
    }
    
    @objc public func invalidatePushToken(_ invoke: Invoke) throws {
        voipRegistry?.desiredPushTypes = nil
        voipRegistry = nil
        invoke.resolve()
    }
    
    @objc public func reportNewIncomingVoipPush(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(VoipPushData.self)
        
        // Convert to incoming call
        let _ = IncomingCallData(
            uuid: args.uuid,
            handle: CallHandleData(handleType: "phoneNumber", value: args.handle),
            hasVideo: args.hasVideo,
            callerName: args.callerName,
            supportsDtmf: true,
            supportsHolding: true,
            supportsGrouping: true,
            supportsUngrouping: true
        )
        
        // Report as incoming call
        try reportIncomingCall(invoke)
    }
    
    // MARK: - CXProviderDelegate
    
    func providerDidReset(_ provider: CXProvider) {
        activeCalls.removeAll()
        trigger("providerReset", data: [:])
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        if let callInfo = activeCalls[action.callUUID] {
            var updatedInfo = callInfo
            updatedInfo.startTime = Date()
            activeCalls[action.callUUID] = updatedInfo
        }
        
        action.fulfill()
        
        trigger("callStarted", data: ["uuid": action.callUUID.uuidString])
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        if let callInfo = activeCalls[action.callUUID] {
            var updatedInfo = callInfo
            updatedInfo.hasConnected = true
            updatedInfo.startTime = Date()
            activeCalls[action.callUUID] = updatedInfo
        }
        
        action.fulfill()
        
        trigger("callAnswered", data: ["uuid": action.callUUID.uuidString])
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        if let callInfo = activeCalls[action.callUUID] {
            var updatedInfo = callInfo
            updatedInfo.hasEnded = true
            updatedInfo.endTime = Date()
            activeCalls[action.callUUID] = updatedInfo
        }
        
        action.fulfill()
        
        trigger("callEnded", data: ["uuid": action.callUUID.uuidString])
        
        // Remove from active calls after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.activeCalls.removeValue(forKey: action.callUUID)
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        if let callInfo = activeCalls[action.callUUID] {
            var updatedInfo = callInfo
            updatedInfo.onHold = action.isOnHold
            activeCalls[action.callUUID] = updatedInfo
        }
        
        action.fulfill()
        
        trigger("callHeld", data: [
            "uuid": action.callUUID.uuidString,
            "onHold": action.isOnHold
        ])
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        if let callInfo = activeCalls[action.callUUID] {
            var updatedInfo = callInfo
            updatedInfo.isMuted = action.isMuted
            activeCalls[action.callUUID] = updatedInfo
        }
        
        action.fulfill()
        
        trigger("callMuted", data: [
            "uuid": action.callUUID.uuidString,
            "muted": action.isMuted
        ])
    }
    
    // MARK: - PKPushRegistryDelegate
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if type == .voIP {
            let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
            trigger("voipTokenUpdated", data: ["token": token])
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        if type == .voIP {
            // Convert payload to JSObject
            var jsPayload: JSObject = [:]
            for (key, value) in payload.dictionaryPayload {
                if let stringKey = key as? String {
                    if let str = value as? String {
                        jsPayload[stringKey] = str
                    } else if let num = value as? NSNumber {
                        jsPayload[stringKey] = num.doubleValue
                    } else if let bool = value as? Bool {
                        jsPayload[stringKey] = bool
                    } else if let dict = value as? [String: Any] {
                        jsPayload[stringKey] = convertToJSObject(dict)
                    } else if let array = value as? [Any] {
                        jsPayload[stringKey] = array
                    }
                }
            }
            trigger("voipPushReceived", data: ["payload": jsPayload])
        }
        completion()
    }
    
    // MARK: - Helpers
    
    private func parseHandleType(_ type: String) -> CXHandle.HandleType {
        switch type {
        case "phoneNumber":
            return .phoneNumber
        case "emailAddress":
            return .emailAddress
        default:
            return .generic
        }
    }
    
    private func handleTypeToString(_ type: CXHandle.HandleType) -> String {
        switch type {
        case .phoneNumber:
            return "phoneNumber"
        case .emailAddress:
            return "emailAddress"
        default:
            return "generic"
        }
    }
    
    private func parseAudioCategory(_ category: String) -> AVAudioSession.Category {
        switch category {
        case "ambient":
            return .ambient
        case "soloAmbient":
            return .soloAmbient
        case "playback":
            return .playback
        case "record":
            return .record
        case "playAndRecord":
            return .playAndRecord
        case "multiRoute":
            return .multiRoute
        default:
            return .playAndRecord
        }
    }
    
    private func parseAudioMode(_ mode: String) -> AVAudioSession.Mode {
        switch mode {
        case "default":
            return .default
        case "voiceChat":
            return .voiceChat
        case "videoChat":
            return .videoChat
        case "gameChat":
            return .gameChat
        case "videoRecording":
            return .videoRecording
        case "measurement":
            return .measurement
        case "moviePlayback":
            return .moviePlayback
        case "spokenAudio":
            return .spokenAudio
        default:
            return .voiceChat
        }
    }
    
    private func parseAudioOptions(_ options: [String]) -> AVAudioSession.CategoryOptions {
        var categoryOptions: AVAudioSession.CategoryOptions = []
        
        for option in options {
            switch option {
            case "mixWithOthers":
                categoryOptions.insert(.mixWithOthers)
            case "duckOthers":
                categoryOptions.insert(.duckOthers)
            case "allowBluetooth":
                categoryOptions.insert(.allowBluetooth)
            case "defaultToSpeaker":
                categoryOptions.insert(.defaultToSpeaker)
            case "interruptSpokenAudioAndMixWithOthers":
                categoryOptions.insert(.interruptSpokenAudioAndMixWithOthers)
            case "allowBluetoothA2dp":
                categoryOptions.insert(.allowBluetoothA2DP)
            case "allowAirPlay":
                categoryOptions.insert(.allowAirPlay)
            case "overrideMutedMicrophoneInterruption":
                if #available(iOS 14.5, *) {
                    categoryOptions.insert(.overrideMutedMicrophoneInterruption)
                }
            default:
                break
            }
        }
        
        return categoryOptions
    }
    
    private func portTypeToString(_ portType: AVAudioSession.Port) -> String {
        switch portType {
        case .builtInReceiver:
            return "builtInReceiver"
        case .builtInSpeaker:
            return "builtInSpeaker"
        case .bluetoothA2DP:
            return "bluetoothA2dp"
        case .bluetoothHFP:
            return "bluetoothHfp"
        case .bluetoothLE:
            return "bluetoothLe"
        case .carAudio:
            return "carAudio"
        case .headphones:
            return "wired"
        case .airPlay:
            return "airPlay"
        default:
            return "unknown"
        }
    }
}

@_cdecl("init_plugin_ios_callkit")
func initPlugin() -> Plugin {
    return CallKitPlugin()
}