import Tauri
import Photos
import PhotosUI
import UIKit
import CoreLocation
import AVFoundation

struct PermissionArgs: Decodable {
    let accessLevel: String
}

struct AlbumQuery: Decodable {
    let albumTypes: [String]?
    let includeEmpty: Bool
    let includeHidden: Bool
    let includeSmartAlbums: Bool
}

struct AssetQuery: Decodable {
    let albumId: String?
    let mediaTypes: [String]?
    let mediaSubtypes: [String]?
    let startDate: String?
    let endDate: String?
    let isFavorite: Bool?
    let isHidden: Bool?
    let hasLocation: Bool?
    let burstOnly: Bool?
    let sortOrder: String?
    let limit: Int?
    let offset: Int?
}

struct SaveImageData: Decodable {
    let imageData: String
    let toAlbum: String?
    let metadata: ImageMetadata?
}

struct ImageMetadata: Decodable {
    let creationDate: String?
    let location: LocationData?
    // Note: exif data is not used in SaveImageData parsing
    // It's only used for metadata export which doesn't require Decodable
}

struct LocationData: Decodable {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
}

struct ExportOptions: Decodable {
    let imageFormat: String?
    let videoFormat: String?
    let quality: Float?
    let maxWidth: Int?
    let maxHeight: Int?
    let preserveMetadata: Bool
}

class PhotosPlugin: Plugin {
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    @objc public override func checkPermissions(_ invoke: Invoke) {
        let readWriteStatus: PHAuthorizationStatus
        let addOnlyStatus: PHAuthorizationStatus
        
        if #available(iOS 14, *) {
            readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            addOnlyStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            // For iOS < 14, use the standard authorization status
            let status = PHPhotoLibrary.authorizationStatus()
            readWriteStatus = status
            addOnlyStatus = status
        }
        
