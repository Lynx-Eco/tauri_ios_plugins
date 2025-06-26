import Tauri
import MessageUI
import UIKit

// Request structures
struct ComposeMessageData: Decodable {
    let recipients: [String]
    let body: String?
    let subject: String?
    let attachments: [AttachmentData]
}

struct AttachmentData: Decodable {
    let data: AttachmentDataWrapper
    let filename: String
    let mimeType: String
}

struct AttachmentDataWrapper: Decodable {
    let base64: String?
    let url: String?
}

struct SendSmsData: Decodable {
    let to: String
    let body: String
    let sendImmediately: Bool
}

struct ConversationFilterData: Decodable {
    let unreadOnly: Bool
    let pinnedOnly: Bool
    let conversationTypes: [String]
    let participantIds: [String]
}

struct SearchQueryData: Decodable {
    let query: String
    let conversationId: String?
    let senderId: String?
    let dateFrom: String?
    let dateTo: String?
    let hasAttachments: Bool?
    let messageTypes: [String]
    let limit: Int?
}

class MessagesPlugin: Plugin, MFMessageComposeViewControllerDelegate {
    private var pendingInvoke: Invoke?
    private let iso8601Formatter = ISO8601DateFormatter()
    
    override init() {
        super.init()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
    @objc public func composeMessage(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(ComposeMessageData.self)
        
        guard MFMessageComposeViewController.canSendText() else {
            invoke.reject("Cannot send messages")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.pendingInvoke = invoke
            
            let messageController = MFMessageComposeViewController()
            messageController.messageComposeDelegate = self
            messageController.recipients = args.recipients
            messageController.body = args.body
            
            if MFMessageComposeViewController.canSendSubject(),
               let subject = args.subject {
                messageController.subject = subject
            }
            
            // Add attachments
            if MFMessageComposeViewController.canSendAttachments() {
                for attachment in args.attachments {
                    if let base64 = attachment.data.base64,
                       let data = Data(base64Encoded: base64) {
                        messageController.addAttachmentData(
                            data,
                            typeIdentifier: attachment.mimeType,
                            filename: attachment.filename
                        )
                    } else if let urlString = attachment.data.url,
                              let url = URL(string: urlString),
                              let data = try? Data(contentsOf: url) {
                        messageController.addAttachmentData(
                            data,
                            typeIdentifier: attachment.mimeType,
                            filename: attachment.filename
                        )
                    }
                }
            }
            
            self?.presentViewController(messageController)
        }
    }
    
    @objc public func composeImessage(_ invoke: Invoke) throws {
        // iOS doesn't differentiate between SMS and iMessage in the compose UI
        // The system automatically determines which to use based on the recipient
        try composeMessage(invoke)
    }
    
    @objc public func sendSms(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SendSmsData.self)
        
        if args.sendImmediately {
            // Direct SMS sending is not allowed on iOS for security reasons
            invoke.reject("Direct SMS sending is not allowed on iOS")
        } else {
            // Open message composer with pre-filled data
            let request = ComposeMessageData(
                recipients: [args.to],
                body: args.body,
                subject: nil,
                attachments: []
            )
            
            pendingInvoke = invoke
            
            DispatchQueue.main.async { [weak self] in
                do {
                    try self?.composeMessage(invoke)
                } catch {
                    invoke.reject("Failed to compose message: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc public func canSendText(_ invoke: Invoke) throws {
        invoke.resolve(MFMessageComposeViewController.canSendText())
    }
    
    @objc public func canSendSubject(_ invoke: Invoke) throws {
        invoke.resolve(MFMessageComposeViewController.canSendSubject())
    }
    
    @objc public func canSendAttachments(_ invoke: Invoke) throws {
        invoke.resolve(MFMessageComposeViewController.canSendAttachments())
    }
    
    @objc public func getConversationList(_ invoke: Invoke) throws {
        // iOS doesn't provide access to message history for privacy reasons
        // Return empty array or mock data
        invoke.resolve(["conversations": []])
    }
    
    @objc public func getConversation(_ invoke: Invoke) throws {
        struct GetConversationArgs: Decodable {
            let conversationId: String
        }
        
        let args = try invoke.parseArgs(GetConversationArgs.self)
        
        // iOS doesn't provide access to message history
        invoke.reject("Access to message history is not available on iOS")
    }
    
    @objc public func getMessages(_ invoke: Invoke) throws {
        struct GetMessagesArgs: Decodable {
            let conversationId: String
            let limit: Int?
            let before: String?
        }
        
        let args = try invoke.parseArgs(GetMessagesArgs.self)
        
        // iOS doesn't provide access to message history
        invoke.reject("Access to message history is not available on iOS")
    }
    
    @objc public func markAsRead(_ invoke: Invoke) throws {
        struct MarkAsReadArgs: Decodable {
            let messageIds: [String]
        }
        
        let args = try invoke.parseArgs(MarkAsReadArgs.self)
        
        // iOS doesn't provide access to modify message state
        invoke.reject("Cannot modify message state on iOS")
    }
    
    @objc public func deleteMessage(_ invoke: Invoke) throws {
        struct DeleteMessageArgs: Decodable {
            let messageId: String
        }
        
        let args = try invoke.parseArgs(DeleteMessageArgs.self)
        
        // iOS doesn't allow deleting messages programmatically
        invoke.reject("Cannot delete messages on iOS")
    }
    
    @objc public func searchMessages(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SearchQueryData.self)
        
        // iOS doesn't provide access to search messages
        invoke.reject("Message search is not available on iOS")
    }
    
    @objc public func getAttachments(_ invoke: Invoke) throws {
        struct GetAttachmentsArgs: Decodable {
            let messageId: String
        }
        
        let args = try invoke.parseArgs(GetAttachmentsArgs.self)
        
        // iOS doesn't provide access to message attachments
        invoke.reject("Access to message attachments is not available on iOS")
    }
    
    @objc public func saveAttachment(_ invoke: Invoke) throws {
        struct SaveAttachmentArgs: Decodable {
            let attachmentId: String
            let destination: String
        }
        
        let args = try invoke.parseArgs(SaveAttachmentArgs.self)
        
        // iOS doesn't provide access to save attachments
        invoke.reject("Cannot save message attachments on iOS")
    }
    
    @objc public func getMessageStatus(_ invoke: Invoke) throws {
        struct GetStatusArgs: Decodable {
            let messageId: String
        }
        
        let args = try invoke.parseArgs(GetStatusArgs.self)
        
        // iOS doesn't provide access to message status
        invoke.reject("Message status is not available on iOS")
    }
    
    @objc public func registerForNotifications(_ invoke: Invoke) throws {
        // Message notifications are handled by the system
        invoke.resolve()
    }
    
    @objc public func unregisterNotifications(_ invoke: Invoke) throws {
        // Message notifications are handled by the system
        invoke.resolve()
    }
    
    @objc public func checkImessageAvailability(_ invoke: Invoke) throws {
        let capabilities: [String: Any] = [
            "isAvailable": MFMessageComposeViewController.canSendText(),
            "isSignedIn": true, // Assumed if can send text
            "canSendMessages": MFMessageComposeViewController.canSendText(),
            "canReceiveMessages": true,
            "supportsEffects": true,
            "supportsStickers": true,
            "supportsTapback": true
        ]
        
        invoke.resolve(capabilities)
    }
    
    @objc public func getBlockedContacts(_ invoke: Invoke) throws {
        // iOS doesn't provide access to blocked contacts list
        invoke.reject("Blocked contacts list is not accessible on iOS")
    }
    
    @objc public func blockContact(_ invoke: Invoke) throws {
        struct BlockContactArgs: Decodable {
            let contactId: String
            let reason: String?
        }
        
        let args = try invoke.parseArgs(BlockContactArgs.self)
        
        // iOS doesn't allow blocking contacts programmatically
        invoke.reject("Cannot block contacts programmatically on iOS")
    }
    
    @objc public func unblockContact(_ invoke: Invoke) throws {
        struct UnblockContactArgs: Decodable {
            let contactId: String
        }
        
        let args = try invoke.parseArgs(UnblockContactArgs.self)
        
        // iOS doesn't allow unblocking contacts programmatically
        invoke.reject("Cannot unblock contacts programmatically on iOS")
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) { [weak self] in
            guard let invoke = self?.pendingInvoke else { return }
            self?.pendingInvoke = nil
            
            let response: [String: Any]
            
            switch result {
            case .sent:
                response = [
                    "sent": true,
                    "cancelled": false,
                    "error": NSNull()
                ]
            case .cancelled:
                response = [
                    "sent": false,
                    "cancelled": true,
                    "error": NSNull()
                ]
            case .failed:
                response = [
                    "sent": false,
                    "cancelled": false,
                    "error": "Failed to send message"
                ]
            @unknown default:
                response = [
                    "sent": false,
                    "cancelled": false,
                    "error": "Unknown error"
                ]
            }
            
            invoke.resolve(response)
        }
    }
    
    // MARK: - Helpers
    
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

@_cdecl("init_plugin_ios_messages")
func initPlugin() -> Plugin {
    return MessagesPlugin()
}