use std::fs;
use std::sync::Mutex;

use serde::{Deserialize, Serialize};

use crate::paths::AppPaths;

static MANIFEST: Mutex<Option<DesktopManifest>> = Mutex::new(None);

pub const DEFAULT_MANIFEST_URL: &str = "https://cdn.example.com/fastapp/manifest.json";

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DesktopManifest {
    pub app_version: String,
    pub channel: String,
    pub components: ManifestComponents,
    #[serde(default)]
    pub models_catalog_url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ManifestComponents {
    pub server: PackageEntry,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PackageEntry {
    pub url: String,
    pub sha256: String,
    pub size: u64,
    #[serde(default)]
    pub version: String,
    #[serde(default)]
    pub kind: String,
}

pub fn fetch(url: &str, paths: &AppPaths) -> Result<DesktopManifest, String> {
    let body = reqwest::blocking::get(url)
        .map_err(|e| e.to_string())?
        .text()
        .map_err(|e| e.to_string())?;
    let m: DesktopManifest = serde_json::from_str(&body).map_err(|e| e.to_string())?;
    let _ = fs::write(paths.manifest_cache(), &body);
    *MANIFEST.lock().unwrap() = Some(m.clone());
    Ok(m)
}

pub fn cached(paths: &AppPaths) -> Option<DesktopManifest> {
    if let Some(m) = MANIFEST.lock().unwrap().clone() {
        return Some(m);
    }
    let p = paths.manifest_cache();
    if !p.is_file() {
        return None;
    }
    let body = fs::read_to_string(p).ok()?;
    let m: DesktopManifest = serde_json::from_str(&body).ok()?;
    *MANIFEST.lock().unwrap() = Some(m.clone());
    Some(m)
}

pub fn entry_for(component: &str) -> Result<PackageEntry, String> {
    let m = MANIFEST
        .lock()
        .unwrap()
        .clone()
        .ok_or("manifest 未加载，请先 fetch")?;
    match component {
        "server" => Ok(m.components.server.clone()),
        other => Err(format!("未知组件: {other}")),
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct ManifestInfo {
    pub app_version: String,
    pub channel: String,
}
