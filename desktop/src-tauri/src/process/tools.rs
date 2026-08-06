use std::fs;
use std::net::TcpStream;
use std::process::{Command, Stdio};
use std::time::{Duration, Instant};

use crate::paths::{write_log, AppPaths};

pub fn uv_sync(paths: &AppPaths) -> Result<(), String> {
    let uv = resolve_uv(paths)?;
    if paths.tools.join(".venv").is_dir() {
        return Ok(());
    }
    let out = Command::new(&uv)
        .args(["sync", "-q"])
        .current_dir(&paths.tools)
        .output()
        .map_err(|e| e.to_string())?;
    write_log(
        paths,
        &format!("uv sync exit={}", out.status),
    );
    Ok(())
}

pub fn start_scheduler(paths: &AppPaths) -> Result<(), String> {
    if !paths.tools.join("main.py").is_file() {
        return Err("tools 未安装".into());
    }
    if tcp_open(8312) {
        return Ok(());
    }
    let uv = resolve_uv(paths)?;
    let log = paths.tools.join("runtime/logs/scheduler.log");
    if let Some(parent) = log.parent() {
        let _ = fs::create_dir_all(parent);
    }
    let log_file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log)
        .map_err(|e| e.to_string())?;
    let mut cmd = Command::new(&uv);
    cmd.args(["run", "python", "main.py", "start", "-d"])
        .current_dir(&paths.tools)
        .stdout(Stdio::from(log_file.try_clone().map_err(|e| e.to_string())?))
        .stderr(Stdio::from(log_file))
        .stdin(Stdio::null());
    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        const CREATE_NO_WINDOW: u32 = 0x08000000;
        cmd.creation_flags(CREATE_NO_WINDOW);
    }
    cmd.spawn().map_err(|e| e.to_string())?;
    write_log(paths, "scheduler start spawned");
    Ok(())
}

pub fn stop_scheduler(paths: &AppPaths) {
    if let Ok(uv) = resolve_uv(paths) {
        let _ = Command::new(&uv)
            .args(["run", "python", "main.py", "stop"])
            .current_dir(&paths.tools)
            .output();
    }
    write_log(paths, "scheduler stop");
}

pub fn wait_ready(max_sec: u64) -> Result<(), String> {
    let start = Instant::now();
    while start.elapsed().as_secs() < max_sec {
        if tcp_open(8312) {
            return Ok(());
        }
        std::thread::sleep(Duration::from_secs(1));
    }
    Err("scheduler 8312 启动超时".into())
}

pub fn download_model(paths: &AppPaths, key: &str) -> Result<(), String> {
    let uv = resolve_uv(paths)?;
    let out = Command::new(&uv)
        .args(["run", "python", "main.py", "download", key])
        .current_dir(&paths.tools)
        .output()
        .map_err(|e| e.to_string())?;
    if !out.status.success() {
        return Err(String::from_utf8_lossy(&out.stderr).into());
    }
    Ok(())
}

fn resolve_uv(paths: &AppPaths) -> Result<std::path::PathBuf, String> {
    if paths.uv_binary().is_file() {
        return Ok(paths.uv_binary());
    }
    if let Ok(o) = Command::new("which").arg("uv").output() {
        if o.status.success() {
            let p = String::from_utf8_lossy(&o.stdout).trim().to_string();
            if !p.is_empty() {
                return Ok(std::path::PathBuf::from(p));
            }
        }
    }
    #[cfg(windows)]
    {
        if let Ok(o) = Command::new("where").arg("uv").output() {
            if o.status.success() {
                let p = String::from_utf8_lossy(&o.stdout)
                    .lines()
                    .next()
                    .unwrap_or("")
                    .trim()
                    .to_string();
                if !p.is_empty() {
                    return Ok(std::path::PathBuf::from(p));
                }
            }
        }
    }
    Err("未找到 uv".into())
}

fn tcp_open(port: u16) -> bool {
    TcpStream::connect_timeout(
        &format!("127.0.0.1:{port}").parse().unwrap(),
        Duration::from_millis(500),
    )
    .is_ok()
}
