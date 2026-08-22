use std::fs;
use std::net::TcpStream;
use std::process::{Command, Stdio};
use std::time::{Duration, Instant};

use crate::download::make_cmd_executable;
use crate::paths::{write_log, AppPaths};

pub fn start(paths: &AppPaths) -> Result<(), String> {
    let bin = paths.server_binary();
    if !bin.is_file() {
        return Err("fastapp 运行时未安装".into());
    }
    make_cmd_executable(paths);
    if tcp_open(9501) {
        return Ok(());
    }
    let log = paths.server.join("runtime/hyperf.log");
    let log_file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log)
        .map_err(|e| e.to_string())?;
    let mut cmd = Command::new(&bin);
    cmd.arg("-d")
        .arg("swoole.use_shortname=Off")
        .arg("start")
        .current_dir(&paths.server)
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
    write_log(paths, "hyperf start spawned");
    Ok(())
}

pub fn stop(paths: &AppPaths) {
    let pid_file = paths.server.join("runtime/hyperf.pid");
    if !pid_file.is_file() {
        return;
    }
    if let Ok(pid_s) = fs::read_to_string(&pid_file) {
        if let Ok(pid) = pid_s.trim().parse::<i32>() {
            kill_pid(pid);
        }
    }
    let _ = fs::remove_file(pid_file);
    write_log(paths, "hyperf stopped");
}

pub fn wait_ready(max_sec: u64) -> Result<(), String> {
    let start = Instant::now();
    while start.elapsed().as_secs() < max_sec {
        if tcp_open(9501) {
            return Ok(());
        }
        std::thread::sleep(Duration::from_secs(1));
    }
    Err("Hyperf 9501 启动超时".into())
}

pub fn migrate_if_needed(paths: &AppPaths) -> Result<(), String> {
    let db = paths.server.join("storage/fastapp.sqlite");
    if db.is_file() {
        return Ok(());
    }
    let bin = paths.server_binary();
    if !bin.is_file() {
        return Err("fastapp 运行时未安装".into());
    }
    let out = Command::new(&bin)
        .arg("-d")
        .arg("swoole.use_shortname=Off")
        .arg("migrate")
        .current_dir(&paths.server)
        .output()
        .map_err(|e| e.to_string())?;
    write_log(
        paths,
        &format!(
            "migrate exit={} stdout={}",
            out.status,
            String::from_utf8_lossy(&out.stdout)
        ),
    );
    Ok(())
}

fn tcp_open(port: u16) -> bool {
    TcpStream::connect_timeout(
        &format!("127.0.0.1:{port}").parse().unwrap(),
        Duration::from_millis(500),
    )
    .is_ok()
}

fn kill_pid(pid: i32) {
    #[cfg(unix)]
    {
        let _ = Command::new("kill").args(["-TERM", &pid.to_string()]).status();
    }
    #[cfg(windows)]
    {
        let _ = Command::new("taskkill")
            .args(["/PID", &pid.to_string(), "/F"])
            .status();
    }
}
