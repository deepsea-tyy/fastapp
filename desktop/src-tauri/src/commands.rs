use serde::Serialize;
use tauri::{AppHandle, Manager};

use crate::bootstrap;
use crate::download::{self, make_cmd_executable};
use crate::gpu;
use crate::hardware;
use crate::health;
use crate::manifest::{self, ManifestInfo, DEFAULT_MANIFEST_URL};
use crate::paths::{path_to_string, AppPaths};
use crate::process;
use crate::setup;
use crate::state::{self, AppState};

#[derive(Serialize)]
pub struct AppPathsDto {
    pub root: String,
    pub server: String,
    pub ui: String,
    pub tools: String,
    pub cmd: String,
    pub logs: String,
}

#[derive(Serialize)]
pub struct InstallStateDto {
    pub ready: bool,
    pub components: std::collections::HashMap<String, bool>,
    pub versions: std::collections::HashMap<String, String>,
}

#[derive(Serialize)]
pub struct CapabilityItem {
    pub name: String,
    pub tier: String,
    pub r#impl: String,
    pub available: bool,
}

#[tauri::command]
pub fn get_app_paths() -> AppPathsDto {
    let p = AppPaths::resolve();
    AppPathsDto {
        root: path_to_string(&p.root),
        server: path_to_string(&p.server),
        ui: path_to_string(&p.ui),
        tools: path_to_string(&p.tools),
        cmd: path_to_string(&p.cmd),
        logs: path_to_string(&p.logs),
    }
}

#[tauri::command]
pub fn get_install_state() -> InstallStateDto {
    let p = AppPaths::resolve();
    let mut st = AppState::load(&p);
    state::refresh_install_flags(&p, &mut st);
    st.save(&p);
    InstallStateDto {
        ready: st.setup_done,
        components: st.components,
        versions: st.versions,
    }
}

#[tauri::command]
pub fn seed_bundled_components(app: AppHandle) -> Result<(), String> {
    let p = AppPaths::resolve();
    p.ensure_dirs();
    bootstrap::seed_bundled_components(&app, &p)
}

#[tauri::command]
pub fn fetch_manifest(url: Option<String>) -> Result<ManifestInfo, String> {
    let p = AppPaths::resolve();
    let u = url.unwrap_or_else(|| DEFAULT_MANIFEST_URL.into());
    let m = manifest::fetch(&u, &p)?;
    Ok(ManifestInfo {
        app_version: m.app_version,
        channel: m.channel,
    })
}

#[tauri::command]
pub fn download_component(component: String) -> Result<(), String> {
    let p = AppPaths::resolve();
    download::download_and_install(&component, &p)?;
    make_cmd_executable(&p);
    let mut st = AppState::load(&p);
    state::refresh_install_flags(&p, &mut st);
    st.save(&p);
    Ok(())
}

#[tauri::command]
pub fn start_services(app: AppHandle) -> Result<(), String> {
    let p = AppPaths::resolve();
    process::start_all(&p)?;
    navigate_ui(&app, &p);
    Ok(())
}

#[tauri::command]
pub fn stop_services() -> Result<(), String> {
    let p = AppPaths::resolve();
    process::stop_all(&p);
    Ok(())
}

#[tauri::command]
pub fn health_check() -> health::ServiceHealth {
    health::check()
}

#[tauri::command]
pub fn gpu_is_locked() -> bool {
    gpu::is_locked()
}

#[tauri::command]
pub fn gpu_slots() -> gpu::GpuSlots {
    gpu::fetch_slots()
}

#[tauri::command]
pub fn get_hardware_report() -> hardware::HardwareReport {
    hardware::hardware_report()
}

#[tauri::command]
pub fn get_capabilities() -> Vec<CapabilityItem> {
    let url = "http://127.0.0.1:8312/v1/scheduler/capabilities";
    let resp = reqwest::blocking::get(url);
    let mut out = vec![];
    if let Ok(r) = resp {
        if let Ok(v) = r.json::<serde_json::Value>() {
            if let Some(arr) = v.get("capabilities").and_then(|c| c.as_array()) {
                for item in arr {
                    out.push(CapabilityItem {
                        name: item
                            .get("name")
                            .and_then(|x| x.as_str())
                            .unwrap_or("")
                            .into(),
                        tier: item
                            .get("tier")
                            .and_then(|x| x.as_str())
                            .unwrap_or("")
                            .into(),
                        r#impl: item
                            .get("impl")
                            .and_then(|x| x.as_str())
                            .unwrap_or("")
                            .into(),
                        available: item
                            .get("available")
                            .and_then(|x| x.as_bool())
                            .unwrap_or(false),
                    });
                }
            }
        }
    }
    out
}

#[tauri::command]
pub fn write_tools_env(hf_token: String) -> Result<(), String> {
    let p = AppPaths::resolve();
    setup::write_tools_env(&p, &hf_token);
    Ok(())
}

#[tauri::command]
pub fn download_model(key: String) -> Result<(), String> {
    let p = AppPaths::resolve();
    crate::process::tools::download_model(&p, &key)
}

#[tauri::command]
pub fn check_updates() -> Result<std::collections::HashMap<String, String>, String> {
    let p = AppPaths::resolve();
    let m = manifest::cached(&p).ok_or("manifest 未缓存")?;
    let lock = state::LockFile::load(&p);
    let mut updates = std::collections::HashMap::new();
    let cur = lock
        .components
        .get("server")
        .map(|c| c.version.as_str())
        .unwrap_or("");
    if cur != m.components.server.version.as_str() {
        updates.insert("server".into(), m.components.server.version.clone());
    }
    Ok(updates)
}

#[tauri::command]
pub fn repair_component(component: String) -> Result<(), String> {
    let p = AppPaths::resolve();
    process::stop_all(&p);
    download::download_and_install(&component, &p)?;
    process::start_all(&p)?;
    Ok(())
}

#[tauri::command]
pub fn read_log_tail(name: String, lines: Option<usize>) -> Result<String, String> {
    let p = AppPaths::resolve();
    Ok(setup::read_log_tail(&p, &name, lines.unwrap_or(50)))
}

#[tauri::command]
pub fn default_manifest_url() -> String {
    DEFAULT_MANIFEST_URL.into()
}

pub fn navigate_ui(app: &AppHandle, paths: &AppPaths) {
    let index = paths.ui_index();
    if !index.is_file() {
        return;
    }
    if let Some(w) = app.get_webview_window("main") {
        if let Ok(url) = tauri::Url::from_file_path(&index) {
            let _ = w.navigate(tauri::WebviewUrl::External(url));
        }
    }
}
