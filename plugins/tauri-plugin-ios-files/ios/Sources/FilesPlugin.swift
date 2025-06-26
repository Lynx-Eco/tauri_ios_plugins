import Tauri
import UIKit
import UniformTypeIdentifiers
import QuickLook
import MobileCoreServices

// Request structures
struct FilePickerOptionsData: Decodable {
    let types: [String]
    let allowMultiple: Bool
    let startingDirectory: String?
}

struct SaveFileOptionsData: Decodable {
    let suggestedName: String
    let types: [String]
    let data: FileDataWrapper
}

struct FileDataWrapper: Decodable {
    let base64: String?
    let text: String?
    let url: String?
}

struct ImportOptionsData: Decodable {
    let types: [String]
    let allowMultiple: Bool
    let copyToApp: Bool
}

struct ExportOptionsData: Decodable {
    let fileUrls: [String]
    let destinationName: String?
}

struct ListOptionsData: Decodable {
    let directoryUrl: String?
    let includeHidden: Bool
    let includePackages: Bool
    let sortBy: String
    let filter: FileFilterData?
}

struct FileFilterData: Decodable {
    let types: [String]?
    let namePattern: String?
    let minSize: Int64?
    let maxSize: Int64?
    let modifiedAfter: String?
    let modifiedBefore: String?
}

struct FileOperationData: Decodable {
    let sourceUrl: String
    let destinationUrl: String
    let overwrite: Bool
}

struct ShareOptionsData: Decodable {
    let fileUrls: [String]
    let excludeActivityTypes: [String]
}

struct PreviewOptionsData: Decodable {
    let fileUrl: String
    let canEdit: Bool
}

struct MonitoringOptionsData: Decodable {
    let directoryUrls: [String]
    let recursive: Bool
    let events: [String]
}

