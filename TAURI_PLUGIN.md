Mobile Plugin Development
Plugin Development

Be sure that you’re familiar with the concepts covered in the Plugin Development guide as many concepts in this guide build on top of foundations covered there.

Plugins can run native mobile code written in Kotlin (or Java) and Swift. The default plugin template includes an Android library project using Kotlin and a Swift package including an example mobile command showing how to trigger its execution from Rust code.

Initialize Plugin Project
Follow the steps in the Plugin Development guide to initialize a new plugin project.

If you have an existing plugin and would like to add Android or iOS capabilities to it, you can use plugin android init and plugin ios init to bootstrap the mobile library projects and guide you through the changes needed.

The default plugin template splits the plugin’s implementation into two separate modules: desktop.rs and mobile.rs.

The desktop implementation uses Rust code to implement a functionality, while the mobile implementation sends a message to the native mobile code to execute a function and get a result back. If shared logic is needed across both implementations, it can be defined in lib.rs:

src/lib.rs
use tauri::Runtime;

impl<R: Runtime> <plugin-name><R> {
  pub fn do_something(&self) {
    // do something that is a shared implementation between desktop and mobile
  }
}

This implementation simplifies the process of sharing an API that can be used both by commands and Rust code.

Develop an Android Plugin
A Tauri plugin for Android is defined as a Kotlin class that extends app.tauri.plugin.Plugin and is annotated with app.tauri.annotation.TauriPlugin. Each method annotated with app.tauri.annotation.Command can be called by Rust or JavaScript.

Tauri uses Kotlin by default for the Android plugin implementation, but you can switch to Java if you prefer. After generating a plugin, right click the Kotlin plugin class in Android Studio and select the “Convert Kotlin file to Java file” option from the menu. Android Studio will guide you through the project migration to Java.

Develop an iOS Plugin
A Tauri plugin for iOS is defined as a Swift class that extends the Plugin class from the Tauri package. Each function with the @objc attribute and the (_ invoke: Invoke) parameter (for example @objc private func download(_ invoke: Invoke) { }) can be called by Rust or JavaScript.

The plugin is defined as a Swift package so that you can use its package manager to manage dependencies.

Plugin Configuration
Refer to the Plugin Configuration section of the Plugin Development guide for more details on developing plugin configurations.

The plugin instance on mobile has a getter for the plugin configuration:

Android
iOS
struct Config: Decodable {
  let timeout: Int?
}

class ExamplePlugin: Plugin {
  var timeout: Int? = 3000

  @objc public override func load(webview: WKWebView) {
    do {
      let config = try parseConfig(Config.self)
      self.timeout = config.timeout
    } catch {}
  }
}

Lifecycle Events
Plugins can hook into several lifecycle events:

load: When the plugin is loaded into the web view
onNewIntent: Android only, when the activity is re-launched
There are also the additional lifecycle events for plugins in the Plugin Development guide.

load
When: When the plugin is loaded into the web view
Why: Execute plugin initialization code
Android
iOS
class ExamplePlugin: Plugin {
  @objc public override func load(webview: WKWebView) {
    let timeout = self.config["timeout"] as? Int ?? 30
  }
}

onNewIntent
Note: This is only available on Android.

When: When the activity is re-launched. See Activity#onNewIntent for more information.
Why: Handle application re-launch such as when a notification is clicked or a deep link is accessed.
import android.app.Activity
import android.content.Intent
import app.tauri.annotation.TauriPlugin

@TauriPlugin
class ExamplePlugin(private val activity: Activity): Plugin(activity) {
  override fun onNewIntent(intent: Intent) {
    // handle new intent event
  }
}

Adding Mobile Commands
There is a plugin class inside the respective mobile projects where commands can be defined that can be called by the Rust code:

Android
iOS
class ExamplePlugin: Plugin {
  @objc public func openCamera(_ invoke: Invoke) throws {
    invoke.resolve(["path": "/path/to/photo.jpg"])
  }
}

