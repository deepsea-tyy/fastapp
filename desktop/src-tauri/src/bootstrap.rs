use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use tauri::{AppHandle, Manager};

use crate::download::make_cmd_executable;
use crate::paths::{write_log, AppPaths};
use crate::state::{self, AppState};

const BUNDLED_PREFIX: &str = "bundled";

pub fn seed_bundled_components(app: &AppHandle, paths: &AppPaths) -> Result<(), String> {
    let bundled = resolve_bundled_dir(app)?;
    if !bundled.is_dir() {
        return Err(format!(
            "安装包内未找到 bundled 资源: {}",
            bundled.display()
        ));
    }

    let extractor = resolve_extractor(&bundled)?;
    seed_component(&bundled, paths, &extractor, "ui", &paths.ui)?;
    seed_component(&bundled, paths, &extractor, "tools", &paths.tools)?;
    seed_component(&bundled, paths, &extractor, "cmd", &paths.cmd)?;

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
        .join("bundle");
    if dev.is_dir() {
        return Ok(dev);
    }
    app.path()
        .resource_dir()
        .map(|p| p.join(BUNDLED_PREFIX))
        .map_err(|e| e.to_string())
}

fn resolve_extractor(bundled: &Path) -> Result<PathBuf, String> {
    #[cfg(windows)]
    {
        for name in ["7z2602-x64.exe", "7z2602-arm64.exe"] {
            let p = bundled.join(name);
            if p.is_file() {
                return Ok(p);
            }
        }
    }
    #[cfg(not(windows))]
    {
        let p = bundled.join("7zz");
        if p.is_file() {
            return Ok(p);
        }
    }
    Err("bundled 内未找到 7z 解压器".into())
}

fn seed_component(
    bundled: &Path,
    paths: &AppPaths,
    extractor: &Path,
    name: &str,
    dest: &Path,
) -> Result<(), String> {
    if state::component_installed(paths, name) {
        write_log(paths, &format!("seed skip {name} (already installed)"));
        return Ok(());
    }
    let archive = bundled.join(format!("{name}.7z"));
    if !archive.is_file() {
        return Err(format!("bundled/{name}.7z 不存在"));
    }
    fs::create_dir_all(dest).map_err(|e| e.to_string())?;
    extract_7z(extractor, &archive, dest)?;
    write_log(paths, &format!("seed {name} -> {}", dest.display()));
    Ok(())
}

fn extract_7z(extractor: &Path, archive: &Path, dest: &Path) -> Result<(), String> {
    let out = format!("{}/*", dest.to_string_lossy());
    let status = Command::new(extractor)
        .arg("x")
        .arg(archive)
        .arg(format!("-o{}", dest.to_string_lossy()))
        .arg("-y")
        .status()
        .map_err(|e| e.to_string())?;
    if !status.success() {
        return Err(format!(
            "7z 解压失败: {} -> {}",
            archive.display(),
            out
        ));
    }
    Ok(())
}