class FilesPlugin: Plugin, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    private var pendingInvoke: Invoke?
    private var documentInteractionController: UIDocumentInteractionController?
    private var previewController: QLPreviewController?
    private var previewUrl: URL?
    private var fileMonitor: FileMonitor?
    
    @objc public func pickFile(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(FilePickerOptionsData.self)
        
        DispatchQueue.main.async { [weak self] in
            self?.pendingInvoke = invoke
            
            if #available(iOS 14.0, *) {
                let types = self?.parseFileTypes(args.types) ?? [UTType.data]
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
                picker.delegate = self
                picker.allowsMultipleSelection = false
                
                if let startingDir = args.startingDirectory,
                   let url = URL(string: startingDir) {
                    picker.directoryURL = url
                }
                
                self?.presentViewController(picker)
            } else {
                // Fallback for iOS 13 and earlier
                let types = self?.parseFileTypesLegacy(args.types) ?? [kUTTypeData as String]
                let picker = UIDocumentPickerViewController(documentTypes: types, in: .import)
                picker.delegate = self
                picker.allowsMultipleSelection = false
                
                if let startingDir = args.startingDirectory,
                   let url = URL(string: startingDir) {
                    picker.directoryURL = url
                }
                
                self?.presentViewController(picker)
            }
        }
    }
    
    @objc public func pickMultipleFiles(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(FilePickerOptionsData.self)
        
        DispatchQueue.main.async { [weak self] in
            self?.pendingInvoke = invoke
            
            if #available(iOS 14.0, *) {
                let types = self?.parseFileTypes(args.types) ?? [UTType.data]
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
                picker.delegate = self
                picker.allowsMultipleSelection = true
                
                if let startingDir = args.startingDirectory,
                   let url = URL(string: startingDir) {
                    picker.directoryURL = url
                }
                
                self?.presentViewController(picker)
            } else {
                // Fallback for iOS 13 and earlier
                let types = self?.parseFileTypesLegacy(args.types) ?? [kUTTypeData as String]
                let picker = UIDocumentPickerViewController(documentTypes: types, in: .import)
                picker.delegate = self
                picker.allowsMultipleSelection = true
                
                if let startingDir = args.startingDirectory,
                   let url = URL(string: startingDir) {
                    picker.directoryURL = url
                }
                
                self?.presentViewController(picker)
            }
        }
    }
    
    @objc public func pickFolder(_ invoke: Invoke) throws {
        DispatchQueue.main.async { [weak self] in
            self?.pendingInvoke = invoke
            
            if #available(iOS 14.0, *) {
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder])
                picker.delegate = self
                picker.allowsMultipleSelection = false
                
                self?.presentViewController(picker)
            } else {
                // Folders not directly supported in iOS 13, use generic picker
                let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
                picker.delegate = self
                picker.allowsMultipleSelection = false
                
                self?.presentViewController(picker)
            }
        }
    }
    
    @objc public func saveFile(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SaveFileOptionsData.self)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Create temporary file
            let tempDir = FileManager.default.temporaryDirectory
            let tempUrl = tempDir.appendingPathComponent(args.suggestedName)
            
            do {
                // Write data to temp file
                if let base64 = args.data.base64,
                   let data = Data(base64Encoded: base64) {
                    try data.write(to: tempUrl)
                } else if let text = args.data.text {
                    try text.write(to: tempUrl, atomically: true, encoding: .utf8)
                } else if let urlString = args.data.url,
                          let sourceUrl = URL(string: urlString) {
                    try FileManager.default.copyItem(at: sourceUrl, to: tempUrl)
                } else {
                    invoke.reject("Invalid file data")
                    return
                }
                
                self.pendingInvoke = invoke
                
                if #available(iOS 14.0, *) {
                    let types = self.parseFileTypes(args.types)
                    let picker = UIDocumentPickerViewController(forExporting: [tempUrl], asCopy: true)
                    picker.delegate = self
                    
                    self.presentViewController(picker)
                } else {
                    // Fallback for iOS 13 and earlier
                    let picker = UIDocumentPickerViewController(urls: [tempUrl], in: .exportToService)
                    picker.delegate = self
                    
                    self.presentViewController(picker)
                }
            } catch {
                invoke.reject("Failed to create temporary file: \(error.localizedDescription)")
            }
        }
    }
    
    @objc public func openInFiles(_ invoke: Invoke) throws {
        struct OpenArgs: Decodable {
            let url: String
        }
        
        let args = try invoke.parseArgs(OpenArgs.self)
        
        guard let url = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.documentInteractionController = UIDocumentInteractionController(url: url)
            self?.documentInteractionController?.delegate = self
            
            if let controller = self?.documentInteractionController,
               let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let view = window.rootViewController?.view {
                if !controller.presentOpenInMenu(from: view.bounds, in: view, animated: true) {
                    invoke.reject("No apps available to open this file")
                } else {
                    invoke.resolve()
                }
            } else {
                invoke.reject("Failed to present Files app")
            }
        }
    }
    
    @objc public func importFromFiles(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(ImportOptionsData.self)
        
        DispatchQueue.main.async { [weak self] in
            self?.pendingInvoke = invoke
            
            if #available(iOS 14.0, *) {
                let types = self?.parseFileTypes(args.types) ?? [UTType.data]
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
                picker.delegate = self
                picker.allowsMultipleSelection = args.allowMultiple
                
                self?.presentViewController(picker)
            } else {
                // Fallback for iOS 13 and earlier
                let types = self?.parseFileTypesLegacy(args.types) ?? [kUTTypeData as String]
                let picker = UIDocumentPickerViewController(documentTypes: types, in: .import)
                picker.delegate = self
                picker.allowsMultipleSelection = args.allowMultiple
                
                self?.presentViewController(picker)
            }
        }
    }
    
    @objc public func exportToFiles(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(ExportOptionsData.self)
        
        var urls: [URL] = []
        for urlString in args.fileUrls {
            if let url = URL(string: urlString) {
                urls.append(url)
            }
        }
        
        guard !urls.isEmpty else {
            invoke.reject("No valid URLs provided")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.pendingInvoke = invoke
            
            if #available(iOS 14.0, *) {
                let picker = UIDocumentPickerViewController(forExporting: urls, asCopy: true)
                picker.delegate = self
                
                self?.presentViewController(picker)
            } else {
                // Fallback for iOS 13 and earlier
                let picker = UIDocumentPickerViewController(urls: urls, in: .exportToService)
                picker.delegate = self
                
                self?.presentViewController(picker)
            }
        }
    }
    
    @objc public func listDocuments(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(ListOptionsData.self)
        
        let documentsUrl: URL
        if let dirUrl = args?.directoryUrl,
           let url = URL(string: dirUrl) {
            documentsUrl = url
        } else {
            documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        
        do {
            let resourceKeys: [URLResourceKey] = [
                .nameKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey,
                .contentAccessDateKey, .typeIdentifierKey, .isDirectoryKey,
                .isPackageKey, .isHiddenKey, .isAliasFileKey, .ubiquitousItemIsDownloadingKey,
                .ubiquitousItemDownloadingStatusKey
            ]
            
            let enumerator = FileManager.default.enumerator(
                at: documentsUrl,
                includingPropertiesForKeys: resourceKeys,
                options: args?.includeHidden ?? false ? [] : [.skipsHiddenFiles]
            )
            
            var documents: [[String: Any]] = []
            
            while let fileUrl = enumerator?.nextObject() as? URL {
                let resourceValues = try fileUrl.resourceValues(forKeys: Set(resourceKeys))
                
                var doc: [String: Any] = [
                    "url": fileUrl.absoluteString,
                    "name": resourceValues.name ?? "",
                    "size": resourceValues.fileSize ?? 0,
                    "isDirectory": resourceValues.isDirectory ?? false,
                    "isPackage": resourceValues.isPackage ?? false,
                    "isHidden": resourceValues.isHidden ?? false,
                    "isAlias": resourceValues.isAliasFile ?? false,
                    "utiType": resourceValues.typeIdentifier ?? ""
                ]
                
                if let createdDate = resourceValues.creationDate {
                    doc["createdDate"] = ISO8601DateFormatter().string(from: createdDate)
                }
                
                if let modifiedDate = resourceValues.contentModificationDate {
                    doc["modifiedDate"] = ISO8601DateFormatter().string(from: modifiedDate)
                }
                
                if let accessedDate = resourceValues.contentAccessDate {
                    doc["accessedDate"] = ISO8601DateFormatter().string(from: accessedDate)
                }
                
                // Cloud status
                let cloudStatus: String
                if let isDownloading = resourceValues.ubiquitousItemIsDownloading {
                    if !isDownloading {
                        cloudStatus = "downloaded"
                    } else if let downloadingStatus = resourceValues.ubiquitousItemDownloadingStatus {
                        if downloadingStatus == .current {
                            cloudStatus = "current"
                        } else if downloadingStatus == .downloaded {
                            cloudStatus = "downloaded"
                        } else if downloadingStatus == .notDownloaded {
                            cloudStatus = "notDownloaded"
                        } else {
                            cloudStatus = "downloading"
                        }
                    } else {
                        cloudStatus = "notDownloaded"
                    }
                } else {
                    cloudStatus = "notInCloud"
                }
                doc["cloudStatus"] = cloudStatus
                
                documents.append(doc)
            }
            
            // Apply sorting
            if let sortBy = args?.sortBy {
                switch sortBy {
                case "name":
                    documents.sort { ($0["name"] as? String ?? "") < ($1["name"] as? String ?? "") }
                case "date":
                    documents.sort { ($0["modifiedDate"] as? String ?? "") > ($1["modifiedDate"] as? String ?? "") }
                case "size":
                    documents.sort { ($0["size"] as? Int ?? 0) > ($1["size"] as? Int ?? 0) }
                default:
                    break
                }
            }
            
            invoke.resolve(["documents": documents])
        } catch {
            invoke.reject("Failed to list documents: \(error.localizedDescription)")
        }
    }
    
    @objc public func readFile(_ invoke: Invoke) throws {
        struct ReadArgs: Decodable {
            let url: String
        }
        
        let args = try invoke.parseArgs(ReadArgs.self)
        
        guard let url = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            // Try to detect if it's text
            if let text = String(data: data, encoding: .utf8) {
                invoke.resolve(["text": text])
            } else {
                invoke.resolve(["base64": data.base64EncodedString()])
            }
        } catch {
            invoke.reject("Failed to read file: \(error.localizedDescription)")
        }
    }
    
    @objc public func writeFile(_ invoke: Invoke) throws {
        struct WriteArgs: Decodable {
            let url: String
            let data: FileDataWrapper
        }
        
        let args = try invoke.parseArgs(WriteArgs.self)
        
        guard let url = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        do {
            if let base64 = args.data.base64,
               let data = Data(base64Encoded: base64) {
                try data.write(to: url)
            } else if let text = args.data.text {
                try text.write(to: url, atomically: true, encoding: .utf8)
            } else {
                invoke.reject("Invalid file data")
                return
            }
            
            invoke.resolve()
        } catch {
            invoke.reject("Failed to write file: \(error.localizedDescription)")
        }
    }
    
    @objc public func deleteFile(_ invoke: Invoke) throws {
        struct DeleteArgs: Decodable {
            let url: String
        }
        
        let args = try invoke.parseArgs(DeleteArgs.self)
        
        guard let url = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
            invoke.resolve()
        } catch {
            invoke.reject("Failed to delete file: \(error.localizedDescription)")
        }
    }
    
    @objc public func moveFile(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(FileOperationData.self)
        
        guard let sourceUrl = URL(string: args.sourceUrl),
              let destUrl = URL(string: args.destinationUrl) else {
            invoke.reject("Invalid URLs")
            return
        }
        
        do {
            if args.overwrite && FileManager.default.fileExists(atPath: destUrl.path) {
                try FileManager.default.removeItem(at: destUrl)
            }
            
            try FileManager.default.moveItem(at: sourceUrl, to: destUrl)
            invoke.resolve(destUrl.absoluteString)
        } catch {
            invoke.reject("Failed to move file: \(error.localizedDescription)")
        }
    }
    
    @objc public func copyFile(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(FileOperationData.self)
        
        guard let sourceUrl = URL(string: args.sourceUrl),
              let destUrl = URL(string: args.destinationUrl) else {
            invoke.reject("Invalid URLs")
            return
        }
        
        do {
            if args.overwrite && FileManager.default.fileExists(atPath: destUrl.path) {
                try FileManager.default.removeItem(at: destUrl)
            }
            
            try FileManager.default.copyItem(at: sourceUrl, to: destUrl)
            invoke.resolve(destUrl.absoluteString)
        } catch {
            invoke.reject("Failed to copy file: \(error.localizedDescription)")
        }
    }
    
    @objc public func createFolder(_ invoke: Invoke) throws {
        struct CreateFolderArgs: Decodable {
            let url: String
            let name: String
        }
        
        let args = try invoke.parseArgs(CreateFolderArgs.self)
        
        guard let parentUrl = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        let folderUrl = parentUrl.appendingPathComponent(args.name)
        
        do {
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true)
            invoke.resolve(folderUrl.absoluteString)
        } catch {
            invoke.reject("Failed to create folder: \(error.localizedDescription)")
        }
    }
    
    @objc public func getFileInfo(_ invoke: Invoke) throws {
        struct InfoArgs: Decodable {
            let url: String
        }
        
        let args = try invoke.parseArgs(InfoArgs.self)
        
        guard let url = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        do {
            let resourceKeys: [URLResourceKey] = [
                .nameKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey,
                .contentAccessDateKey, .typeIdentifierKey, .isDirectoryKey,
                .isPackageKey, .isHiddenKey, .isAliasFileKey
            ]
            
            let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
            
            var info: [String: Any] = [
                "url": url.absoluteString,
                "name": resourceValues.name ?? "",
                "size": resourceValues.fileSize ?? 0,
                "isDirectory": resourceValues.isDirectory ?? false,
                "isPackage": resourceValues.isPackage ?? false,
                "isHidden": resourceValues.isHidden ?? false,
                "isAlias": resourceValues.isAliasFile ?? false,
                "utiType": resourceValues.typeIdentifier ?? ""
            ]
            
            let formatter = ISO8601DateFormatter()
            
            if let createdDate = resourceValues.creationDate {
                info["createdDate"] = formatter.string(from: createdDate)
            }
            
            if let modifiedDate = resourceValues.contentModificationDate {
                info["modifiedDate"] = formatter.string(from: modifiedDate)
            }
            
            if let accessedDate = resourceValues.contentAccessDate {
                info["accessedDate"] = formatter.string(from: accessedDate)
            }
            
            invoke.resolve(info)
        } catch {
            invoke.reject("Failed to get file info: \(error.localizedDescription)")
        }
    }
    
    @objc public func shareFile(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(ShareOptionsData.self)
        
        var items: [Any] = []
        for urlString in args.fileUrls {
            if let url = URL(string: urlString) {
                items.append(url)
            }
        }
        
        guard !items.isEmpty else {
            invoke.reject("No valid URLs to share")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            if !args.excludeActivityTypes.isEmpty {
                activityVC.excludedActivityTypes = args.excludeActivityTypes.compactMap { UIActivity.ActivityType(rawValue: $0) }
            }
            
            if let popover = activityVC.popoverPresentationController {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let view = window.rootViewController?.view {
                    popover.sourceView = view
                    popover.sourceRect = view.bounds
                }
            }
            
            self?.presentViewController(activityVC)
            invoke.resolve()
        }
    }
    
    @objc public func previewFile(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(PreviewOptionsData.self)
        
        guard let url = URL(string: args.fileUrl) else {
            invoke.reject("Invalid URL")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.previewUrl = url
            
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.delegate = self
            
            self?.previewController = previewController
            self?.presentViewController(previewController)
            
            invoke.resolve()
        }
    }
    
    @objc public func getCloudStatus(_ invoke: Invoke) throws {
        struct StatusArgs: Decodable {
            let url: String
        }
        
        let args = try invoke.parseArgs(StatusArgs.self)
        
        guard let url = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [
                .ubiquitousItemIsDownloadingKey,
                .ubiquitousItemDownloadingStatusKey
            ])
            
            let status: String
            if let isDownloading = resourceValues.ubiquitousItemIsDownloading {
                if !isDownloading {
                    status = "downloaded"
                } else if let downloadingStatus = resourceValues.ubiquitousItemDownloadingStatus {
                    if downloadingStatus == .current {
                        status = "current"
                    } else if downloadingStatus == .downloaded {
                        status = "downloaded"
                    } else if downloadingStatus == .notDownloaded {
                        status = "notDownloaded"
                    } else {
                        status = "downloading"
                    }
                } else {
                    status = "notDownloaded"
                }
            } else {
                status = "notInCloud"
            }
            
            invoke.resolve(status)
        } catch {
            invoke.reject("Failed to get cloud status: \(error.localizedDescription)")
        }
    }
    
    @objc public func downloadFromCloud(_ invoke: Invoke) throws {
        struct DownloadArgs: Decodable {
            let url: String
        }
        
        let args = try invoke.parseArgs(DownloadArgs.self)
        
        guard let url = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
            invoke.resolve()
        } catch {
            invoke.reject("Failed to start download: \(error.localizedDescription)")
        }
    }
    
    @objc public func evictFromLocal(_ invoke: Invoke) throws {
        struct EvictArgs: Decodable {
            let url: String
        }
        
        let args = try invoke.parseArgs(EvictArgs.self)
        
        guard let url = URL(string: args.url) else {
            invoke.reject("Invalid URL")
            return
        }
        
        do {
            try FileManager.default.evictUbiquitousItem(at: url)
            invoke.resolve()
        } catch {
            invoke.reject("Failed to evict file: \(error.localizedDescription)")
        }
    }
    
    @objc public func startMonitoring(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(MonitoringOptionsData.self)
        
        guard fileMonitor == nil else {
            invoke.reject("Monitoring already active")
            return
        }
        
        var urls: [URL] = []
        for urlString in args.directoryUrls {
            if let url = URL(string: urlString) {
                urls.append(url)
            }
        }
        
        guard !urls.isEmpty else {
            invoke.reject("No valid URLs to monitor")
            return
        }
        
        fileMonitor = FileMonitor(urls: urls, recursive: args.recursive) { [weak self] change in
            self?.trigger("fileChanged", data: [
                "fileUrl": change.fileUrl.absoluteString,
                "eventType": change.eventType,
                "oldUrl": change.oldUrl?.absoluteString ?? NSNull(),
                "timestamp": ISO8601DateFormatter().string(from: change.timestamp)
            ])
        }
        
        fileMonitor?.startMonitoring()
        invoke.resolve()
    }
    
    @objc public func stopMonitoring(_ invoke: Invoke) throws {
        guard fileMonitor != nil else {
            invoke.reject("Monitoring not active")
            return
        }
        
        fileMonitor?.stopMonitoring()
        fileMonitor = nil
        invoke.resolve()
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let invoke = pendingInvoke else { return }
        pendingInvoke = nil
        
        var pickedFiles: [[String: Any]] = []
        
        for url in urls {
            _ = url.startAccessingSecurityScopedResource()
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let resourceValues = try url.resourceValues(forKeys: [
                    .nameKey, .fileSizeKey, .typeIdentifierKey, .isDirectoryKey
                ])
                
                let file: [String: Any] = [
                    "url": url.absoluteString,
                    "name": resourceValues.name ?? url.lastPathComponent,
                    "size": resourceValues.fileSize ?? 0,
                    "utiType": resourceValues.typeIdentifier ?? "",
                    "isDirectory": resourceValues.isDirectory ?? false
                ]
                
                pickedFiles.append(file)
            } catch {
                // Continue with partial data
                let file: [String: Any] = [
                    "url": url.absoluteString,
                    "name": url.lastPathComponent,
                    "size": 0,
                    "utiType": "",
                    "isDirectory": false
                ]
                pickedFiles.append(file)
            }
        }
        
        if controller.allowsMultipleSelection {
            invoke.resolve(["files": pickedFiles])
        } else {
            invoke.resolve(pickedFiles.first ?? [:])
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        pendingInvoke?.reject("User cancelled")
        pendingInvoke = nil
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewUrl != nil ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewUrl! as QLPreviewItem
    }
    
    // MARK: - Helpers
    
    @available(iOS 14.0, *)
    private func parseFileTypes(_ types: [String]) -> [UTType] {
        var utTypes: [UTType] = []
        
        for type in types {
            switch type.lowercased() {
            case "image":
                utTypes.append(.image)
            case "video":
                utTypes.append(.movie)
            case "audio":
                utTypes.append(.audio)
            case "pdf":
                utTypes.append(.pdf)
            case "text":
                utTypes.append(.text)
            case "spreadsheet":
                utTypes.append(.spreadsheet)
            case "presentation":
                utTypes.append(.presentation)
            case "archive":
                utTypes.append(.archive)
            default:
                // Try to create UTType from string
                if let utType = UTType(type) {
                    utTypes.append(utType)
                }
            }
        }
        
        return utTypes.isEmpty ? [.data] : utTypes
    }
    
    // Legacy method for iOS 13 and earlier
    private func parseFileTypesLegacy(_ types: [String]) -> [String] {
        var utTypes: [String] = []
        
        for type in types {
            switch type.lowercased() {
            case "image":
                utTypes.append(kUTTypeImage as String)
            case "video":
                utTypes.append(kUTTypeMovie as String)
            case "audio":
                utTypes.append(kUTTypeAudio as String)
            case "pdf":
                utTypes.append(kUTTypePDF as String)
            case "text":
                utTypes.append(kUTTypeText as String)
            case "spreadsheet":
                utTypes.append("com.apple.iwork.numbers.numbers" as String)
                utTypes.append("com.microsoft.excel.xls" as String)
                utTypes.append("com.microsoft.excel.xlsx" as String)
            case "presentation":
                utTypes.append("com.apple.iwork.keynote.key" as String)
                utTypes.append("com.microsoft.powerpoint.ppt" as String)
                utTypes.append("com.microsoft.powerpoint.pptx" as String)
            case "archive":
                utTypes.append(kUTTypeArchive as String)
            default:
                // Use the type string as-is
                utTypes.append(type)
            }
        }
        
        return utTypes.isEmpty ? [kUTTypeData as String] : utTypes
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async {
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
}

// MARK: - File Monitor

class FileMonitor {
    private let urls: [URL]
    private let recursive: Bool
    private let changeHandler: (FileChangeEvent) -> Void
    private var sources: [DispatchSourceFileSystemObject] = []
    
    struct FileChangeEvent {
        let fileUrl: URL
        let eventType: String
        let oldUrl: URL?
        let timestamp: Date
    }
    
    init(urls: [URL], recursive: Bool, changeHandler: @escaping (FileChangeEvent) -> Void) {
        self.urls = urls
        self.recursive = recursive
        self.changeHandler = changeHandler
    }
    
    func startMonitoring() {
        for url in urls {
            monitorDirectory(at: url)
        }
    }
    
    func stopMonitoring() {
        for source in sources {
            source.cancel()
        }
        sources.removeAll()
    }
    
    private func monitorDirectory(at url: URL) {
        let fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global()
        )
        
        source.setEventHandler { [weak self] in
            let event = FileChangeEvent(
                fileUrl: url,
                eventType: "modified",
                oldUrl: nil,
                timestamp: Date()
            )
            self?.changeHandler(event)
        }
        
        source.setCancelHandler {
            close(fileDescriptor)
        }
        
        source.resume()
        sources.append(source)
        
        // Monitor subdirectories if recursive
        if recursive {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey])
                for item in contents {
                    if let isDirectory = try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory,
                       isDirectory == true {
                        monitorDirectory(at: item)
                    }
                }
            } catch {
                // Ignore errors
            }
        }
    }
}

@_cdecl("init_plugin_ios_files")
func initPlugin() -> Plugin {
    return FilesPlugin()
}