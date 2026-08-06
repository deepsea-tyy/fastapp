pub mod bootstrap;
pub mod commands;
pub mod download;
pub mod gpu;
pub mod hardware;
pub mod health;
pub mod manifest;
pub mod paths;
pub mod process;
pub mod setup;
pub mod state;

use tauri::{AppHandle, Manager};

use crate::paths::AppPaths;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let mut builder = tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            commands::get_app_paths,
            commands::get_install_state,
            commands::seed_bundled_components,
            commands::fetch_manifest,
            commands::download_component,
            commands::start_services,
            commands::stop_services,
            commands::health_check,
            commands::gpu_is_locked,
            commands::gpu_slots,
            commands::get_capabilities,
            commands::get_hardware_report,
            commands::write_tools_env,
            commands::download_model,
            commands::check_updates,
            commands::repair_component,
            commands::read_log_tail,
            commands::default_manifest_url,
        ])
        .setup(|app| {
            let paths = AppPaths::resolve();
            paths.ensure_dirs();
            setup::write_server_env_if_missing(&paths);
            gpu::spawn_poller(app.handle().clone());
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
            if let tauri::RunEvent::Exit = event {
                let paths = paths::AppPaths::resolve();
                process::stop_all(&paths);
            }
            if let tauri::RunEvent::WindowEvent {
                label,
                event: tauri::WindowEvent::CloseRequested { .. },
                ..
            } = event
            {
                if label == "main" {
                    let paths = paths::AppPaths::resolve();
                    process::stop_all(&paths);
                }
            }
            let _ = app_handle;
        });
}

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
