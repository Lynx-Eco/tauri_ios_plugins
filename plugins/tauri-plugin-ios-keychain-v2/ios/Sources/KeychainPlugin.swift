import Tauri
import Security
import LocalAuthentication
import UIKit

struct KeychainItemData: Decodable {
    let key: String
    let value: String
    let service: String?
    let account: String?
    let accessGroup: String?
    let accessible: String?
    let synchronizable: Bool
    let label: String?
    let comment: String?
}

struct KeychainQueryData: Decodable {
    let key: String
    let service: String?
    let account: String?
    let accessGroup: String?
}

struct KeychainUpdateData: Decodable {
    let value: String?
    let accessible: String?
    let synchronizable: Bool?
    let label: String?
    let comment: String?
}

struct UpdateItemArgs: Decodable {
    let query: KeychainQueryData
    let updates: KeychainUpdateData
}

struct SecureKeychainItemData: Decodable {
    let key: String
    let value: SecureValueData
    let service: String?
    let accessGroup: String?
    let authentication: AuthenticationPolicyData
    let accessible: String?
    let validityDuration: Int?
}

struct SecureValueData: Decodable {
    let type: String
    let data: String
}

struct AuthenticationPolicyData: Decodable {
    let biometryAny: Bool
    let biometryCurrentSet: Bool
    let devicePasscode: Bool
    let userPresence: Bool
    let applicationPassword: String?
}

struct SecureKeychainQueryData: Decodable {
    let key: String
    let service: String?
    let accessGroup: String?
    let authenticationPrompt: String?
}

struct InternetPasswordItemData: Decodable {
    let server: String
    let account: String
    let password: String
    let port: Int?
    let protocol: String?
    let authenticationType: String?
    let securityDomain: String?
    let accessible: String?
    let synchronizable: Bool
}

struct InternetPasswordQueryData: Decodable {
    let server: String
    let account: String?
    let port: Int?
    let protocol: String?
}

struct PasswordOptionsData: Decodable {
    let length: Int
    let includeUppercase: Bool
    let includeLowercase: Bool
    let includeNumbers: Bool
    let includeSymbols: Bool
    let excludeAmbiguous: Bool
    let customCharacters: String?
}

class KeychainPlugin: Plugin {
    private var defaultService: String {
        return Bundle.main.bundleIdentifier ?? "com.tauri.keychain"
    }
    
    @objc public func setItem(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(KeychainItemData.self)
        
        let service = args.service ?? defaultService
        let account = args.account ?? args.key
        
        // Create query
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        // Add optional attributes
        if let accessGroup = args.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Create attributes
        var attributes: [String: Any] = [
            kSecValueData as String: args.value.data(using: .utf8)!
        ]
        
        if let accessible = args.accessible {
            attributes[kSecAttrAccessible as String] = parseAccessible(accessible)
        }
        
        attributes[kSecAttrSynchronizable as String] = args.synchronizable
        
        if let label = args.label {
            attributes[kSecAttrLabel as String] = label
        }
        
        if let comment = args.comment {
            attributes[kSecAttrComment as String] = comment
        }
        
        // Try to update existing item first
        var status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecItemNotFound {
            // Item doesn't exist, create it
            for (key, value) in attributes {
                query[key] = value
            }
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        if status == errSecSuccess {
            invoke.resolve()
        } else if status == errSecDuplicateItem {
            invoke.reject("Duplicate item exists")
        } else {
            invoke.reject("Failed to save item: \(status)")
        }
    }
    
    @objc public func getItem(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(KeychainQueryData.self)
        
        let service = args.service ?? defaultService
        let account = args.account ?? args.key
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = args.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let item = result as? [String: Any],
           let data = item[kSecValueData as String] as? Data,
           let value = String(data: data, encoding: .utf8) {
            
            invoke.resolve([
                "key": args.key,
                "value": value,
                "service": service,
                "account": account,
                "accessGroup": args.accessGroup,
                "accessible": "whenUnlocked", // Default
                "synchronizable": item[kSecAttrSynchronizable as String] as? Bool ?? false,
                "label": item[kSecAttrLabel as String] as? String,
                "comment": item[kSecAttrComment as String] as? String
            ])
        } else if status == errSecItemNotFound {
            invoke.reject("Keychain item not found")
        } else {
            invoke.reject("Failed to get item: \(status)")
        }
    }
    
    @objc public func deleteItem(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(KeychainQueryData.self)
        
        let service = args.service ?? defaultService
        let account = args.account ?? args.key
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        if let accessGroup = args.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            invoke.resolve()
        } else {
            invoke.reject("Failed to delete item: \(status)")
        }
    }
    
