use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::{models::*, Result};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_microphone);

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> Result<Microphone<R>> {
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_microphone)?;
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.tauri.plugins.microphone", "MicrophonePlugin")?;
    
    Ok(Microphone(handle))
}

/// Access to the microphone APIs on mobile.
pub struct Microphone<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Microphone<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        self.0
            .run_mobile_plugin("checkPermissions", ())
            .map_err(Into::into)
    }

    pub fn request_permissions(&self) -> Result<PermissionStatus> {
        self.0
            .run_mobile_plugin("requestPermissions", ())
            .map_err(Into::into)
    }

    pub fn start_recording(&self, options: RecordingOptions) -> Result<RecordingSession> {
        self.0
            .run_mobile_plugin("startRecording", options)
            .map_err(Into::into)
    }

    pub fn stop_recording(&self) -> Result<RecordingResult> {
        self.0
            .run_mobile_plugin("stopRecording", ())
            .map_err(Into::into)
    }

    pub fn pause_recording(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("pauseRecording", ())
            .map_err(Into::into)
    }

    pub fn resume_recording(&self) -> Result<()> {
        self.0
            .run_mobile_plugin("resumeRecording", ())
            .map_err(Into::into)
    }

    pub fn get_recording_state(&self) -> Result<RecordingState> {
        self.0
            .run_mobile_plugin("getRecordingState", ())
            .map_err(Into::into)
    }

    pub fn get_audio_levels(&self) -> Result<AudioLevels> {
        self.0
            .run_mobile_plugin("getAudioLevels", ())
            .map_err(Into::into)
    }

    pub fn get_available_inputs(&self) -> Result<Vec<AudioInput>> {
        self.0
            .run_mobile_plugin("getAvailableInputs", ())
            .map_err(Into::into)
    }

    pub fn set_audio_input(&self, input_id: &str) -> Result<()> {
        #[derive(serde::Serialize)]
        struct SetInputArgs<'a> {
            input_id: &'a str,
        }
        
        self.0
            .run_mobile_plugin("setAudioInput", SetInputArgs { input_id })
            .map_err(Into::into)
    }

    pub fn get_recording_duration(&self) -> Result<f64> {
        self.0
            .run_mobile_plugin("getRecordingDuration", ())
            .map_err(Into::into)
    }
}