        invoke.resolve([
            "readWrite": authorizationStatusToString(readWriteStatus),
            "addOnly": authorizationStatusToString(addOnlyStatus)
        ])
    }
    
    @objc public override func requestPermissions(_ invoke: Invoke) {
        do {
            let args = try invoke.parseArgs(PermissionArgs.self)
            
            if #available(iOS 14, *) {
                let accessLevel: PHAccessLevel = args.accessLevel == "addOnly" ? .addOnly : .readWrite
                
                PHPhotoLibrary.requestAuthorization(for: accessLevel) { [weak self] status in
                    self?.checkPermissions(invoke)
                }
            } else {
                // For iOS < 14, use standard authorization
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    self?.checkPermissions(invoke)
                }
            }
        } catch {
            invoke.reject(error.localizedDescription)
        }
    }
    
    @objc public func getAlbums(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(AlbumQuery.self)
        
        let isAuthorized: Bool
        if #available(iOS 14, *) {
            isAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized ||
                          PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
        } else {
            isAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        }
        
        guard isAuthorized else {
            invoke.reject("Photos library access denied")
            return
        }
        
        var albums: [[String: Any]] = []
        
        // User albums
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        userAlbums.enumerateObjects { collection, _, _ in
            if !collection.localizedTitle!.isEmpty {
                albums.append(self.serializeAlbum(collection))
            }
        }
        
        // Smart albums
        if args?.includeSmartAlbums ?? true {
            let smartAlbums = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: .any,
                options: nil
            )
            smartAlbums.enumerateObjects { collection, _, _ in
                if let title = collection.localizedTitle, !title.isEmpty {
                    albums.append(self.serializeAlbum(collection))
                }
            }
        }
        
        // Filter empty albums if requested
        if !(args?.includeEmpty ?? true) {
            albums = albums.filter { ($0["assetCount"] as? Int ?? 0) > 0 }
        }
        
        invoke.resolve(["albums": albums])
    }
    
    @objc public func getAlbum(_ invoke: Invoke) throws {
        struct GetAlbumArgs: Decodable {
            let id: String
        }
        
        let args = try invoke.parseArgs(GetAlbumArgs.self)
        
        guard let collection = fetchAssetCollection(withId: args.id) else {
            invoke.reject("Album not found")
            return
        }
        
        invoke.resolve(serializeAlbum(collection))
    }
    
    @objc public func createAlbum(_ invoke: Invoke) throws {
        struct CreateAlbumArgs: Decodable {
            let title: String
        }
        
        let args = try invoke.parseArgs(CreateAlbumArgs.self)
        
        var albumId: String?
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: args.title)
            albumId = request.placeholderForCreatedAssetCollection.localIdentifier
        }) { success, error in
            if success, let albumId = albumId,
               let collection = self.fetchAssetCollection(withId: albumId) {
                invoke.resolve(self.serializeAlbum(collection))
            } else {
                invoke.reject("Failed to create album: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @objc public func deleteAlbum(_ invoke: Invoke) throws {
        struct DeleteAlbumArgs: Decodable {
            let id: String
        }
        
        let args = try invoke.parseArgs(DeleteAlbumArgs.self)
        
        guard let collection = fetchAssetCollection(withId: args.id) else {
            invoke.reject("Album not found")
            return
        }
        
        guard collection.canPerform(.delete) else {
            invoke.reject("Cannot delete system album")
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections([collection] as NSFastEnumeration)
        }) { success, error in
            if success {
                invoke.resolve([:] as [String: Any])
            } else {
                invoke.reject("Failed to delete album: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @objc public func getAssets(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(AssetQuery.self)
        
        let fetchOptions = PHFetchOptions()
        var predicates: [NSPredicate] = []
        
        // Media type filter
        if let mediaTypes = args?.mediaTypes, !mediaTypes.isEmpty {
            let types = mediaTypes.compactMap { parseMediaType($0) }
            predicates.append(NSPredicate(format: "mediaType IN %@", types))
        }
        
        // Date range filter
        if let startDate = args?.startDate,
           let start = dateFormatter.date(from: startDate) {
            predicates.append(NSPredicate(format: "creationDate >= %@", start as NSDate))
        }
        if let endDate = args?.endDate,
           let end = dateFormatter.date(from: endDate) {
            predicates.append(NSPredicate(format: "creationDate <= %@", end as NSDate))
        }
        
        // Other filters
        if let isFavorite = args?.isFavorite {
            predicates.append(NSPredicate(format: "favorite == %@", NSNumber(value: isFavorite)))
        }
        
        if let isHidden = args?.isHidden {
            fetchOptions.includeHiddenAssets = isHidden
        }
        
        if !predicates.isEmpty {
            fetchOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // Sort order
        fetchOptions.sortDescriptors = [parseSortDescriptor(args?.sortOrder)]
        
        // Limit
        if let limit = args?.limit {
            fetchOptions.fetchLimit = limit
        }
        
        // Fetch assets
        let assets: PHFetchResult<PHAsset>
        if let albumId = args?.albumId,
           let collection = fetchAssetCollection(withId: albumId) {
            assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        } else {
            assets = PHAsset.fetchAssets(with: fetchOptions)
        }
        
        var results: [[String: Any]] = []
        assets.enumerateObjects { asset, _, _ in
            results.append(self.serializeAsset(asset))
        }
        
        invoke.resolve(["assets": results])
    }
    
    @objc public func getAsset(_ invoke: Invoke) throws {
        struct GetAssetArgs: Decodable {
            let id: String
        }
        
        let args = try invoke.parseArgs(GetAssetArgs.self)
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [args.id], options: nil)
        guard let asset = fetchResult.firstObject else {
            invoke.reject("Asset not found")
            return
        }
        
        invoke.resolve(serializeAsset(asset))
    }
    
    @objc public func deleteAssets(_ invoke: Invoke) throws {
        struct DeleteAssetsArgs: Decodable {
            let ids: [String]
        }
        
        let args = try invoke.parseArgs(DeleteAssetsArgs.self)
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: args.ids, options: nil)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets)
        }) { success, error in
            if success {
                invoke.resolve([:] as [String: Any])
            } else {
                invoke.reject("Failed to delete assets: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @objc public func saveImage(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SaveImageData.self)
        
        guard let imageData = Data(base64Encoded: args.imageData),
              let image = UIImage(data: imageData) else {
            invoke.reject("Invalid image data")
            return
        }
        
        var assetId: String?
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            assetId = request.placeholderForCreatedAsset?.localIdentifier
            
            // Add to album if specified
            if let albumId = args.toAlbum,
               let collection = self.fetchAssetCollection(withId: albumId),
               let albumRequest = PHAssetCollectionChangeRequest(for: collection),
               let placeholder = request.placeholderForCreatedAsset {
                albumRequest.addAssets([placeholder] as NSFastEnumeration)
            }
            
            // Set metadata if provided
            if let metadata = args.metadata {
                if let creationDate = metadata.creationDate,
                   let date = self.dateFormatter.date(from: creationDate) {
                    request.creationDate = date
                }
                
                if let location = metadata.location {
                    let loc = CLLocation(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    request.location = loc
                }
            }
        }) { success, error in
            if success, let assetId = assetId {
                invoke.resolve(["id": assetId] as [String: Any])
            } else {
                invoke.reject("Failed to save image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @objc public func saveVideo(_ invoke: Invoke) throws {
        struct SaveVideoArgs: Decodable {
            let path: String
            let toAlbum: String?
        }
        
        let args = try invoke.parseArgs(SaveVideoArgs.self)
        let videoURL = URL(fileURLWithPath: args.path)
        
        var assetId: String?
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            assetId = request?.placeholderForCreatedAsset?.localIdentifier
            
            // Add to album if specified
            if let albumId = args.toAlbum,
               let collection = self.fetchAssetCollection(withId: albumId),
               let albumRequest = PHAssetCollectionChangeRequest(for: collection),
               let placeholder = request?.placeholderForCreatedAsset {
                albumRequest.addAssets([placeholder] as NSFastEnumeration)
            }
        }) { success, error in
            if success, let assetId = assetId {
                invoke.resolve(["id": assetId] as [String: Any])
            } else {
                invoke.reject("Failed to save video: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @objc public func exportAsset(_ invoke: Invoke) throws {
        struct ExportArgs: Decodable {
            let id: String
            let options: ExportOptions
        }
        
        let args = try invoke.parseArgs(ExportArgs.self)
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [args.id], options: nil)
        guard let asset = fetchResult.firstObject else {
            invoke.reject("Asset not found")
            return
        }
        
        if asset.mediaType == .image {
            exportImage(asset: asset, options: args.options, invoke: invoke)
        } else if asset.mediaType == .video {
            exportVideo(asset: asset, options: args.options, invoke: invoke)
        } else {
            invoke.reject("Unsupported media type")
        }
    }
    
    @objc public func getAssetMetadata(_ invoke: Invoke) throws {
        struct GetMetadataArgs: Decodable {
            let id: String
        }
        
        let args = try invoke.parseArgs(GetMetadataArgs.self)
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [args.id], options: nil)
        guard let asset = fetchResult.firstObject else {
            invoke.reject("Asset not found")
            return
        }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, info in
            var metadata: [String: Any] = [
                "creationDate": self.dateFormatter.string(from: asset.creationDate ?? Date()),
                "modificationDate": self.dateFormatter.string(from: asset.modificationDate ?? Date()),
                "dimensions": [
                    "width": asset.pixelWidth,
                    "height": asset.pixelHeight
                ],
                "fileSize": data?.count ?? 0
            ]
            
            // Extract EXIF data if available
            if let data = data,
               let source = CGImageSourceCreateWithData(data as CFData, nil),
               let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] {
                metadata["exif"] = properties
                
                // Camera info
                if let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
                    var cameraInfo: [String: Any] = [:]
                    if let tiffDict = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
                        cameraInfo["make"] = tiffDict["Make"]
                        cameraInfo["model"] = tiffDict["Model"]
                    }
                    cameraInfo["lensMake"] = exif["LensMake"]
                    cameraInfo["lensModel"] = exif["LensModel"]
                    metadata["takenWith"] = cameraInfo
                }
            }
            
            // Location
            if let location = asset.location {
                metadata["gps"] = [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                    "altitude": location.altitude
                ]
            }
            
            // Video specific metadata
            if asset.mediaType == .video {
                metadata["codec"] = asset.value(forKey: "codec")
                metadata["bitRate"] = asset.value(forKey: "bitRate")
                metadata["frameRate"] = asset.value(forKey: "frameRate")
            }
            
            invoke.resolve(metadata)
        }
    }
    
    // MARK: - Helper Methods
    
    private func fetchAssetCollection(withId id: String) -> PHAssetCollection? {
        let collections = PHAssetCollection.fetchAssetCollections(
            withLocalIdentifiers: [id],
            options: nil
        )
        return collections.firstObject
    }
    
    private func serializeAlbum(_ collection: PHAssetCollection) -> [String: Any] {
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        
        var startDate: Date?
        var endDate: Date?
        
        assets.enumerateObjects { asset, _, _ in
            if let creation = asset.creationDate {
                if startDate == nil || creation < startDate! {
                    startDate = creation
                }
                if endDate == nil || creation > endDate! {
                    endDate = creation
                }
            }
        }
        
        return [
            "id": collection.localIdentifier,
            "title": collection.localizedTitle ?? "",
            "assetCount": assets.count,
            "startDate": startDate != nil ? dateFormatter.string(from: startDate!) : NSNull(),
            "endDate": endDate != nil ? dateFormatter.string(from: endDate!) : NSNull(),
            "albumType": albumTypeToString(collection),
            "canAddAssets": collection.canPerform(.addContent),
            "canRemoveAssets": collection.canPerform(.removeContent),
            "canDelete": collection.canPerform(.delete),
            "isSmartAlbum": collection.assetCollectionType == .smartAlbum
        ]
    }
    
    private func serializeAsset(_ asset: PHAsset) -> [String: Any] {
        var data: [String: Any] = [
            "id": asset.localIdentifier,
            "mediaType": mediaTypeToString(asset.mediaType),
            "mediaSubtype": mediaSubtypesToArray(asset.mediaSubtypes),
            "creationDate": dateFormatter.string(from: asset.creationDate ?? Date()),
            "modificationDate": dateFormatter.string(from: asset.modificationDate ?? Date()),
            "width": asset.pixelWidth,
            "height": asset.pixelHeight,
            "isFavorite": asset.isFavorite,
            "isHidden": asset.isHidden,
            "burstIdentifier": asset.burstIdentifier ?? NSNull(),
            "representsBurst": asset.representsBurst
        ]
        
        if asset.mediaType == .video {
            data["duration"] = asset.duration
        }
        
        if let location = asset.location {
            data["location"] = [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "altitude": location.altitude
            ]
        }
        
        return data
    }
    
    private func exportImage(asset: PHAsset, options: ExportOptions, invoke: Invoke) {
        let imageOptions = PHImageRequestOptions()
        imageOptions.version = .current
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isNetworkAccessAllowed = true
        
        let targetSize: CGSize
        if let maxWidth = options.maxWidth, let maxHeight = options.maxHeight {
            targetSize = CGSize(width: maxWidth, height: maxHeight)
        } else {
            targetSize = PHImageManagerMaximumSize
        }
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: imageOptions
        ) { image, info in
            guard let image = image else {
                invoke.reject("Failed to export image")
                return
            }
            
            let format = options.imageFormat ?? "jpeg"
            let quality = CGFloat(options.quality ?? 0.85)
            
            var imageData: Data?
            switch format.lowercased() {
            case "png":
                imageData = image.pngData()
            case "jpeg", "jpg":
                imageData = image.jpegData(compressionQuality: quality)
            default:
                imageData = image.jpegData(compressionQuality: quality)
            }
            
            guard let data = imageData else {
                invoke.reject("Failed to encode image")
                return
            }
            
            let fileName = "IMG_\(UUID().uuidString).\(format)"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: tempURL)
                invoke.resolve(["path": tempURL.path] as [String: Any])
            } catch {
                invoke.reject("Failed to save exported image: \(error.localizedDescription)")
            }
        }
    }
    
    private func exportVideo(asset: PHAsset, options: ExportOptions, invoke: Invoke) {
        let videoOptions = PHVideoRequestOptions()
        videoOptions.version = .current
        videoOptions.deliveryMode = .highQualityFormat
        videoOptions.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { avAsset, _, _ in
            guard let urlAsset = avAsset as? AVURLAsset else {
                invoke.reject("Failed to export video")
                return
            }
            
            let fileName = "VID_\(UUID().uuidString).mp4"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try FileManager.default.copyItem(at: urlAsset.url, to: tempURL)
                invoke.resolve(["path": tempURL.path] as [String: Any])
            } catch {
                invoke.reject("Failed to export video: \(error.localizedDescription)")
            }
        }
    }
    
    private func authorizationStatusToString(_ status: PHAuthorizationStatus) -> String {
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
    
    private func albumTypeToString(_ collection: PHAssetCollection) -> String {
        switch collection.assetCollectionType {
        case .album:
            return "regular"
        case .smartAlbum:
            return "smartAlbum"
        case .moment:
            return "moments"
        @unknown default:
            return "regular"
        }
    }
    
    private func mediaTypeToString(_ type: PHAssetMediaType) -> String {
        switch type {
        case .unknown:
            return "unknown"
        case .image:
            return "image"
        case .video:
            return "video"
        case .audio:
            return "audio"
        @unknown default:
            return "unknown"
        }
    }
    
    private func parseMediaType(_ type: String) -> PHAssetMediaType? {
        switch type.lowercased() {
        case "image":
            return .image
        case "video":
            return .video
        case "audio":
            return .audio
        default:
            return nil
        }
    }
    
    private func mediaSubtypesToArray(_ subtypes: PHAssetMediaSubtype) -> [String] {
        var result: [String] = []
        
        if subtypes.contains(.photoPanorama) {
            result.append("photoPanorama")
        }
        if subtypes.contains(.photoHDR) {
            result.append("photoHDR")
        }
        if subtypes.contains(.photoScreenshot) {
            result.append("photoScreenshot")
        }
        if subtypes.contains(.photoLive) {
            result.append("photoLive")
        }
        if subtypes.contains(.photoDepthEffect) {
            result.append("photoDepthEffect")
        }
        if subtypes.contains(.videoStreamed) {
            result.append("videoStreamed")
        }
        if subtypes.contains(.videoHighFrameRate) {
            result.append("videoHighFrameRate")
        }
        if subtypes.contains(.videoTimelapse) {
            result.append("videoTimelapse")
        }
        if #available(iOS 15.0, *) {
            if subtypes.contains(.videoCinematic) {
                result.append("videoCinematic")
            }
        }
        // videoSloMo is not available in current SDK
        // if #available(iOS 17.2, *) {
        //     if subtypes.contains(.videoSloMo) {
        //         result.append("videoSloMo")
        //     }
        // }
        
        return result
    }
    
    private func parseSortDescriptor(_ sortOrder: String?) -> NSSortDescriptor {
        switch sortOrder?.lowercased() {
        case "creationdateascending":
            return NSSortDescriptor(key: "creationDate", ascending: true)
        case "modificationdateascending":
            return NSSortDescriptor(key: "modificationDate", ascending: true)
        case "modificationdatedescending":
            return NSSortDescriptor(key: "modificationDate", ascending: false)
        default:
            return NSSortDescriptor(key: "creationDate", ascending: false)
        }
    }
}

@_cdecl("init_plugin_ios_photos")
func initPlugin() -> Plugin {
    return PhotosPlugin()
}