import { invoke } from '@tauri-apps/api/core'

// Enums
export enum IntentCategory {
  Information = 'information',
  Play = 'play',
  Order = 'order',
  Message = 'message',
  Call = 'call',
  Search = 'search',
  Create = 'create',
  Share = 'share',
  Toggle = 'toggle',
  Download = 'download'
}

export enum ParameterType {
  String = 'string',
  Number = 'number',
  Boolean = 'boolean',
  Date = 'date',
  Duration = 'duration',
  Location = 'location',
  Person = 'person',
  File = 'file'
}

export enum PredictionReason {
  TimeOfDay = 'timeOfDay',
  Location = 'location',
  UserBehavior = 'userBehavior',
  RecentUsage = 'recentUsage',
  ContextualRelevance = 'contextualRelevance'
}

export enum ShortcutEventType {
  Invoked = 'invoked',
  Added = 'added',
  Updated = 'updated',
  Deleted = 'deleted',
  Failed = 'failed'
}

// Interfaces
export interface Shortcut {
  identifier: string
  title: string
  suggestedInvocationPhrase?: string
  isEligibleForSearch?: boolean
  isEligibleForPrediction?: boolean
  userActivityType: string
  userInfo: Record<string, any>
  persistentIdentifier?: string
}

export interface IntentImage {
  systemName?: string
  templateName?: string
  data?: string
}

export interface IntentParameter {
  name: string
  value: any
  displayName: string
  prompt?: string
}

export interface Intent {
  identifier: string
  displayName: string
  category: IntentCategory | { custom: string }
  parameters: Record<string, IntentParameter>
  suggestedInvocationPhrase?: string
  image?: IntentImage
}

export interface Interaction {
  intent: Intent
  donationDate?: string
  shortcut?: Shortcut
}

export interface VoiceShortcut {
  identifier: string
  invocationPhrase: string
  shortcut: Shortcut
}

export interface ContentAttributes {
  title?: string
  contentDescription?: string
  thumbnailData?: string
  thumbnailUrl?: string
  keywords: string[]
}

export interface UserActivity {
  activityType: string
  title: string
  userInfo: Record<string, any>
  keywords: string[]
  persistentIdentifier?: string
  isEligibleForSearch?: boolean
  isEligibleForPublicIndexing?: boolean
  isEligibleForHandoff?: boolean
  isEligibleForPrediction?: boolean
  contentAttributes?: ContentAttributes
  requiredUserInfoKeys?: string[]
}

export interface ShortcutSuggestion {
  intent: Intent
  suggestedPhrase: string
}

export interface ParameterOption {
  identifier: string
  displayName: string
  synonyms: string[]
}

export interface ParameterDefinition {
  name: string
  displayName: string
  description: string
  parameterType: ParameterType | { custom: string }
  isRequired: boolean
  defaultValue?: any
  options: ParameterOption[]
}

export interface AppIntent {
  identifier: string
  displayName: string
  description: string
  category: IntentCategory | { custom: string }
  parameterDefinitions: ParameterDefinition[]
  responseTemplate?: string
}

export interface IntentResponse {
  success: boolean
  userActivity?: UserActivity
  output: Record<string, any>
  error?: string
}

export interface DonatedIntent {
  identifier: string
  intent: Intent
  donationDate: string
  interactionCount: number
}

export interface IntentPrediction {
  intent: Intent
  confidence: number
  reason: PredictionReason
}

export interface ShortcutEvent {
  eventType: ShortcutEventType
  shortcutIdentifier: string
  timestamp: string
  userInfo: Record<string, any>
}

// API Functions
export async function donateInteraction(interaction: Interaction): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|donate_interaction', { interaction })
}

export async function donateShortcut(shortcut: Shortcut): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|donate_shortcut', { shortcut })
}

export async function getAllShortcuts(): Promise<Shortcut[]> {
  return await invoke('plugin:ios-shortcuts-v2|get_all_shortcuts')
}

export async function deleteShortcut(identifier: string): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|delete_shortcut', { identifier })
}

export async function deleteAllShortcuts(): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|delete_all_shortcuts')
}

export async function getVoiceShortcuts(): Promise<VoiceShortcut[]> {
  return await invoke('plugin:ios-shortcuts-v2|get_voice_shortcuts')
}

export async function suggestPhrase(shortcutIdentifier: string): Promise<string> {
  return await invoke('plugin:ios-shortcuts-v2|suggest_phrase', { shortcutIdentifier })
}

export async function handleUserActivity(activity: UserActivity): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|handle_user_activity', { activity })
}

export async function updateShortcut(shortcut: Shortcut): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|update_shortcut', { shortcut })
}

export async function getShortcutSuggestions(): Promise<ShortcutSuggestion[]> {
  return await invoke('plugin:ios-shortcuts-v2|get_shortcut_suggestions')
}

export async function setShortcutSuggestions(suggestions: ShortcutSuggestion[]): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|set_shortcut_suggestions', { suggestions })
}

export async function createAppIntent(intent: AppIntent): Promise<string> {
  return await invoke('plugin:ios-shortcuts-v2|create_app_intent', { intent })
}

export async function registerAppIntents(intents: AppIntent[]): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|register_app_intents', { intents })
}

export async function handleIntent(intentId: string, parameters: Record<string, any>): Promise<IntentResponse> {
  return await invoke('plugin:ios-shortcuts-v2|handle_intent', { intentId, parameters })
}

export async function getDonatedIntents(): Promise<DonatedIntent[]> {
  return await invoke('plugin:ios-shortcuts-v2|get_donated_intents')
}

export async function deleteDonatedIntents(identifiers: string[]): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|delete_donated_intents', { identifiers })
}

export async function setEligibleForPrediction(intentIds: string[], eligible: boolean): Promise<void> {
  return await invoke('plugin:ios-shortcuts-v2|set_eligible_for_prediction', { intentIds, eligible })
}

export async function getPredictions(limit?: number): Promise<IntentPrediction[]> {
  return await invoke('plugin:ios-shortcuts-v2|get_predictions', { limit })
}