import Tauri
import WebKit
import AVFoundation
import UIKit
import CoreAudioTypes

struct RecordingOptions: Decodable {
    let format: String?
    let quality: String?
    let sampleRate: Double?
    let channels: Int?
    let bitRate: Int?
    let maxDuration: Double?
    let silenceDetection: Bool
    let noiseSuppression: Bool
    let echoCancellation: Bool
}

class MicrophonePlugin: Plugin {
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var levelTimer: Timer?
    private var recordingStartTime: Date?
    private var pausedTime: TimeInterval = 0
    private var isPaused = false
    private var recordingState = "idle"
    private var currentSessionId: String?
    private var maxDuration: Double?
    private var durationTimer: Timer?
    
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
    
    public override func load(webview: WKWebView) {
        super.load(webview: webview)
        setupAudioSession()
    }
    
    @objc public override func checkPermissions(_ invoke: Invoke) {
        let status = AVAudioSession.sharedInstance().recordPermission
        let permissionState = recordPermissionToString(status)
        invoke.resolve(["microphone": permissionState])
    }
    
    @objc public override func requestPermissions(_ invoke: Invoke) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            let permissionState = granted ? "granted" : "denied"
            invoke.resolve(["microphone": permissionState])
        }
    }
    
    @objc public func startRecording(_ invoke: Invoke) {
        guard AVAudioSession.sharedInstance().recordPermission == .granted else {
            invoke.reject("Microphone access denied")
            return
        }
        
        guard recordingState == "idle" else {
            invoke.reject("Already recording")
            return
        }
        
        let options = try? invoke.parseArgs(RecordingOptions.self)
        
        let fileName = "REC_\(UUID().uuidString).\(getFileExtension(for: options?.format))"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        let settings = createRecordingSettings(options: options)
        
        do {
            // Configure audio session
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            
            // Apply audio processing options
            if let options = options {
                if options.noiseSuppression {
                    try audioSession.setMode(.voiceChat)
                }
            }
            
            // Create recorder
            audioRecorder = try AVAudioRecorder(url: tempURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            // Start recording
            audioRecorder?.record()
            
            recordingState = "recording"
            recordingStartTime = Date()
            currentSessionId = UUID().uuidString
            maxDuration = options?.maxDuration
            
            // Start level monitoring
            startLevelMonitoring()
            
            // Start duration timer if max duration is set
            if let maxDuration = maxDuration {
                durationTimer = Timer.scheduledTimer(withTimeInterval: maxDuration, repeats: false) { _ in
                    self.stopRecordingInternal { result in
                        if let result = result {
                            self.trigger("maxDurationReached", data: self.convertToJSObject(result))
                        } else {
                            self.trigger("maxDurationReached", data: [:] as JSObject)
                        }
                    }
                }
            }
            
            let session: [String: Any] = [
                "id": currentSessionId!,
                "startTime": ISO8601DateFormatter().string(from: recordingStartTime!),
                "format": options?.format ?? "m4a",
                "sampleRate": settings[AVSampleRateKey] as? Double ?? 44100,
                "channels": settings[AVNumberOfChannelsKey] as? Int ?? 1,
                "bitRate": settings[AVEncoderBitRateKey] as? Int ?? 128000
            ]
            
            invoke.resolve(session)
            trigger("recordingStarted", data: convertToJSObject(session))
            
        } catch {
            invoke.reject("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    @objc public func stopRecording(_ invoke: Invoke) {
        guard recordingState != "idle" else {
            invoke.reject("No recording in progress")
            return
        }
        
        stopRecordingInternal { result in
            if let result = result {
                invoke.resolve(result)
            } else {
                invoke.reject("Failed to stop recording")
            }
        }
    }
    
    @objc public func pauseRecording(_ invoke: Invoke) {
        guard recordingState == "recording" else {
            invoke.reject("No active recording to pause")
            return
        }
        
        audioRecorder?.pause()
        isPaused = true
        recordingState = "paused"
        
        if let startTime = recordingStartTime {
            pausedTime += Date().timeIntervalSince(startTime)
        }
        
        invoke.resolve()
        trigger("recordingPaused", data: [:] as JSObject)
    }
    
    @objc public func resumeRecording(_ invoke: Invoke) {
        guard recordingState == "paused" else {
            invoke.reject("No paused recording to resume")
            return
        }
        
        audioRecorder?.record()
        isPaused = false
        recordingState = "recording"
        recordingStartTime = Date()
        
        invoke.resolve()
        trigger("recordingResumed", data: [:] as JSObject)
    }
    
    @objc public func getRecordingState(_ invoke: Invoke) {
        invoke.resolve(recordingState)
    }
    
    @objc public func getAudioLevels(_ invoke: Invoke) {
        guard let recorder = audioRecorder, recorder.isRecording else {
            invoke.resolve([
                "peakLevel": 0.0,
                "averageLevel": 0.0,
                "isClipping": false
            ])
            return
        }
        
        recorder.updateMeters()
        let peakLevel = normalizeLevel(recorder.peakPower(forChannel: 0))
        let averageLevel = normalizeLevel(recorder.averagePower(forChannel: 0))
        
        invoke.resolve([
            "peakLevel": peakLevel,
            "averageLevel": averageLevel,
            "isClipping": peakLevel > 0.95
        ])
    }
    
    @objc public func getAvailableInputs(_ invoke: Invoke) {
        var inputs: [[String: Any]] = []
        
        if let availableInputs = audioSession.availableInputs {
            for input in availableInputs {
                let portType = portTypeToString(input.portType)
                inputs.append([
                    "id": input.uid,
                    "name": input.portName,
                    "portType": portType,
                    "isDefault": input == audioSession.preferredInput,
                    "channels": input.channels?.count ?? 0,
                    "sampleRate": audioSession.sampleRate
                ])
            }
        }
        
        // Convert the array to a dictionary response
        invoke.resolve(["inputs": inputs])
    }
    
    @objc public func setAudioInput(_ invoke: Invoke) {
        struct SetInputArgs: Decodable {
            let inputId: String
        }
        
        guard let args = try? invoke.parseArgs(SetInputArgs.self) else {
            invoke.reject("Invalid arguments")
            return
        }
        
        guard let availableInputs = audioSession.availableInputs else {
            invoke.reject("No inputs available")
            return
        }
        
        guard let input = availableInputs.first(where: { $0.uid == args.inputId }) else {
            invoke.reject("Audio input not found")
            return
        }
        
        do {
            try audioSession.setPreferredInput(input)
            invoke.resolve()
            trigger("inputChanged", data: ["inputId": args.inputId] as JSObject)
        } catch {
            invoke.reject("Failed to set audio input: \(error.localizedDescription)")
        }
    }
    
    @objc public func getRecordingDuration(_ invoke: Invoke) {
        guard recordingState != "idle" else {
            invoke.resolve(0.0)
            return
        }
        
        var duration: TimeInterval = pausedTime
        if let startTime = recordingStartTime, !isPaused {
            duration += Date().timeIntervalSince(startTime)
        }
        
        invoke.resolve(duration)
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func createRecordingSettings(options: RecordingOptions?) -> [String: Any] {
        var settings: [String: Any] = [:]
        
        // Format
        let format = getAudioFormat(options?.format)
        settings[AVFormatIDKey] = format
        
        // Sample rate
        let sampleRate = options?.sampleRate ?? 44100
        settings[AVSampleRateKey] = sampleRate
        
        // Channels
        let channels = options?.channels ?? 1
        settings[AVNumberOfChannelsKey] = channels
        
        // Quality and bit rate
        let quality = getAudioQuality(options?.quality)
        settings[AVEncoderAudioQualityKey] = quality
        
        if let bitRate = options?.bitRate {
            settings[AVEncoderBitRateKey] = bitRate
        } else {
            // Set default bit rate based on quality
            settings[AVEncoderBitRateKey] = getDefaultBitRate(for: options?.quality)
        }
        
        return settings
    }
    
    private func getAudioFormat(_ format: String?) -> Int {
        switch format?.lowercased() {
        case "wav":
            return Int(kAudioFormatLinearPCM)
        case "caf":
            return Int(kAudioFormatAppleLossless)
        case "aiff":
            return Int(kAudioFormatAppleIMA4)
        case "mp3":
            return Int(kAudioFormatMPEGLayer3)
        default:
            return Int(kAudioFormatMPEG4AAC)
        }
    }
    
    private func getFileExtension(for format: String?) -> String {
        switch format?.lowercased() {
        case "wav":
            return "wav"
        case "caf":
            return "caf"
        case "aiff":
            return "aiff"
        case "mp3":
            return "mp3"
        default:
            return "m4a"
        }
    }
    
    private func getAudioQuality(_ quality: String?) -> Int {
        switch quality?.lowercased() {
        case "low":
            return AVAudioQuality.low.rawValue
        case "medium":
            return AVAudioQuality.medium.rawValue
        case "lossless":
            return AVAudioQuality.max.rawValue
        default:
            return AVAudioQuality.high.rawValue
        }
    }
    
    private func getDefaultBitRate(for quality: String?) -> Int {
        switch quality?.lowercased() {
        case "low":
            return 64000
        case "medium":
            return 128000
        case "lossless":
            return 320000
        default:
            return 256000
        }
    }
    
    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let recorder = self.audioRecorder, recorder.isRecording else { return }
            
            recorder.updateMeters()
            let peakLevel = self.normalizeLevel(recorder.peakPower(forChannel: 0))
            let averageLevel = self.normalizeLevel(recorder.averagePower(forChannel: 0))
            
            self.trigger("levelUpdate", data: [
                "peakLevel": peakLevel,
                "averageLevel": averageLevel,
                "isClipping": peakLevel > 0.95
            ] as JSObject)
        }
    }
    
    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
    
    private func normalizeLevel(_ level: Float) -> Float {
        // Convert dB to linear scale (0.0 to 1.0)
        let minDb: Float = -60
        let normalized = (level - minDb) / -minDb
        return max(0, min(1, normalized))
    }
    
    private func stopRecordingInternal(completion: @escaping ([String: Any]?) -> Void) {
        guard let recorder = audioRecorder else {
            completion(nil)
            return
        }
        
        let url = recorder.url
        recorder.stop()
        
        recordingState = "idle"
        stopLevelMonitoring()
        durationTimer?.invalidate()
        durationTimer = nil
        
        var duration: TimeInterval = pausedTime
        if let startTime = recordingStartTime, !isPaused {
            duration += Date().timeIntervalSince(startTime)
        }
        
        // Get file info
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? UInt64 ?? 0
            
            let result: [String: Any] = [
                "path": url.path,
                "duration": duration,
                "size": fileSize,
                "format": url.pathExtension,
                "sampleRate": audioSession.sampleRate,
                "channels": recorder.format.channelCount,
                "bitRate": 128000, // This would need to be tracked from settings
                "peakLevel": 0.0,
                "averageLevel": 0.0
            ]
            
            // Reset state
            audioRecorder = nil
            recordingStartTime = nil
            pausedTime = 0
            isPaused = false
            currentSessionId = nil
            
            completion(result)
            trigger("recordingStopped", data: convertToJSObject(result))
            
        } catch {
            completion(nil)
        }
    }
    
    private func recordPermissionToString(_ permission: AVAudioSession.RecordPermission) -> String {
        switch permission {
        case .undetermined:
            return "prompt"
        case .denied:
            return "denied"
        case .granted:
            return "granted"
        @unknown default:
            return "denied"
        }
    }
    
    private func portTypeToString(_ portType: AVAudioSession.Port) -> String {
        switch portType {
        case .builtInMic:
            return "builtInMic"
        case .headsetMic:
            return "headsetMic"
        case .usbAudio:
            return "usbAudio"
        case .bluetoothHFP:
            return "bluetoothHFP"
        case .carAudio:
            return "carAudio"
        case .lineIn:
            return "lineIn"
        default:
            return "other"
        }
    }
}

// MARK: - AVAudioRecorderDelegate

extension MicrophonePlugin: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            trigger("recordingError", data: ["error": "Recording finished unsuccessfully"] as JSObject)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            trigger("recordingError", data: ["error": error.localizedDescription] as JSObject)
        }
    }
}

@_cdecl("init_plugin_ios_microphone")
func initPlugin() -> Plugin {
    return MicrophonePlugin()
}