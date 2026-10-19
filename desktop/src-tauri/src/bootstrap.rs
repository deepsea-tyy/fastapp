use std::fs;
use std::path::{Path, PathBuf};

use tauri::{AppHandle, Manager};

use crate::exec::make_cmd_executable;
use crate::paths::{dev_build_dir, write_log, AppPaths};

const BUNDLED_PREFIX: &str = "bundled";

pub fn install_bundled_once(app: &AppHandle, paths: &AppPaths) -> Result<(), String> {
    let bundled = resolve_bundled_dir(app)?;
    if !bundled.is_dir() {
        return Err(format!(
            "安装包内未找到 bundled 资源: {}",
            bundled.display()
        ));
    }

    // 启动管线第 1 步（splash → install_bundled）：装/刷 AppData 资源。
    // 第 2 步 start_services：start → wait 8501 → navigate（见 process::start_all）。
    #[cfg(dev)]
    if paths.fastapp_binary().is_file() {
        write_log(paths, "install dev refresh bundled -> AppData");
        return refresh_runtime_assets(paths, &bundled);
    }

    #[cfg(not(dev))]
    if paths.fastapp_binary().is_file() {
        write_log(paths, "install skip (already installed)");
        paths.ensure_dirs();
        seed_missing_storage(paths, &bundled)?;
        return Ok(());
    }

    install_runtime_assets(paths, &bundled)?;
    write_log(paths, "install_bundled_once done");
    Ok(())
}

/// 安装替换：先停 Hyperf，再换 fastapp/ui/cmd，再 seed。勿在运行中覆盖 SFX。
fn refresh_runtime_assets(paths: &AppPaths, bundled: &Path) -> Result<(), String> {
    crate::process::stop_all(paths);
    install_runtime_assets(paths, bundled)
}

fn install_runtime_assets(paths: &AppPaths, bundled: &Path) -> Result<(), String> {
    copy_file_if_exists(paths, bundled, bundled_fastapp_name(), &paths.fastapp_binary())?;
    copy_dir_if_exists(paths, bundled, "ui", &paths.ui)?;
    copy_dir_if_exists(paths, bundled, "cmd", &paths.cmd)?;
    paths.ensure_dirs();
    make_cmd_executable(paths);
    seed_missing_storage(paths, bundled)
}

/// Fill missing storage artifacts from bundled without overwriting existing user data.
fn seed_missing_storage(paths: &AppPaths, bundled: &Path) -> Result<(), String> {
    let bundled_storage = bundled.join("storage");
    if !bundled_storage.is_dir() {
        return Err(format!(
            "bundled/storage 不存在: {}",
            bundled_storage.display()
        ));
    }

    let storage = paths.storage_dir();
    fs::create_dir_all(storage.join("uploads")).map_err(|e| e.to_string())?;

    let db_dest = storage.join("fastapp.sqlite");
    if !db_dest.is_file() {
        let db_src = bundled_storage.join("fastapp.sqlite");
        if !db_src.is_file() {
            return Err("bundled/storage/fastapp.sqlite 不存在".into());
        }
        fs::copy(&db_src, &db_dest).map_err(|e| e.to_string())?;
        write_log(
            paths,
            &format!("seed storage/fastapp.sqlite -> {}", db_dest.display()),
        );
    }

    for name in ["languages"] {
        let dest = storage.join(name);
        if dest.is_dir() {
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
            &format!("seed storage/{name}/ -> {}", dest.display()),
        );
    }

    Ok(())
}

pub fn resolve_bundled_dir(app: &AppHandle) -> Result<PathBuf, String> {
    if let Ok(resource) = app.path().resource_dir() {
        let bundled = resource.join(BUNDLED_PREFIX);
        if bundled.is_dir() {
            return Ok(bundled);
        }
    }
    let dev = dev_build_dir();
    if dev.is_dir() {
        return Ok(dev);
    }
    app.path()
        .resource_dir()
        .map(|p| p.join(BUNDLED_PREFIX))
        .map_err(|e| e.to_string())
}

fn bundled_fastapp_name() -> &'static str {
    #[cfg(windows)]
    {
        "fastapp.exe"
    }
    #[cfg(not(windows))]
    {
        "fastapp"
    }
}

fn copy_file_if_exists(
    paths: &AppPaths,
    bundled: &Path,
    name: &str,
    dest: &Path,
) -> Result<(), String> {
    let src = bundled.join(name);
    if !src.is_file() {
        return Err(format!("bundled/{name} 不存在"));
    }
    if let Some(parent) = dest.parent() {
        fs::create_dir_all(parent).map_err(|e| e.to_string())?;
    }
    // 原子替换（.new → rename）；调用方须已 stop，勿在运行中覆盖 SFX
    let tmp = dest.with_extension("new");
    fs::copy(&src, &tmp).map_err(|e| e.to_string())?;
    #[cfg(windows)]
    {
        if dest.exists() {
            fs::remove_file(dest).map_err(|e| e.to_string())?;
        }
    }
    fs::rename(&tmp, dest).map_err(|e| e.to_string())?;
    write_log(paths, &format!("install {name} -> {}", dest.display()));
    Ok(())
}

fn copy_dir_if_exists(
    paths: &AppPaths,
    bundled: &Path,
    name: &str,
    dest: &Path,
) -> Result<(), String> {
    let src = bundled.join(name);
    if !src.is_dir() {
        return Err(format!("bundled/{name} 不存在"));
    }
    // ui：先删后拷，避免 AppData 合并残留旧 hash chunk（与 stage rsync --delete 一致）
    if name == "ui" && dest.exists() {
        fs::remove_dir_all(dest).map_err(|e| e.to_string())?;
        write_log(paths, &format!("wipe {name}/ -> {}", dest.display()));
    }
    fs::create_dir_all(dest).map_err(|e| e.to_string())?;
    copy_dir_all(&src, dest)?;
    write_log(paths, &format!("install {name}/ -> {}", dest.display()));
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
