import { invoke } from '@tauri-apps/api/core'

// Enums
export enum HandleType {
  Generic = 'generic',
  PhoneNumber = 'phoneNumber',
  EmailAddress = 'emailAddress'
}

export enum CallFailureReason {
  Failed = 'failed',
  RemoteEnded = 'remoteEnded',
  Unanswered = 'unanswered',
  AnsweredElsewhere = 'answeredElsewhere',
  DeclinedElsewhere = 'declinedElsewhere',
  CallerFiltered = 'callerFiltered'
}

export enum CallState {
  Idle = 'idle',
  Dialing = 'dialing',
  Incoming = 'incoming',
  Connecting = 'connecting',
  Connected = 'connected',
  Held = 'held',
  Disconnecting = 'disconnecting',
  Disconnected = 'disconnected'
}

export enum AudioRouteType {
  BuiltInReceiver = 'builtInReceiver',
  BuiltInSpeaker = 'builtInSpeaker',
  Bluetooth = 'bluetooth',
  BluetoothHfp = 'bluetoothHfp',
  BluetoothA2dp = 'bluetoothA2dp',
  BluetoothLe = 'bluetoothLe',
  CarAudio = 'carAudio',
  Wired = 'wired',
  AirPlay = 'airPlay',
  Unknown = 'unknown'
}

export enum TransactionAction {
  Start = 'start',
  Answer = 'answer',
  End = 'end',
  SetHeld = 'setHeld',
  SetMuted = 'setMuted',
  SetGroup = 'setGroup',
  PlayDtmf = 'playDtmf'
}

export enum AudioSessionCategory {
  Ambient = 'ambient',
  SoloAmbient = 'soloAmbient',
  Playback = 'playback',
  Record = 'record',
  PlayAndRecord = 'playAndRecord',
  MultiRoute = 'multiRoute'
}

export enum AudioSessionMode {
  Default = 'default',
  VoiceChat = 'voiceChat',
  VideoChat = 'videoChat',
  GameChat = 'gameChat',
  VideoRecording = 'videoRecording',
  Measurement = 'measurement',
  MoviePlayback = 'moviePlayback',
  SpokenAudio = 'spokenAudio'
}

export enum AudioSessionOption {
  MixWithOthers = 'mixWithOthers',
  DuckOthers = 'duckOthers',
  AllowBluetooth = 'allowBluetooth',
  DefaultToSpeaker = 'defaultToSpeaker',
  InterruptSpokenAudioAndMixWithOthers = 'interruptSpokenAudioAndMixWithOthers',
  AllowBluetoothA2dp = 'allowBluetoothA2dp',
  AllowAirPlay = 'allowAirPlay',
  OverrideMutedMicrophoneInterruption = 'overrideMutedMicrophoneInterruption'
}

export enum CallEventType {
  IncomingCall = 'incomingCall',
  OutgoingCall = 'outgoingCall',
  CallAnswered = 'callAnswered',
  CallEnded = 'callEnded',
  CallHeld = 'callHeld',
  CallResumed = 'callResumed',
  CallMuted = 'callMuted',
  CallUnmuted = 'callUnmuted',
  CallFailed = 'callFailed',
  AudioRouteChanged = 'audioRouteChanged',
  DtmfReceived = 'dtmfReceived'
}

// Interfaces
export interface ProviderConfiguration {
  localizedName: string
  ringtoneSound?: string
  iconTemplateImage?: string
  maximumCallGroups?: number
  maximumCallsPerGroup?: number
  supportsVideo?: boolean
  includeCallsInRecents?: boolean
  supportedHandleTypes?: HandleType[]
}

export interface CallHandle {
  handleType: HandleType
  value: string
}

export interface IncomingCallInfo {
  uuid: string
  handle: CallHandle
  hasVideo?: boolean
  callerName?: string
  supportsDtmf?: boolean
  supportsHolding?: boolean
  supportsGrouping?: boolean
  supportsUngrouping?: boolean
}

