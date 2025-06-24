import Tauri
import UIKit
import AVFoundation
import Photos
import PhotosUI
import MobileCoreServices

struct PhotoOptions: Decodable {
    let cameraPosition: String?
    let quality: String?
    let allowEditing: Bool
    let saveToGallery: Bool
    let flashMode: String?
    let maxWidth: Int?
    let maxHeight: Int?
}

struct VideoOptions: Decodable {
    let cameraPosition: String?
    let quality: String?
    let maxDuration: Int?
    let saveToGallery: Bool
    let flashMode: String?
}

struct PickerOptions: Decodable {
    let allowMultiple: Bool
    let includeMetadata: Bool
    let limit: Int?
    let mediaTypes: [String]?
}

struct PermissionRequest: Decodable {
    let camera: Bool
    let photoLibrary: Bool
    let microphone: Bool
}

class CameraPlugin: Plugin {
    private var currentImagePickerController: UIImagePickerController?
    private var currentPHPickerController: PHPickerViewController?
    private var pendingInvoke: Invoke?
    private var captureOptions: Any?
    
    @objc public func checkPermissions(_ invoke: Invoke) throws {
        var permissions: [String: String] = [:]
        
        // Camera permission
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        permissions["camera"] = authorizationStatusToString(cameraStatus)
        
        // Photo library permission
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        permissions["photoLibrary"] = photoAuthorizationStatusToString(photoStatus)
        
        // Microphone permission
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        permissions["microphone"] = authorizationStatusToString(micStatus)
        
        invoke.resolve(permissions)
    }
    
    @objc public func requestPermissions(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(PermissionRequest.self)
        
        let group = DispatchGroup()
        var permissions: [String: String] = [:]
        
        if args.camera {
            group.enter()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                permissions["camera"] = granted ? "granted" : "denied"
                group.leave()
            }
        }
        
        if args.photoLibrary {
            group.enter()
            PHPhotoLibrary.requestAuthorization { status in
                permissions["photoLibrary"] = self.photoAuthorizationStatusToString(status)
                group.leave()
            }
        }
        
