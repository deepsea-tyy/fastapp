use std::fs;
use std::path::{Path, PathBuf};

use tauri::{AppHandle, Manager};

use crate::download::make_cmd_executable;
use crate::paths::{write_log, AppPaths};
use crate::state::{self, AppState};

const BUNDLED_PREFIX: &str = "bundled";
const SEED_COMPONENTS: &[&str] = &["ui", "cmd", "server"];
const STORAGE_SEED_DIRS: &[&str] = &["languages", "ttc"];

pub fn seed_bundled_components(app: &AppHandle, paths: &AppPaths) -> Result<(), String> {
    let bundled = resolve_bundled_dir(app)?;
    if !bundled.is_dir() {
        return Err(format!(
            "安装包内未找到 bundled 资源: {}",
            bundled.display()
        ));
    }

    for name in SEED_COMPONENTS {
        let dest = paths.component_dir(name);
        seed_component(&bundled, paths, name, &dest)?;
    }

    seed_storage_assets(&bundled, paths)?;

    make_cmd_executable(paths);
    let mut st = AppState::load(paths);
    state::refresh_install_flags(paths, &mut st);
    st.save(paths);
    write_log(paths, "seed_bundled_components done");
    Ok(())
}

fn resolve_bundled_dir(app: &AppHandle) -> Result<PathBuf, String> {
    if let Ok(resource) = app.path().resource_dir() {
        let bundled = resource.join(BUNDLED_PREFIX);
        if bundled.is_dir() {
            return Ok(bundled);
        }
    }
    let dev = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("build");
    if dev.is_dir() {
        return Ok(dev);
    }
    app.path()
        .resource_dir()
        .map(|p| p.join(BUNDLED_PREFIX))
        .map_err(|e| e.to_string())
}

fn seed_component(
    bundled: &Path,
    paths: &AppPaths,
    name: &str,
    dest: &Path,
) -> Result<(), String> {
    if state::component_installed(paths, name) {
        write_log(paths, &format!("seed skip {name} (already installed)"));
        return Ok(());
    }
    let src = bundled.join(name);
    if !src.is_dir() {
        return Err(format!("bundled/{name} 不存在"));
    }
    fs::create_dir_all(dest).map_err(|e| e.to_string())?;
    copy_dir_all(&src, dest)?;
    write_log(paths, &format!("seed {name} -> {}", dest.display()));
    Ok(())
}

fn seed_storage_assets(bundled: &Path, paths: &AppPaths) -> Result<(), String> {
    let storage_root = paths.server.join("storage");
    fs::create_dir_all(&storage_root).map_err(|e| e.to_string())?;
    fs::create_dir_all(storage_root.join("uploads")).map_err(|e| e.to_string())?;

    let bundled_storage = bundled.join("storage");
    if !bundled_storage.is_dir() {
        return Err(format!(
            "bundled/storage 不存在: {}",
            bundled_storage.display()
        ));
    }

    for name in STORAGE_SEED_DIRS {
        let dest = storage_root.join(name);
        if dest.is_dir() {
            write_log(paths, &format!("seed skip storage/{name} (already exists)"));
            continue;
        }
        let src = bundled_storage.join(name);
        if !src.is_dir() {
            return Err(format!("bundled/storage/{name} 不存在"));
        }
        fs::create_dir_all(&dest).map_err(|e| e.to_string())?;
        copy_dir_all(&src, &dest)?;
        write_log(
            paths,
            &format!("seed storage/{name} -> {}", dest.display()),
        );
    }

    Ok(())
}

fn copy_dir_all(src: &Path, dest: &Path) -> Result<(), String> {
    for entry in fs::read_dir(src).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let ty = entry.file_type().map_err(|e| e.to_string())?;
        let from = entry.path();
        let to = dest.join(entry.file_name());
        if ty.is_dir() {
            fs::create_dir_all(&to).map_err(|e| e.to_string())?;
            copy_dir_all(&from, &to)?;
        } else {
            if let Some(parent) = to.parent() {
                fs::create_dir_all(parent).map_err(|e| e.to_string())?;
            }
            fs::copy(&from, &to).map_err(|e| e.to_string())?;
        }
    }
    Ok(())
}