Use the tauri::plugin::PluginHandle to call a mobile command from Rust:

use std::path::PathBuf;
use serde::{Deserialize, Serialize};
use tauri::Runtime;

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CameraRequest {
  quality: usize,
  allow_edit: bool,
}

#[derive(Deserialize)]
pub struct Photo {
  path: PathBuf,
}


impl<R: Runtime> <plugin-name;pascal-case><R> {
  pub fn open_camera(&self, payload: CameraRequest) -> crate::Result<Photo> {
    self
      .0
      .run_mobile_plugin("openCamera", payload)
      .map_err(Into::into)
  }
}

Command Arguments
Arguments are serialized to commands and can be parsed on the mobile plugin with the Invoke::parseArgs function, taking a class describing the argument object.

Android
On Android, the arguments are defined as a class annotated with @app.tauri.annotation.InvokeArg. Inner objects must also be annotated:

import android.app.Activity
import android.webkit.WebView
import app.tauri.annotation.Command
import app.tauri.annotation.InvokeArg
import app.tauri.annotation.TauriPlugin

@InvokeArg
internal class OpenAppArgs {
  lateinit var name: String
  var timeout: Int? = null
}

@InvokeArg
internal class OpenArgs {
  lateinit var requiredArg: String
  var allowEdit: Boolean = false
  var quality: Int = 100
  var app: OpenAppArgs? = null
}

@TauriPlugin
class ExamplePlugin(private val activity: Activity): Plugin(activity) {
  @Command
  fun openCamera(invoke: Invoke) {
    val args = invoke.parseArgs(OpenArgs::class.java)
  }
}

Note

Optional arguments are defined as var <argumentName>: Type? = null

Arguments with default values are defined as var <argumentName>: Type = <default-value>

Required arguments are defined as lateinit var <argumentName>: Type

iOS
On iOS, the arguments are defined as a class that inherits Decodable. Inner objects must also inherit the Decodable protocol:

class OpenAppArgs: Decodable {
  let name: String
  var timeout: Int?
}

class OpenArgs: Decodable {
  let requiredArg: String
  var allowEdit: Bool?
  var quality: UInt8?
  var app: OpenAppArgs?
}

class ExamplePlugin: Plugin {
  @objc public func openCamera(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(OpenArgs.self)

    invoke.resolve(["path": "/path/to/photo.jpg"])
  }
}

Note

Optional arguments are defined as var <argumentName>: Type?

Arguments with default values are NOT supported. Use a nullable type and set the default value on the command function instead.

Required arguments are defined as let <argumentName>: Type

Permissions
If a plugin requires permissions from the end user, Tauri simplifies the process of checking and requesting permissions.

Android
iOS
First override the checkPermissions and requestPermissions functions:

class ExamplePlugin: Plugin {
  @objc open func checkPermissions(_ invoke: Invoke) {
    invoke.resolve(["postNotification": "prompt"])
  }

  @objc public override func requestPermissions(_ invoke: Invoke) {
    // request permissions here
    // then resolve the request
    invoke.resolve(["postNotification": "granted"])
  }
}

Tauri automatically implements two commands for the plugin: checkPermissions and requestPermissions. Those commands can be directly called from JavaScript or Rust:

JavaScript
Rust
use serde::{Serialize, Deserialize};
use tauri::{plugin::PermissionState, Runtime};

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct PermissionResponse {
  pub post_notification: PermissionState,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct RequestPermission {
  post_notification: bool,
}

impl<R: Runtime> Notification<R> {
  pub fn request_post_notification_permission(&self) -> crate::Result<PermissionState> {
    self.0
      .run_mobile_plugin::<PermissionResponse>("requestPermissions", RequestPermission { post_notification: true })
      .map(|r| r.post_notification)
      .map_err(Into::into)
  }

  pub fn check_permissions(&self) -> crate::Result<PermissionResponse> {
    self.0
      .run_mobile_plugin::<PermissionResponse>("checkPermissions", ())
      .map_err(Into::into)
  }
}

Plugin Events
Plugins can emit events at any point of time using the trigger function:

Android
iOS
class ExamplePlugin: Plugin {
  @objc public override func load(webview: WKWebView) {
    trigger("load", data: [:])
  }

  @objc public func openCamera(_ invoke: Invoke) {
    trigger("camera", data: ["open": true])
  }
}

The helper functions can then be called from the NPM package by using the addPluginListener helper function:

import { addPluginListener, PluginListener } from '@tauri-apps/api/core';

export async function onRequest(
  handler: (url: string) => void
): Promise<PluginListener> {
  return await addPluginListener(
    '<plugin-name>',
    'event-name',
    handler
  );
}



Plugin Development
Plugin Development

This guide is for developing Tauri plugins. If you’re looking for a list of the currently available plugins and how to use them then visit the Features and Recipes list.

Plugins are able to hook into the Tauri lifecycle, expose Rust code that relies on the web view APIs, handle commands with Rust, Kotlin or Swift code, and much more.

Tauri offers a windowing system with web view functionality, a way to send messages between the Rust process and the web view, and an event system along with several tools to enhance the development experience. By design, the Tauri core does not contain features not needed by everyone. Instead it offers a mechanism to add external functionalities into a Tauri application called plugins.

A Tauri plugin is composed of a Cargo crate and an optional NPM package that provides API bindings for its commands and events. Additionally, a plugin project can include an Android library project and a Swift package for iOS. You can learn more about developing plugins for Android and iOS in the Mobile Plugin Development guide.

Naming Convention
Tauri plugins have a prefix followed by the plugin name. The plugin name is specified on the plugin configuration under tauri.conf.json > plugins.

By default Tauri prefixes your plugin crate with tauri-plugin-. This helps your plugin to be discovered by the Tauri community and to be used with the Tauri CLI. When initializing a new plugin project, you must provide its name. The generated crate name will be tauri-plugin-{plugin-name} and the JavaScript NPM package name will be tauri-plugin-{plugin-name}-api (although we recommend using an NPM scope if possible). The Tauri naming convention for NPM packages is @scope-name/plugin-{plugin-name}.

Initialize Plugin Project
To bootstrap a new plugin project, run plugin new. If you do not need the NPM package, use the --no-api CLI flag. If you want to initialize the plugin with Android and/or iOS support, use the --android and/or --ios flags.

After installing, you can run the following to create a plugin project:

npm
npx @tauri-apps/cli plugin new [name]

This will initialize the plugin at the directory tauri-plugin-[name] and, depending on the used CLI flags, the resulting project will look like this:

. tauri-plugin-[name]/
├── src/                - Rust code
│ ├── commands.rs       - Defines the commands the webview can use
| ├── desktop.rs        - Desktop implementation
| ├── error.rs          - Default error type to use in returned results
│ ├── lib.rs            - Re-exports appropriate implementation, setup state...
│ ├── mobile.rs         - Mobile implementation
│ └── models.rs         - Shared structs
├── permissions/        - This will host (generated) permission files for commands
├── android             - Android library
├── ios                 - Swift package
├── guest-js            - Source code of the JavaScript API bindings
├── dist-js             - Transpiled assets from guest-js
├── Cargo.toml          - Cargo crate metadata
└── package.json        - NPM package metadata

If you have an existing plugin and would like to add Android or iOS capabilities to it, you can use plugin android add and plugin ios add to bootstrap the mobile library projects and guide you through the changes needed.

Mobile Plugin Development
Plugins can run native mobile code written in Kotlin (or Java) and Swift. The default plugin template includes an Android library project using Kotlin and a Swift package. It includes an example mobile command showing how to trigger its execution from Rust code.

Read more about developing plugins for mobile in the Mobile Plugin Development guide.

Plugin Configuration
In the Tauri application where the plugin is used, the plugin configuration is specified on tauri.conf.json where plugin-name is the name of the plugin:

{
  "build": { ... },
  "tauri": { ... },
  "plugins": {
    "plugin-name": {
      "timeout": 30
    }
  }
}

The plugin’s configuration is set on the Builder and is parsed at runtime. Here is an example of the Config struct being used to specify the plugin configuration:

src/lib.rs
use tauri::plugin::{Builder, Runtime, TauriPlugin};
use serde::Deserialize;

// Define the plugin config
#[derive(Deserialize)]
struct Config {
  timeout: usize,
}

pub fn init<R: Runtime>() -> TauriPlugin<R, Config> {
  // Make the plugin config optional
  // by using `Builder::<R, Option<Config>>` instead
  Builder::<R, Config>::new("<plugin-name>")
    .setup(|app, api| {
      let timeout = api.config().timeout;
      Ok(())
    })
    .build()
}

Lifecycle Events
Plugins can hook into several lifecycle events:

setup: Plugin is being initialized
on_navigation: Web view is attempting to perform navigation
on_webview_ready: New window is being created
on_event: Event loop events
on_drop: Plugin is being deconstructed
There are additional lifecycle events for mobile plugins.

setup
When: Plugin is being initialized
Why: Register mobile plugins, manage state, run background tasks
src/lib.rs
use tauri::{Manager, plugin::Builder};
use std::{collections::HashMap, sync::Mutex, time::Duration};

struct DummyStore(Mutex<HashMap<String, String>>);

Builder::new("<plugin-name>")
  .setup(|app, api| {
    app.manage(DummyStore(Default::default()));

    let app_ = app.clone();
    std::thread::spawn(move || {
      loop {
        app_.emit("tick", ());
        std::thread::sleep(Duration::from_secs(1));
      }
    });

    Ok(())
  })

on_navigation
When: Web view is attempting to perform navigation
Why: Validate the navigation or track URL changes
Returning false cancels the navigation.

src/lib.rs
use tauri::plugin::Builder;

Builder::new("<plugin-name>")
  .on_navigation(|window, url| {
    println!("window {} is navigating to {}", window.label(), url);
    // Cancels the navigation if forbidden
    url.scheme() != "forbidden"
  })

on_webview_ready
When: New window has been created
Why: Execute an initialization script for every window
src/lib.rs
use tauri::plugin::Builder;

Builder::new("<plugin-name>")
  .on_webview_ready(|window| {
    window.listen("content-loaded", |event| {
      println!("webview content has been loaded");
    });
  })

on_event
When: Event loop events
Why: Handle core events such as window events, menu events and application exit requested
With this lifecycle hook you can be notified of any event loop events.

src/lib.rs
use std::{collections::HashMap, fs::write, sync::Mutex};
use tauri::{plugin::Builder, Manager, RunEvent};

struct DummyStore(Mutex<HashMap<String, String>>);

Builder::new("<plugin-name>")
  .setup(|app, _api| {
    app.manage(DummyStore(Default::default()));
    Ok(())
  })
  .on_event(|app, event| {
    match event {
      RunEvent::ExitRequested { api, .. } => {
        // user requested a window to be closed and there's no windows left

        // we can prevent the app from exiting:
        api.prevent_exit();
      }
      RunEvent::Exit => {
        // app is going to exit, you can cleanup here

        let store = app.state::<DummyStore>();
        write(
          app.path().app_local_data_dir().unwrap().join("store.json"),
          serde_json::to_string(&*store.0.lock().unwrap()).unwrap(),
        )
        .unwrap();
      }
      _ => {}
    }
  })

on_drop
When: Plugin is being deconstructed
Why: Execute code when the plugin has been destroyed
See Drop for more information.

src/lib.rs
use tauri::plugin::Builder;

Builder::new("<plugin-name>")
  .on_drop(|app| {
    // plugin has been destroyed...
  })

Exposing Rust APIs
The plugin APIs defined in the project’s desktop.rs and mobile.rs are exported to the user as a struct with the same name as the plugin (in pascal case). When the plugin is setup, an instance of this struct is created and managed as a state so that users can retrieve it at any point in time with a Manager instance (such as AppHandle, App, or Window) through the extension trait defined in the plugin.

For example, the global-shortcut plugin defines a GlobalShortcut struct that can be read by using the global_shortcut method of the GlobalShortcutExt trait:

src-tauri/src/lib.rs
use tauri_plugin_global_shortcut::GlobalShortcutExt;

tauri::Builder::default()
  .plugin(tauri_plugin_global_shortcut::init())
  .setup(|app| {
    app.global_shortcut().register(...);
    Ok(())
  })

Adding Commands
Commands are defined in the commands.rs file. They are regular Tauri applications commands. They can access the AppHandle and Window instances directly, access state, and take input the same way as application commands. Read the Commands guide for more details on Tauri commands.

This command shows how to get access to the AppHandle and Window instance via dependency injection, and takes two input parameters (on_progress and url):

src/commands.rs
use tauri::{command, ipc::Channel, AppHandle, Runtime, Window};

#[command]
async fn upload<R: Runtime>(app: AppHandle<R>, window: Window<R>, on_progress: Channel, url: String) {
  // implement command logic here
  on_progress.send(100).unwrap();
}

To expose the command to the webview, you must hook into the invoke_handler() call in lib.rs:

src/lib.rs
Builder::new("<plugin-name>")
    .invoke_handler(tauri::generate_handler![commands::upload])

Define a binding function in webview-src/index.ts so that plugin users can easily call the command in JavaScript:

import { invoke, Channel } from '@tauri-apps/api/core'

export async function upload(url: string, onProgressHandler: (progress: number) => void): Promise<void> {
  const onProgress = new Channel<number>()
  onProgress.onmessage = onProgressHandler
  await invoke('plugin:<plugin-name>|upload', { url, onProgress })
}

Be sure to build the TypeScript code prior to testing it.

Command Permissions
By default your commands are not accessible by the frontend. If you try to execute one of them, you will get a denied error rejection. To actually expose commands, you also need to define permissions that allow each command.

Permission Files
Permissions are defined as JSON or TOML files inside the permissions directory. Each file can define a list of permissions, a list of permission sets and your plugin’s default permission.

Permissions
A permission describes privileges of your plugin commands. It can allow or deny a list of commands and associate command-specific and global scopes.

permissions/start-server.toml
"$schema" = "schemas/schema.json"

[[permission]]
identifier = "allow-start-server"
description = "Enables the start_server command."
commands.allow = ["start_server"]

[[permission]]
identifier = "deny-start-server"
description = "Denies the start_server command."
commands.deny = ["start_server"]

Scope
Scopes allow your plugin to define deeper restrictions to individual commands. Each permission can define a list of scope objects that define something to be allowed or denied either specific to a command or globally to the plugin.

Let’s define an example struct that will hold scope data for a list of binaries a shell plugin is allowed to spawn:

src/scope.rs
#[derive(Debug, schemars::JsonSchema)]
pub struct Entry {
    pub binary: String,
}

Command Scope
Your plugin consumer can define a scope for a specific command in their capability file (see the documentation). You can read the command-specific scope with the tauri::ipc::CommandScope struct:

src/commands.rs
use tauri::ipc::CommandScope;
use crate::scope::Entry;

async fn spawn<R: tauri::Runtime>(app: tauri::AppHandle<R>, command_scope: CommandScope<'_, Entry>) -> Result<()> {
  let allowed = command_scope.allows();
  let denied = command_scope.denies();
  todo!()
}

Global Scope
When a permission does not define any commands to be allowed or denied, it’s considered a scope permission and it should only define a global scope for your plugin:

permissions/spawn-node.toml
[[permission]]
identifier = "allow-spawn-node"
description = "This scope permits spawning the `node` binary."

[[permission.scope.allow]]
binary = "node"

You can read the global scope with the tauri::ipc::GlobalScope struct:

src/commands.rs
use tauri::ipc::GlobalScope;
use crate::scope::Entry;

async fn spawn<R: tauri::Runtime>(app: tauri::AppHandle<R>, scope: GlobalScope<'_, Entry>) -> Result<()> {
  let allowed = scope.allows();
  let denied = scope.denies();
  todo!()
}

Note

We recommend checking both global and command scopes for flexibility

Schema
The scope entry requires the schemars dependency to generate a JSON schema so the plugin consumers know the format of the scope and have autocomplete in their IDEs.

To define the schema, first add the dependency to your Cargo.toml file:

# we need to add schemars to both dependencies and build-dependencies because the scope.rs module is shared between the app code and build script
[dependencies]
schemars = "0.8"

[build-dependencies]
schemars = "0.8"

In your build script, add the following code:

build.rs
#[path = "src/scope.rs"]
mod scope;

const COMMANDS: &[&str] = &[];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .global_scope_schema(schemars::schema_for!(scope::Entry))
        .build();
}