        if args.microphone {
            group.enter()
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                permissions["microphone"] = granted ? "granted" : "denied"
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            invoke.resolve(permissions)
        }
    }
    
    @objc public func takePhoto(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(PhotoOptions.self)
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            invoke.reject("Camera access denied")
            return
        }
        
        DispatchQueue.main.async {
            self.pendingInvoke = invoke
            self.captureOptions = args
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.allowsEditing = args?.allowEditing ?? false
            
            // Set camera position
            if let position = args?.cameraPosition {
                switch position {
                case "front":
                    picker.cameraDevice = .front
                case "back":
                    picker.cameraDevice = .rear
                default:
                    break
                }
            }
            
            // Set flash mode
            if let flashMode = args?.flashMode {
                switch flashMode {
                case "on":
                    picker.cameraFlashMode = .on
                case "off":
                    picker.cameraFlashMode = .off
                case "auto":
                    picker.cameraFlashMode = .auto
                default:
                    break
                }
            }
            
            self.currentImagePickerController = picker
            self.presentViewController(picker)
        }
    }
    
    @objc public func recordVideo(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(VideoOptions.self)
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            invoke.reject("Camera access denied")
            return
        }
        
        DispatchQueue.main.async {
            self.pendingInvoke = invoke
            self.captureOptions = args
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.videoQuality = self.parseVideoQuality(args?.quality)
            
            if let maxDuration = args?.maxDuration {
                picker.videoMaximumDuration = TimeInterval(maxDuration)
            }
            
            // Set camera position
            if let position = args?.cameraPosition {
                switch position {
                case "front":
                    picker.cameraDevice = .front
                case "back":
                    picker.cameraDevice = .rear
                default:
                    break
                }
            }
            
            self.currentImagePickerController = picker
            self.presentViewController(picker)
        }
    }
    
    @objc public func pickImage(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(PickerOptions.self)
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Photo library access denied")
            return
        }
        
        DispatchQueue.main.async {
            self.pendingInvoke = invoke
            self.captureOptions = args
            
            var config = PHPickerConfiguration()
            config.selectionLimit = args?.allowMultiple ?? false ? (args?.limit ?? 0) : 1
            config.filter = .images
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            
            self.currentPHPickerController = picker
            self.presentViewController(picker)
        }
    }
    
    @objc public func pickVideo(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(PickerOptions.self)
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Photo library access denied")
            return
        }
        
        DispatchQueue.main.async {
            self.pendingInvoke = invoke
            self.captureOptions = args
            
            var config = PHPickerConfiguration()
            config.selectionLimit = args?.allowMultiple ?? false ? (args?.limit ?? 0) : 1
            config.filter = .videos
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            
            self.currentPHPickerController = picker
            self.presentViewController(picker)
        }
    }
    
    @objc public func getCameraInfo(_ invoke: Invoke) throws {
        var cameras: [[String: Any]] = []
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        for device in discoverySession.devices {
            var info: [String: Any] = [
                "id": device.uniqueID,
                "name": device.localizedName,
                "position": positionToString(device.position),
                "hasFlash": device.hasFlash,
                "hasTorch": device.hasTorch,
                "maxZoom": device.maxAvailableVideoZoomFactor,
                "minZoom": device.minAvailableVideoZoomFactor,
                "supportsVideo": true,
                "supportsPhoto": true
            ]
            
            cameras.append(info)
        }
        
        invoke.resolve(cameras)
    }
    
    // MARK: - Helper Methods
    
    private func presentViewController(_ viewController: UIViewController) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            self.pendingInvoke?.reject("Unable to present camera")
            return
        }
        
        rootViewController.present(viewController, animated: true)
    }
    
    private func processImage(_ image: UIImage, options: PhotoOptions?) -> [String: Any]? {
        var processedImage = image
        
        // Resize if needed
        if let maxWidth = options?.maxWidth, let maxHeight = options?.maxHeight {
            processedImage = resizeImage(image, maxWidth: CGFloat(maxWidth), maxHeight: CGFloat(maxHeight))
        }
        
        // Convert to JPEG
        let quality = parseImageQuality(options?.quality)
        guard let imageData = processedImage.jpegData(compressionQuality: quality) else {
            return nil
        }
        
        // Save to temporary file
        let fileName = "IMG_\(UUID().uuidString).jpg"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: tempURL)
            
            // Save to gallery if requested
            if options?.saveToGallery ?? true {
                UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil)
            }
            
            return [
                "path": tempURL.path,
                "width": Int(processedImage.size.width),
                "height": Int(processedImage.size.height),
                "size": imageData.count,
                "mimeType": "image/jpeg"
            ]
        } catch {
            return nil
        }
    }
    
    private func processVideo(_ url: URL, options: VideoOptions?) -> [String: Any]? {
        let asset = AVAsset(url: url)
        
        // Get video dimensions
        var width = 0
        var height = 0
        if let track = asset.tracks(withMediaType: .video).first {
            let size = track.naturalSize.applying(track.preferredTransform)
            width = Int(abs(size.width))
            height = Int(abs(size.height))
        }
        
        // Get duration
        let duration = CMTimeGetSeconds(asset.duration)
        
        // Get file size
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
        
        // Copy to app's temporary directory
        let fileName = "VID_\(UUID().uuidString).mp4"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: url, to: tempURL)
            
            // Save to gallery if requested
            if options?.saveToGallery ?? true {
                UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
            }
            
            return [
                "path": tempURL.path,
                "width": width,
                "height": height,
                "size": fileSize,
                "mimeType": "video/mp4",
                "duration": duration
            ]
        } catch {
            return nil
        }
    }
    
    private func resizeImage(_ image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let size = image.size
        let widthRatio = maxWidth / size.width
        let heightRatio = maxHeight / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    private func parseImageQuality(_ quality: String?) -> CGFloat {
        switch quality {
        case "low":
            return 0.25
        case "medium":
            return 0.5
        case "high":
            return 0.85
        case "original":
            return 1.0
        default:
            return 0.85
        }
    }
    
    private func parseVideoQuality(_ quality: String?) -> UIImagePickerController.QualityType {
        switch quality {
        case "low":
            return .typeLow
        case "medium":
            return .typeMedium
        case "high":
            return .typeHigh
        case "ultra":
            return .type3840x2160
        default:
            return .typeHigh
        }
    }
    
    private func authorizationStatusToString(_ status: AVAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "prompt"
        case .restricted, .denied:
            return "denied"
        case .authorized:
            return "granted"
        @unknown default:
            return "denied"
        }
    }
    
    private func photoAuthorizationStatusToString(_ status: PHAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "prompt"
        case .restricted, .denied:
            return "denied"
        case .authorized:
            return "granted"
        case .limited:
            return "granted" // iOS 14+ limited access
        @unknown default:
            return "denied"
        }
    }
    
    private func positionToString(_ position: AVCaptureDevice.Position) -> String {
        switch position {
        case .front:
            return "front"
        case .back:
            return "back"
        case .unspecified:
            return "external"
        @unknown default:
            return "external"
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CameraPlugin: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            // Handle photo
            if let result = processImage(image, options: captureOptions as? PhotoOptions) {
                pendingInvoke?.resolve(result)
            } else {
                pendingInvoke?.reject("Failed to process image")
            }
        } else if let videoURL = info[.mediaURL] as? URL {
            // Handle video
            if let result = processVideo(videoURL, options: captureOptions as? VideoOptions) {
                pendingInvoke?.resolve(result)
            } else {
                pendingInvoke?.reject("Failed to process video")
            }
        }
        
        cleanup()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        pendingInvoke?.reject("Cancelled")
        cleanup()
    }
    
    private func cleanup() {
        currentImagePickerController = nil
        currentPHPickerController = nil
        pendingInvoke = nil
        captureOptions = nil
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CameraPlugin: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if results.isEmpty {
            pendingInvoke?.reject("Cancelled")
            cleanup()
            return
        }
        
        let options = captureOptions as? PickerOptions
        var mediaItems: [[String: Any]] = []
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    if let image = object as? UIImage,
                       let processedResult = self?.processImage(image, options: nil) {
                        mediaItems.append(processedResult)
                    }
                    group.leave()
                }
            } else if result.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeMovie as String) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: kUTTypeMovie as String) { [weak self] url, error in
                    if let url = url,
                       let processedResult = self?.processVideo(url, options: nil) {
                        mediaItems.append(processedResult)
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.pendingInvoke?.resolve(mediaItems)
            self?.cleanup()
        }
    }
}

@_cdecl("init_plugin_ios_camera")
func initPlugin() -> Plugin {
    return CameraPlugin()
}