import { invoke } from '@tauri-apps/api/core'

// Enums
export enum ConversationType {
  Sms = 'sms',
  Imessage = 'imessage',
  Group = 'group',
  Unknown = 'unknown'
}

export enum MessageType {
  Text = 'text',
  Image = 'image',
  Video = 'video',
  Audio = 'audio',
  Location = 'location',
  Contact = 'contact',
  File = 'file',
  Sticker = 'sticker',
  Gif = 'gif',
  Unknown = 'unknown'
}

export enum NotificationType {
  NewMessage = 'newMessage',
  MessageRead = 'messageRead',
  MessageDeleted = 'messageDeleted',
  TypingStarted = 'typingStarted',
  TypingEnded = 'typingEnded',
  ReactionAdded = 'reactionAdded',
  ReactionRemoved = 'reactionRemoved'
}

// Types
export type AttachmentData = 
  | { base64: string }
  | { url: string }

// Interfaces
export interface MessageAttachment {
  data: AttachmentData
  filename: string
  mimeType: string
}

export interface ComposeMessageRequest {
  recipients: string[]
  body?: string
  subject?: string
  attachments?: MessageAttachment[]
}

export interface SendSmsRequest {
  to: string
  body: string
  sendImmediately?: boolean
}

export interface Participant {
  id: string
  phoneNumber?: string
  email?: string
  displayName?: string
  avatar?: string
  isMe: boolean
}

export interface MessageAttachmentInfo {
  id: string
  filename: string
  mimeType: string
  size: number
  thumbnail?: string
  url?: string
}

export interface MessageReaction {
  sender: Participant
  reaction: string
  timestamp: string
}

export interface Message {
  id: string
  conversationId: string
  sender: Participant
  body?: string
  timestamp: string
  isFromMe: boolean
  isRead: boolean
  isDelivered: boolean
  isSent: boolean
  messageType: MessageType
  attachments: MessageAttachmentInfo[]
  reactions: MessageReaction[]
  threadIdentifier?: string
  replyToMessageId?: string
}

export interface Conversation {
  id: string
  participants: Participant[]
  lastMessage?: Message
  unreadCount: number
  isPinned: boolean
  isMuted: boolean
  hasAttachments: boolean
  conversationType: ConversationType
}

export interface MessageStatus {
  messageId: string
  isSent: boolean
  isDelivered: boolean
  isRead: boolean
  deliveryTime?: string
  readTime?: string
  error?: string
}

export interface SearchQuery {
  query: string
  conversationId?: string
  senderId?: string
  dateFrom?: string
  dateTo?: string
  hasAttachments?: boolean
  messageTypes?: MessageType[]
  limit?: number
}

export interface SearchResult {
  message: Message
  snippet: string
  matchRanges: [number, number][]
}

export interface ConversationFilter {
  unreadOnly?: boolean
  pinnedOnly?: boolean
  conversationTypes?: ConversationType[]
  participantIds?: string[]
}

export interface MessageNotification {
  conversationId: string
  message: Message
  notificationType: NotificationType
}

export interface BlockedContact {
  id: string
  phoneNumber?: string
  email?: string
  displayName?: string
  blockedDate: string
  reason?: string
}

export interface ComposeResult {
  sent: boolean
  cancelled: boolean
  error?: string
}

export interface ImessageCapabilities {
  isAvailable: boolean
  isSignedIn: boolean
  canSendMessages: boolean
  canReceiveMessages: boolean
  supportsEffects: boolean
  supportsStickers: boolean
  supportsTapback: boolean
}

export interface MessagingCapabilities {
  canSendText: boolean
  canSendSubject: boolean
  canSendAttachments: boolean
  maxAttachmentCount: number
  supportedAttachmentTypes: string[]
}

// API Functions
export async function composeMessage(request: ComposeMessageRequest): Promise<ComposeResult> {
  return await invoke('plugin:ios-messages-v2|compose_message', { request })
}

export async function composeImessage(request: ComposeMessageRequest): Promise<ComposeResult> {
  return await invoke('plugin:ios-messages-v2|compose_imessage', { request })
}

export async function sendSms(request: SendSmsRequest): Promise<string> {
  return await invoke('plugin:ios-messages-v2|send_sms', { request })
}

export async function canSendText(): Promise<boolean> {
  return await invoke('plugin:ios-messages-v2|can_send_text')
}

export async function canSendSubject(): Promise<boolean> {
  return await invoke('plugin:ios-messages-v2|can_send_subject')
}

export async function canSendAttachments(): Promise<boolean> {
  return await invoke('plugin:ios-messages-v2|can_send_attachments')
}

export async function getConversationList(filter?: ConversationFilter): Promise<Conversation[]> {
  return await invoke('plugin:ios-messages-v2|get_conversation_list', { filter })
}

export async function getConversation(conversationId: string): Promise<Conversation> {
  return await invoke('plugin:ios-messages-v2|get_conversation', { conversationId })
}

export async function getMessages(conversationId: string, limit?: number, before?: string): Promise<Message[]> {
  return await invoke('plugin:ios-messages-v2|get_messages', { conversationId, limit, before })
}

export async function markAsRead(messageIds: string[]): Promise<void> {
  return await invoke('plugin:ios-messages-v2|mark_as_read', { messageIds })
}

export async function deleteMessage(messageId: string): Promise<void> {
  return await invoke('plugin:ios-messages-v2|delete_message', { messageId })
}

export async function searchMessages(query: SearchQuery): Promise<SearchResult[]> {
  return await invoke('plugin:ios-messages-v2|search_messages', { query })
}

export async function getAttachments(messageId: string): Promise<MessageAttachmentInfo[]> {
  return await invoke('plugin:ios-messages-v2|get_attachments', { messageId })
}

export async function saveAttachment(attachmentId: string, destination: string): Promise<string> {
  return await invoke('plugin:ios-messages-v2|save_attachment', { attachmentId, destination })
}

export async function getMessageStatus(messageId: string): Promise<MessageStatus> {
  return await invoke('plugin:ios-messages-v2|get_message_status', { messageId })
}

export async function registerForNotifications(): Promise<void> {
  return await invoke('plugin:ios-messages-v2|register_for_notifications')
}

export async function unregisterNotifications(): Promise<void> {
  return await invoke('plugin:ios-messages-v2|unregister_notifications')
}

export async function checkImessageAvailability(): Promise<ImessageCapabilities> {
  return await invoke('plugin:ios-messages-v2|check_imessage_availability')
}

export async function getBlockedContacts(): Promise<BlockedContact[]> {
  return await invoke('plugin:ios-messages-v2|get_blocked_contacts')
}

export async function blockContact(contactId: string, reason?: string): Promise<void> {
  return await invoke('plugin:ios-messages-v2|block_contact', { contactId, reason })
}

export async function unblockContact(contactId: string): Promise<void> {
  return await invoke('plugin:ios-messages-v2|unblock_contact', { contactId })
}
