use std::fs::{self, File};
use std::io::{copy, Read, Write};
use std::path::Path;

use sha2::{Digest, Sha256};
use zip::ZipArchive;

use crate::manifest::{entry_for, PackageEntry};
use crate::paths::{write_log, AppPaths};
use crate::state::{ComponentLock, LockFile};

pub fn download_and_install(component: &str, paths: &AppPaths) -> Result<(), String> {
    let entry = entry_for(component)?;
    let tmp = paths.root.join(format!(".download-{component}.zip"));
    download_file(&entry, &tmp)?;
    verify_sha256(&tmp, &entry.sha256)?;
    extract_zip(&tmp, &paths.extract_root_for(component))?;
    let _ = fs::remove_file(&tmp);
    let mut lock = LockFile::load(paths);
    lock.components.insert(
        component.into(),
        ComponentLock {
            version: entry.version.clone(),
            sha256: entry.sha256.clone(),
        },
    );
    lock.save(paths);
    write_log(paths, &format!("installed {component}"));
    Ok(())
}

fn download_file(entry: &PackageEntry, dest: &Path) -> Result<(), String> {
    let mut resp = reqwest::blocking::get(&entry.url).map_err(|e| e.to_string())?;
    if !resp.status.is_success() {
        return Err(format!("下载失败: {}", resp.status()));
    }
    let mut out = File::create(dest).map_err(|e| e.to_string())?;
    copy(&mut resp, &mut out).map_err(|e| e.to_string())?;
    Ok(())
}

pub fn verify_sha256(path: &Path, expected: &str) -> Result<(), String> {
    let mut file = File::open(path).map_err(|e| e.to_string())?;
    let mut hasher = Sha256::new();
    let mut buf = [0u8; 8192];
    loop {
        let n = file.read(&mut buf).map_err(|e| e.to_string())?;
        if n == 0 {
            break;
        }
        hasher.update(&buf[..n]);
    }
    let hash = hex::encode(hasher.finalize());
    if hash != expected.to_lowercase() && hash != expected {
        return Err(format!("sha256 不匹配: {hash} != {expected}"));
    }
    Ok(())
}

fn extract_zip(archive: &Path, dest: &Path) -> Result<(), String> {
    fs::create_dir_all(dest).map_err(|e| e.to_string())?;
    let file = File::open(archive).map_err(|e| e.to_string())?;
    let mut zip = ZipArchive::new(file).map_err(|e| e.to_string())?;
    for i in 0..zip.len() {
        let mut f = zip.by_index(i).map_err(|e| e.to_string())?;
        let name = f.name().to_string();
        let out = dest.join(name);
        if f.is_dir() {
            fs::create_dir_all(&out).map_err(|e| e.to_string())?;
        } else {
            if let Some(parent) = out.parent() {
                fs::create_dir_all(parent).map_err(|e| e.to_string())?;
            }
            let mut out_file = File::create(&out).map_err(|e| e.to_string())?;
            copy(&mut f, &mut out_file).map_err(|e| e.to_string())?;
        }
    }
    Ok(())
}

pub fn make_cmd_executable(paths: &AppPaths) {
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        for bin in [
            paths.php_binary(),
            paths.uv_binary(),
            paths.cmd.join("ffmpeg"),
            paths.cmd.join("ffprobe"),
            paths.cmd.join("uvx"),
        ] {
            if bin.is_file() {
                if let Ok(meta) = fs::metadata(&bin) {
                    let mut perm = meta.permissions();
                    perm.set_mode(0o755);
                    let _ = fs::set_permissions(&bin, perm);
                }
            }
        }
    }
}