Permission Sets
Permission sets are groups of individual permissions that helps users manage your plugin with a higher level of abstraction. For instance if a single API uses multiple commands or if there’s a logical connection between a collection of commands, you should define a set containing them:

permissions/websocket.toml
"$schema" = "schemas/schema.json"
[[set]]
identifier = "allow-websocket"
description = "Allows connecting and sending messages through a WebSocket"
permissions = ["allow-connect", "allow-send"]

Default Permission
The default permission is a special permission set with identifier default. It’s recommended that you enable required commands by default. For instance the http plugin is useless without the request command allowed:

permissions/default.toml
"$schema" = "schemas/schema.json"
[default]
description = "Allows making HTTP requests"
permissions = ["allow-request"]

Autogenerated Permissions
The easiest way to define permissions for each of your commands is to use the autogeneration option defined in your plugin’s build script defined in the build.rs file. Inside the COMMANDS const, define the list of commands in snake_case (should match the command function name) and Tauri will automatically generate an allow-$commandname and a deny-$commandname permissions.

The following example generates the allow-upload and deny-upload permissions:

src/commands.rs
const COMMANDS: &[&str] = &["upload"];

fn main() {
    tauri_plugin::Builder::new(COMMANDS).build();
}

See the Permissions Overview documentation for more information.

