use serde::Serialize;
use tauri::{AppHandle, Manager, Url};

use crate::bootstrap;
use crate::paths::{path_to_string, write_log, AppPaths};
use crate::process;

#[derive(Serialize)]
pub struct AppPathsDto {
    pub root: String,
    pub ui: String,
    pub cmd: String,
    pub logs: String,
}

#[tauri::command]
pub fn get_app_paths() -> AppPathsDto {
    let p = AppPaths::resolve();
    AppPathsDto {
        root: path_to_string(&p.root),
        ui: path_to_string(&p.ui),
        cmd: path_to_string(&p.cmd),
        logs: path_to_string(&p.logs),
    }
}

#[tauri::command]
pub fn install_bundled(app: AppHandle) -> Result<(), String> {
    let p = AppPaths::resolve();
    bootstrap::install_bundled_once(&app, &p)
}

#[tauri::command]
pub fn start_services(app: AppHandle) -> Result<(), String> {
    let p = AppPaths::resolve();
    process::start_all(&p)?;
    if let Some(w) = app.get_webview_window("main") {
        let _ = w.set_title(&crate::desktop_conf::app_name());
    }
    navigate_ui(&app, &p)?;
    Ok(())
}

pub fn navigate_ui(app: &AppHandle, paths: &AppPaths) -> Result<(), String> {
    if !paths.ui_index().is_file() {
        return Err(format!("UI 未安装: {}", paths.ui_index().display()));
    }
    let Some(w) = app.get_webview_window("main") else {
        return Err("主窗口不存在".into());
    };

    let port = paths.app_port();
    let url_str = format!("http://127.0.0.1:{port}/");
    let url = Url::parse(&url_str).map_err(|e| e.to_string())?;
    w.navigate(url)
        .map_err(|e| format!("navigate http failed: {e}"))?;
    let _ = w.set_title(&crate::desktop_conf::app_name());
    write_log(paths, &format!("navigate http ok: {url_str}"));
    Ok(())
}