    @objc public func hasItem(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(KeychainQueryData.self)
        
        let service = args.service ?? defaultService
        let account = args.account ?? args.key
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = args.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        invoke.resolve(status == errSecSuccess)
    }
    
    @objc public func updateItem(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(UpdateItemArgs.self)
        
        let service = args.query.service ?? defaultService
        let account = args.query.account ?? args.query.key
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        if let accessGroup = args.query.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var attributes: [String: Any] = [:]
        
        if let value = args.updates.value {
            attributes[kSecValueData as String] = value.data(using: .utf8)!
        }
        
        if let accessible = args.updates.accessible {
            attributes[kSecAttrAccessible as String] = parseAccessible(accessible)
        }
        
        if let synchronizable = args.updates.synchronizable {
            attributes[kSecAttrSynchronizable as String] = synchronizable
        }
        
        if let label = args.updates.label {
            attributes[kSecAttrLabel as String] = label
        }
        
        if let comment = args.updates.comment {
            attributes[kSecAttrComment as String] = comment
        }
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecSuccess {
            invoke.resolve()
        } else if status == errSecItemNotFound {
            invoke.reject("Keychain item not found")
        } else {
            invoke.reject("Failed to update item: \(status)")
        }
    }
    
    @objc public func getAllKeys(_ invoke: Invoke) throws {
        struct GetAllKeysArgs: Decodable {
            let service: String?
        }
        
        let args = try? invoke.parseArgs(GetAllKeysArgs.self)
        let service = args?.service ?? defaultService
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let items = result as? [[String: Any]] {
            let keys = items.compactMap { $0[kSecAttrAccount as String] as? String }
            invoke.resolve(keys)
        } else if status == errSecItemNotFound {
            invoke.resolve([])
        } else {
            invoke.reject("Failed to get keys: \(status)")
        }
    }
    