Managing State
A plugin can manage state in the same way a Tauri application does. Read the State Management guide for more information.

State Management
In a Tauri application, you often need to keep track of the current state of your application or manage the lifecycle of things associated with it. Tauri provides an easy way to manage the state of your application using the Manager API, and read it when commands are called.

Here is a simple example:

use tauri::{Builder, Manager};

struct AppData {
  welcome_message: &'static str,
}

fn main() {
  Builder::default()
    .setup(|app| {
      app.manage(AppData {
        welcome_message: "Welcome to Tauri!",
      });
      Ok(())
    })
    .run(tauri::generate_context!())
    .unwrap();
}

You can later access your state with any type that implements the Manager trait, for example the App instance:

let data = app.state::<AppData>();

For more info, including accessing state in commands, see the Accessing State section.

Mutability
In Rust, you cannot directly mutate values which are shared between multiple threads or when ownership is controlled through a shared pointer such as Arc (or Tauri’s State). Doing so could cause data races (for example, two writes happening simultaneously).

To work around this, you can use a concept known as interior mutability. For example, the standard library’s Mutex can be used to wrap your state. This allows you to lock the value when you need to modify it, and unlock it when you are done.

use std::sync::Mutex;

use tauri::{Builder, Manager};

#[derive(Default)]
struct AppState {
  counter: u32,
}

