use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`], [`tauri::WebviewWindow`], [`tauri::Webview`] and [`tauri::Window`] to access the microphone APIs.
pub trait MicrophoneExt<R: Runtime> {
    fn microphone(&self) -> &Microphone<R>;
}

impl<R: Runtime, T: Manager<R>> crate::MicrophoneExt<R> for T {
    fn microphone(&self) -> &Microphone<R> {
        self.state::<Microphone<R>>().inner()
    }
}

/// Access to the microphone APIs.
pub struct Microphone<R: Runtime>(MicrophoneImpl<R>);

#[cfg(desktop)]
type MicrophoneImpl<R> = desktop::Microphone<R>;
#[cfg(mobile)]
type MicrophoneImpl<R> = mobile::Microphone<R>;

impl<R: Runtime> Microphone<R> {
    pub fn check_permissions(&self) -> Result<PermissionStatus> {
        self.0.check_permissions()
    }

    pub fn request_permissions(&self) -> Result<PermissionStatus> {
        self.0.request_permissions()
    }

    pub fn start_recording(&self, options: RecordingOptions) -> Result<RecordingSession> {
        self.0.start_recording(options)
    }

    pub fn stop_recording(&self) -> Result<RecordingResult> {
        self.0.stop_recording()
    }

    pub fn pause_recording(&self) -> Result<()> {
        self.0.pause_recording()
    }

    pub fn resume_recording(&self) -> Result<()> {
        self.0.resume_recording()
    }

    pub fn get_recording_state(&self) -> Result<RecordingState> {
        self.0.get_recording_state()
    }

    pub fn get_audio_levels(&self) -> Result<AudioLevels> {
        self.0.get_audio_levels()
    }

    pub fn get_available_inputs(&self) -> Result<Vec<AudioInput>> {
        self.0.get_available_inputs()
    }

    pub fn set_audio_input(&self, input_id: &str) -> Result<()> {
        self.0.set_audio_input(input_id)
    }

    pub fn get_recording_duration(&self) -> Result<f64> {
        self.0.get_recording_duration()
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-microphone")
        .invoke_handler(tauri::generate_handler![
            commands::check_permissions,
            commands::request_permissions,
            commands::start_recording,
            commands::stop_recording,
            commands::pause_recording,
            commands::resume_recording,
            commands::get_recording_state,
            commands::get_audio_levels,
            commands::get_available_inputs,
            commands::set_audio_input,
            commands::get_recording_duration,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let microphone = mobile::init(app, api)?;
            #[cfg(desktop)]
            let microphone = desktop::init(app, api)?;
            
            app.manage(Microphone(microphone));
            Ok(())
        })
        .build()
}