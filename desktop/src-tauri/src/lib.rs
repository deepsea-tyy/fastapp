pub mod bootstrap;
pub mod commands;
pub mod desktop_conf;
pub mod exec;
pub mod paths;
pub mod platform;
pub mod process;

use tauri::{AppHandle, Manager};

use crate::paths::AppPaths;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    setup_ctrlc_handler();

    let mut builder = tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            commands::get_app_paths,
            commands::install_bundled,
            commands::start_services,
        ])
        .setup(|app| {
            desktop_conf::init();
            let paths = AppPaths::resolve();
            paths.ensure_dirs();
            if let Some(w) = app.get_webview_window("main") {
                let _ = w.set_title(&desktop_conf::app_name());
            }
            setup_tray(app.handle());
            Ok(())
        });

    #[cfg(desktop)]
    {
        builder = builder.plugin(tauri_plugin_single_instance::init(|app, _args, _cwd| {
            if let Some(w) = app.get_webview_window("main") {
                let _ = w.set_focus();
                let _ = w.show();
            }
        }));
    }

    builder
        .build(tauri::generate_context!())
        .expect("error while building tauri application")
        .run(|app_handle, event| {
            match event {
                tauri::RunEvent::Exit | tauri::RunEvent::ExitRequested { .. } => {
                    let paths = paths::AppPaths::resolve();
                    process::stop_all(&paths);
                }
                tauri::RunEvent::WindowEvent {
                    label,
                    event: tauri::WindowEvent::CloseRequested { .. },
                    ..
                } if label == "main" => {
                    let paths = paths::AppPaths::resolve();
                    process::stop_all(&paths);
                }
                _ => {}
            }
            let _ = app_handle;
        });
}

#[cfg(unix)]
fn setup_ctrlc_handler() {
    let _ = ctrlc::set_handler(|| {
        let paths = AppPaths::resolve();
        process::stop_all(&paths);
        std::process::exit(0);
    });
}

#[cfg(not(unix))]
fn setup_ctrlc_handler() {}

fn setup_tray(app: &AppHandle) {
    use tauri::menu::{Menu, MenuItem};
    use tauri::tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent};
    let show = MenuItem::with_id(app, "show", "显示窗口", true, None::<&str>).unwrap();
    let quit = MenuItem::with_id(app, "quit", "退出", true, None::<&str>).unwrap();
    let menu = Menu::with_items(app, &[&show, &quit]).unwrap();
    let mut builder = TrayIconBuilder::new().menu(&menu);
    if let Some(icon) = app.default_window_icon() {
        builder = builder.icon(icon.clone());
    }
    let _tray = builder
        .on_menu_event(|app, event| match event.id.as_ref() {
            "show" => {
                if let Some(w) = app.get_webview_window("main") {
                    let _ = w.show();
                    let _ = w.set_focus();
                }
            }
            "quit" => {
                let paths = AppPaths::resolve();
                process::stop_all(&paths);
                app.exit(0);
            }
            _ => {}
        })
        .on_tray_icon_event(|tray, event| {
            if let TrayIconEvent::Click {
                button: MouseButton::Left,
                button_state: MouseButtonState::Up,
                ..
            } = event
            {
                let app = tray.app_handle();
                if let Some(w) = app.get_webview_window("main") {
                    let _ = w.show();
                    let _ = w.set_focus();
                }
            }
        })
        .build(app);
}