    @objc public func deleteAll(_ invoke: Invoke) throws {
        struct DeleteAllArgs: Decodable {
            let service: String?
        }
        
        let args = try? invoke.parseArgs(DeleteAllArgs.self)
        let service = args?.service ?? defaultService
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            invoke.resolve()
        } else {
            invoke.reject("Failed to delete all items: \(status)")
        }
    }
    
    @objc public func setSecureItem(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SecureKeychainItemData.self)
        
        let service = args.service ?? defaultService
        
        // Create access control
        var error: Unmanaged<CFError>?
        var flags: SecAccessControlCreateFlags = []
        
        if args.authentication.biometryAny {
            flags.insert(.biometryAny)
        }
        if args.authentication.biometryCurrentSet {
            flags.insert(.biometryCurrentSet)
        }
        if args.authentication.devicePasscode {
            flags.insert(.devicePasscode)
        }
        if args.authentication.userPresence {
            flags.insert(.userPresence)
        }
        
        let accessible = parseAccessible(args.accessible ?? "whenUnlockedThisDeviceOnly")
        
        guard let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            accessible,
            flags,
            &error
        ) else {
            invoke.reject("Failed to create access control: \(error?.takeRetainedValue().localizedDescription ?? "Unknown error")")
            return
        }
        
        // Get value data
        let valueData: Data
        switch args.value.type {
        case "password":
            valueData = args.value.data.data(using: .utf8) ?? Data()
        case "data", "certificate", "key":
            valueData = Data(base64Encoded: args.value.data) ?? Data()
        default:
            invoke.reject("Invalid secure value type")
            return
        }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: args.key,
            kSecValueData as String: valueData,
            kSecAttrAccessControl as String: access
        ]
        
        if let accessGroup = args.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Try to delete existing item first
        var deleteQuery = query
        deleteQuery.removeValue(forKey: kSecValueData as String)
        deleteQuery.removeValue(forKey: kSecAttrAccessControl as String)
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            invoke.resolve()
        } else {
            invoke.reject("Failed to save secure item: \(status)")
        }
    }
    
    @objc public func getSecureItem(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SecureKeychainQueryData.self)
        
        let service = args.service ?? defaultService
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: args.key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = args.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        if let prompt = args.authenticationPrompt {
            let context = LAContext()
            context.localizedReason = prompt
            query[kSecUseAuthenticationContext as String] = context
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data {
            
            // Try to decode as string first
            let value: [String: Any]
            if let string = String(data: data, encoding: .utf8) {
                value = [
                    "type": "password",
                    "data": string
                ]
            } else {
                value = [
                    "type": "data",
                    "data": data.base64EncodedString()
                ]
            }
            
            invoke.resolve([
                "key": args.key,
                "value": value,
                "service": service,
                "accessGroup": args.accessGroup,
                "authentication": [
                    "biometryAny": false,
                    "biometryCurrentSet": false,
                    "devicePasscode": true,
                    "userPresence": true,
                    "applicationPassword": nil
                ],
                "accessible": "whenUnlockedThisDeviceOnly"
            ])
        } else if status == errSecItemNotFound {
            invoke.reject("Secure item not found")
        } else if status == errSecUserCanceled {
            invoke.reject("Authentication cancelled")
        } else {
            invoke.reject("Failed to get secure item: \(status)")
        }
    }
    
    @objc public func setInternetPassword(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(InternetPasswordItemData.self)
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: args.server,
            kSecAttrAccount as String: args.account,
            kSecValueData as String: args.password.data(using: .utf8)!
        ]
        
        if let port = args.port {
            query[kSecAttrPort as String] = port
        }
        
        if let proto = args.protocol {
            query[kSecAttrProtocol as String] = parseProtocol(proto)
        }
        
        if let authType = args.authenticationType {
            query[kSecAttrAuthenticationType as String] = parseAuthenticationType(authType)
        }
        
        if let domain = args.securityDomain {
            query[kSecAttrSecurityDomain as String] = domain
        }
        
        if let accessible = args.accessible {
            query[kSecAttrAccessible as String] = parseAccessible(accessible)
        }
        
        query[kSecAttrSynchronizable as String] = args.synchronizable
        
        // Try to delete existing item first
        var deleteQuery = query
        deleteQuery.removeValue(forKey: kSecValueData as String)
        deleteQuery.removeValue(forKey: kSecAttrAccessible as String)
        deleteQuery.removeValue(forKey: kSecAttrSynchronizable as String)
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            invoke.resolve()
        } else {
            invoke.reject("Failed to save internet password: \(status)")
        }
    }
    
    @objc public func getInternetPassword(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(InternetPasswordQueryData.self)
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: args.server,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let account = args.account {
            query[kSecAttrAccount as String] = account
        }
        
        if let port = args.port {
            query[kSecAttrPort as String] = port
        }
        
        if let proto = args.protocol {
            query[kSecAttrProtocol as String] = parseProtocol(proto)
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let item = result as? [String: Any],
           let data = item[kSecValueData as String] as? Data,
           let password = String(data: data, encoding: .utf8) {
            
            invoke.resolve([
                "server": args.server,
                "account": item[kSecAttrAccount as String] as? String ?? "",
                "password": password,
                "port": item[kSecAttrPort as String] as? Int,
                "protocol": protocolToString(item[kSecAttrProtocol as String] as? String),
                "authenticationType": authenticationTypeToString(item[kSecAttrAuthenticationType as String] as? String),
                "securityDomain": item[kSecAttrSecurityDomain as String] as? String,
                "accessible": "whenUnlocked",
                "synchronizable": item[kSecAttrSynchronizable as String] as? Bool ?? false
            ])
        } else if status == errSecItemNotFound {
            invoke.reject("Internet password not found")
        } else {
            invoke.reject("Failed to get internet password: \(status)")
        }
    }
    
    @objc public func generatePassword(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(PasswordOptionsData.self)
        
        var characters = ""
        
        if args.includeLowercase {
            characters += "abcdefghijklmnopqrstuvwxyz"
        }
        if args.includeUppercase {
            characters += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        if args.includeNumbers {
            characters += "0123456789"
        }
        if args.includeSymbols {
            characters += "!@#$%^&*()_+-=[]{}|;:,.<>?"
        }
        
        if args.excludeAmbiguous {
            characters = characters.replacingOccurrences(of: "0", with: "")
                                 .replacingOccurrences(of: "O", with: "")
                                 .replacingOccurrences(of: "l", with: "")
                                 .replacingOccurrences(of: "1", with: "")
                                 .replacingOccurrences(of: "I", with: "")
        }
        
        if let custom = args.customCharacters {
            characters += custom
        }
        
        guard !characters.isEmpty else {
            invoke.reject("No characters available for password generation")
            return
        }
        
        var password = ""
        for _ in 0..<args.length {
            let randomIndex = Int.random(in: 0..<characters.count)
            let index = characters.index(characters.startIndex, offsetBy: randomIndex)
            password.append(characters[index])
        }
        
        invoke.resolve(password)
    }
    
    @objc public func checkAuthentication(_ invoke: Invoke) throws {
        struct CheckAuthArgs: Decodable {
            let reason: String
        }
        
        let args = try invoke.parseArgs(CheckAuthArgs.self)
        
        let context = LAContext()
        var error: NSError?
        
        // Check if biometry is available
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        let biometryType: String
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                biometryType = "none"
            case .touchID:
                biometryType = "touchId"
            case .faceID:
                biometryType = "faceId"
            @unknown default:
                biometryType = "none"
            }
        } else {
            biometryType = canEvaluate ? "touchId" : "none"
        }
        
        if canEvaluate {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: args.reason) { success, error in
                invoke.resolve([
                    "success": success,
                    "biometryType": biometryType,
                    "error": error?.localizedDescription
                ])
            }
        } else {
            // Fall back to device passcode
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: args.reason) { success, error in
                invoke.resolve([
                    "success": success,
                    "biometryType": biometryType,
                    "error": error?.localizedDescription
                ])
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseAccessible(_ accessible: String) -> CFString {
        switch accessible {
        case "afterFirstUnlock":
            return kSecAttrAccessibleAfterFirstUnlock
        case "whenUnlockedThisDeviceOnly":
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case "afterFirstUnlockThisDeviceOnly":
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case "whenPasscodeSetThisDeviceOnly":
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        default:
            return kSecAttrAccessibleWhenUnlocked
        }
    }
    
    private func parseProtocol(_ proto: String) -> CFString {
        switch proto.lowercased() {
        case "http":
            return kSecAttrProtocolHTTP
        case "https":
            return kSecAttrProtocolHTTPS
        case "ftp":
            return kSecAttrProtocolFTP
        case "ftps":
            return kSecAttrProtocolFTPS
        case "smtp":
            return kSecAttrProtocolSMTP
        case "pop3":
            return kSecAttrProtocolPOP3
        case "imap":
            return kSecAttrProtocolIMAP
        case "ldap":
            return kSecAttrProtocolLDAP
        case "ssh":
            return kSecAttrProtocolSSH
        case "telnet":
            return kSecAttrProtocolTelnet
        default:
            return kSecAttrProtocolHTTPS
        }
    }
    
    private func protocolToString(_ proto: String?) -> String? {
        guard let proto = proto else { return nil }
        
        switch proto as CFString {
        case kSecAttrProtocolHTTP:
            return "http"
        case kSecAttrProtocolHTTPS:
            return "https"
        case kSecAttrProtocolFTP:
            return "ftp"
        case kSecAttrProtocolFTPS:
            return "ftps"
        case kSecAttrProtocolSMTP:
            return "smtp"
        case kSecAttrProtocolPOP3:
            return "pop3"
        case kSecAttrProtocolIMAP:
            return "imap"
        case kSecAttrProtocolLDAP:
            return "ldap"
        case kSecAttrProtocolSSH:
            return "ssh"
        case kSecAttrProtocolTelnet:
            return "telnet"
        default:
            return nil
        }
    }
    
    private func parseAuthenticationType(_ type: String) -> CFString {
        switch type.lowercased() {
        case "httpbasic":
            return kSecAttrAuthenticationTypeHTTPBasic
        case "httpdigest":
            return kSecAttrAuthenticationTypeHTTPDigest
        case "htmlform":
            return kSecAttrAuthenticationTypeHTMLForm
        case "ntlm":
            return kSecAttrAuthenticationTypeNTLM
        case "negotiate":
            return kSecAttrAuthenticationTypeNegotiate
        default:
            return kSecAttrAuthenticationTypeDefault
        }
    }
    
    private func authenticationTypeToString(_ type: String?) -> String? {
        guard let type = type else { return nil }
        
        switch type as CFString {
        case kSecAttrAuthenticationTypeHTTPBasic:
            return "httpBasic"
        case kSecAttrAuthenticationTypeHTTPDigest:
            return "httpDigest"
        case kSecAttrAuthenticationTypeHTMLForm:
            return "htmlForm"
        case kSecAttrAuthenticationTypeNTLM:
            return "ntlm"
        case kSecAttrAuthenticationTypeNegotiate:
            return "negotiate"
        default:
            return "default"
        }
    }
}

@_cdecl("init_plugin_ios_keychain")
func initPlugin() -> Plugin {
    return KeychainPlugin()
}