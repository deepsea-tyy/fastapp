use std::fs;

use serde::{Deserialize, Serialize};

use crate::paths::AppPaths;

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AppState {
    pub setup_done: bool,
    pub components: std::collections::HashMap<String, bool>,
    pub versions: std::collections::HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct LockFile {
    pub components: std::collections::HashMap<String, ComponentLock>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ComponentLock {
    pub version: String,
    pub sha256: String,
}

impl AppState {
    pub fn load(paths: &AppPaths) -> Self {
        let p = paths.state_file();
        if !p.is_file() {
            return Self::default();
        }
        fs::read_to_string(p)
            .ok()
            .and_then(|s| serde_json::from_str(&s).ok())
            .unwrap_or_default()
    }

    pub fn save(&self, paths: &AppPaths) {
        if let Ok(s) = serde_json::to_string_pretty(self) {
            let _ = fs::write(paths.state_file(), s);
        }
    }
}

impl LockFile {
    pub fn load(paths: &AppPaths) -> Self {
        let p = paths.lock_file();
        if !p.is_file() {
            return Self::default();
        }
        fs::read_to_string(p)
            .ok()
            .and_then(|s| serde_json::from_str(&s).ok())
            .unwrap_or_default()
    }

    pub fn save(&self, paths: &AppPaths) {
        if let Ok(s) = serde_json::to_string_pretty(self) {
            let _ = fs::write(paths.lock_file(), s);
        }
    }
}

pub fn component_installed(paths: &AppPaths, name: &str) -> bool {
    match name {
        "cmd" => paths.ffmpeg_binary().is_file(),
        "server" => paths.server_binary().is_file(),
        "ui" => paths.ui_index().is_file(),
        "tools" => paths.tools.join("main.py").is_file(),
        _ => false,
    }
}

const REQUIRED_COMPONENTS: &[&str] = &["cmd", "server", "ui"];

pub fn refresh_install_flags(paths: &AppPaths, state: &mut AppState) {
    for c in REQUIRED_COMPONENTS {
        state
            .components
            .insert((*c).into(), component_installed(paths, c));
    }
    state.setup_done = REQUIRED_COMPONENTS
        .iter()
        .all(|c| state.components.get(*c).copied().unwrap_or(false));
}