fn main() {
  Builder::default()
    .setup(|app| {
      app.manage(Mutex::new(AppState::default()));
      Ok(())
    })
    .run(tauri::generate_context!())
    .unwrap();
}

The state can now be modified by locking the mutex:

let state = app.state::<Mutex<AppState>>();

// Lock the mutex to get mutable access:
let mut state = state.lock().unwrap();

// Modify the state:
state.counter += 1;

At the end of the scope, or when the MutexGuard is otherwise dropped, the mutex is unlocked automatically so that other parts of your application can access and mutate the data within.

When to use an async mutex
To quote the Tokio documentation, it’s often fine to use the standard library’s Mutex instead of an async mutex such as the one Tokio provides:

Contrary to popular belief, it is ok and often preferred to use the ordinary Mutex from the standard library in asynchronous code … The primary use case for the async mutex is to provide shared mutable access to IO resources such as a database connection.

It’s a good idea to read the linked documentation fully to understand the trade-offs between the two. One reason you would need an async mutex is if you need to hold the MutexGuard across await points.

Do you need Arc?
It’s common to see Arc used in Rust to share ownership of a value across multiple threads (usually paired with a Mutex in the form of Arc<Mutex<T>>). However, you don’t need to use Arc for things stored in State because Tauri will do this for you.

