use tauri::{command, AppHandle, Runtime};

use crate::{MicrophoneExt, PermissionStatus, RecordingOptions, RecordingSession, RecordingResult, RecordingState, AudioLevels, AudioInput, Result};

#[command]
pub(crate) async fn check_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<PermissionStatus> {
    app.microphone().check_permissions()
}

#[command]
pub(crate) async fn request_permissions<R: Runtime>(
    app: AppHandle<R>,
) -> Result<PermissionStatus> {
    app.microphone().request_permissions()
}

#[command]
pub(crate) async fn start_recording<R: Runtime>(
    app: AppHandle<R>,
    options: Option<RecordingOptions>,
) -> Result<RecordingSession> {
    app.microphone().start_recording(options.unwrap_or_default())
}

#[command]
pub(crate) async fn stop_recording<R: Runtime>(
    app: AppHandle<R>,
) -> Result<RecordingResult> {
    app.microphone().stop_recording()
}

#[command]
pub(crate) async fn pause_recording<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.microphone().pause_recording()
}

#[command]
pub(crate) async fn resume_recording<R: Runtime>(
    app: AppHandle<R>,
) -> Result<()> {
    app.microphone().resume_recording()
}

#[command]
pub(crate) async fn get_recording_state<R: Runtime>(
    app: AppHandle<R>,
) -> Result<RecordingState> {
    app.microphone().get_recording_state()
}

#[command]
pub(crate) async fn get_audio_levels<R: Runtime>(
    app: AppHandle<R>,
) -> Result<AudioLevels> {
    app.microphone().get_audio_levels()
}

#[command]
pub(crate) async fn get_available_inputs<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Vec<AudioInput>> {
    app.microphone().get_available_inputs()
}

#[command]
pub(crate) async fn set_audio_input<R: Runtime>(
    app: AppHandle<R>,
    input_id: String,
) -> Result<()> {
    app.microphone().set_audio_input(&input_id)
}

#[command]
pub(crate) async fn get_recording_duration<R: Runtime>(
    app: AppHandle<R>,
) -> Result<f64> {
    app.microphone().get_recording_duration()
}