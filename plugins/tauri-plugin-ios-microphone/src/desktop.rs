use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{models::*, Result, Error};

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> Result<Microphone<R>> {
    Ok(Microphone(app.clone()))
}

/// Access to the microphone APIs on desktop (returns errors as not available).
pub struct Microphone<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Microphone<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        Err(Error::PermissionDenied)
    }

    pub fn request_permissions(&self) -> Result<PermissionStatus> {
        Err(Error::PermissionDenied)
    }

    pub fn start_recording(&self, _options: RecordingOptions) -> Result<RecordingSession> {
        Err(Error::OperationFailed("Not available on desktop".to_string()))
    }

    pub fn stop_recording(&self) -> Result<RecordingResult> {
        Err(Error::OperationFailed("Not recording".to_string()))
    }

    pub fn pause_recording(&self) -> Result<()> {
        Err(Error::OperationFailed("Not recording".to_string()))
    }

    pub fn resume_recording(&self) -> Result<()> {
        Err(Error::OperationFailed("Not recording".to_string()))
    }

    pub fn get_recording_state(&self) -> Result<RecordingState> {
        Ok(RecordingState::Idle)
    }

    pub fn get_audio_levels(&self) -> Result<AudioLevels> {
        Err(Error::OperationFailed("Not recording".to_string()))
    }

    pub fn get_available_inputs(&self) -> Result<Vec<AudioInput>> {
        Ok(vec![])
    }

    pub fn set_audio_input(&self, _input_id: &str) -> Result<()> {
        Err(Error::OperationFailed("Input not found".to_string()))
    }

    pub fn get_recording_duration(&self) -> Result<f64> {
        Err(Error::OperationFailed("Not recording".to_string()))
    }
}