In case State’s lifetime requirements prevent you from moving your state into a new thread you can instead move an AppHandle into the thread and then retrieve your state as shown below in the “Access state with the Manager trait” section. AppHandles are deliberately cheap to clone for use-cases like this.

Accessing State
Access state in commands
#[tauri::command]
fn increase_counter(state: State<'_, Mutex<AppState>>) -> u32 {
  let mut state = state.lock().unwrap();
  state.counter += 1;
  state.counter
}

For more information on commands, see Calling Rust from the Frontend.

Async commands
If you are using async commands and want to use Tokio’s async Mutex, you can set it up the same way and access the state like this:

#[tauri::command]
async fn increase_counter(state: State<'_, Mutex<AppState>>) -> Result<u32, ()> {
  let mut state = state.lock().await;
  state.counter += 1;
  Ok(state.counter)
}

Note that the return type must be Result if you use asynchronous commands.

Access state with the Manager trait
Sometimes you may need to access the state outside of commands, such as in a different thread or in an event handler like on_window_event. In such cases, you can use the state() method of types that implement the Manager trait (such as the AppHandle) to get the state:

use std::sync::Mutex;
use tauri::{Builder, Window, WindowEvent, Manager};

#[derive(Default)]
struct AppState {
  counter: u32,
}

// In an event handler:
fn on_window_event(window: &Window, _event: &WindowEvent) {
    // Get a handle to the app so we can get the global state.
    let app_handle = window.app_handle();
    let state = app_handle.state::<Mutex<AppState>>();

    // Lock the mutex to mutably access the state.
    let mut state = state.lock().unwrap();
    state.counter += 1;
}

fn main() {
  Builder::default()
    .setup(|app| {
      app.manage(Mutex::new(AppState::default()));
      Ok(())
    })
    .on_window_event(on_window_event)
    .run(tauri::generate_context!())
    .unwrap();
}

This method is useful when you cannot rely on command injection. For example, if you need to move the state into a thread where using an AppHandle is easier, or if you are not in a command context.

Mismatching Types
Caution

If you use the wrong type for the State parameter, you will get a runtime panic instead of compile time error.

For example, if you use State<'_, AppState> instead of State<'_, Mutex<AppState>>, there won’t be any state managed with that type.

If you prefer, you can wrap your state with a type alias to prevent this mistake:

use std::sync::Mutex;

#[derive(Default)]
struct AppStateInner {
  counter: u32,
}

type AppState = Mutex<AppStateInner>;

However, make sure to use the type alias as it is, and not wrap it in a Mutex a second time, otherwise you will run into the same issue.