export interface OutgoingCallInfo {
  uuid: string
  handle: CallHandle
  hasVideo?: boolean
  contactIdentifier?: string
}

export interface CallUpdate {
  remoteHandle?: CallHandle
  localizedCallerName?: string
  supportsDtmf?: boolean
  supportsHolding?: boolean
  supportsGrouping?: boolean
  supportsUngrouping?: boolean
  hasVideo?: boolean
}

export interface Call {
  uuid: string
  handle: CallHandle
  outgoing: boolean
  hasConnected: boolean
  hasEnded: boolean
  onHold: boolean
  isMuted: boolean
  startTime?: string
  endTime?: string
  failureReason?: CallFailureReason
}

export interface AudioRoute {
  name: string
  routeType: AudioRouteType
  isSelected: boolean
}

export interface Transaction {
  action: TransactionAction
  callUuid: string
  timestamp: string
}

export interface CallCapability {
  canMakeCalls: boolean
  canReceiveCalls: boolean
  supportsVideo: boolean
  supportsVoip: boolean
  cellularProvider?: string
}

export interface VoipPushPayload {
  uuid: string
  handle: string
  hasVideo?: boolean
  callerName?: string
  customData?: Record<string, string>
}

export interface AudioSessionConfiguration {
  category: AudioSessionCategory
  mode: AudioSessionMode
  options?: AudioSessionOption[]
}

export interface CallEvent {
  eventType: CallEventType
  callUuid: string
  timestamp: string
  data?: any
}

// API Functions
export async function configureAudioSession(config: AudioSessionConfiguration): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|configure_audio_session', { config })
}

export async function reportIncomingCall(info: IncomingCallInfo): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|report_incoming_call', { info })
}

export async function reportOutgoingCall(info: OutgoingCallInfo): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|report_outgoing_call', { info })
}

export async function endCall(uuid: string, reason?: CallFailureReason): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|end_call', { uuid, reason })
}

export async function setHeld(uuid: string, onHold: boolean): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|set_held', { uuid, onHold })
}

export async function setMuted(uuid: string, muted: boolean): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|set_muted', { uuid, muted })
}

export async function setGroup(uuid: string, groupUuid?: string): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|set_group', { uuid, groupUuid })
}

export async function setOnHold(uuid: string, onHold: boolean): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|set_on_hold', { uuid, onHold })
}

export async function startCallAudio(uuid: string): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|start_call_audio', { uuid })
}

export async function answerCall(uuid: string): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|answer_call', { uuid })
}

export async function reportCallUpdate(uuid: string, update: CallUpdate): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|report_call_update', { uuid, update })
}

export async function getActiveCalls(): Promise<Call[]> {
  return await invoke('plugin:ios-callkit-v2|get_active_calls')
}

export async function getCallState(uuid: string): Promise<CallState> {
  return await invoke('plugin:ios-callkit-v2|get_call_state', { uuid })
}

export async function requestTransaction(transaction: Transaction): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|request_transaction', { transaction })
}

export async function reportAudioRouteChange(route: AudioRoute): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|report_audio_route_change', { route })
}

export async function setProviderConfiguration(config: ProviderConfiguration): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|set_provider_configuration', { config })
}

export async function registerForVoipNotifications(): Promise<string> {
  return await invoke('plugin:ios-callkit-v2|register_for_voip_notifications')
}

export async function invalidatePushToken(): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|invalidate_push_token')
}

export async function reportNewIncomingVoipPush(payload: VoipPushPayload): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|report_new_incoming_voip_push', { payload })
}

export async function checkCallCapability(): Promise<CallCapability> {
  return await invoke('plugin:ios-callkit-v2|check_call_capability')
}

export async function getAudioRoutes(): Promise<AudioRoute[]> {
  return await invoke('plugin:ios-callkit-v2|get_audio_routes')
}

export async function setAudioRoute(routeType: AudioRouteType): Promise<void> {
  return await invoke('plugin:ios-callkit-v2|set_audio_route', { routeType })
}
