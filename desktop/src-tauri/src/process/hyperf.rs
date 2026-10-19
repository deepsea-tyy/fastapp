use std::fs;
use std::net::TcpStream;
use std::process::{Command, Stdio};
use std::time::{Duration, Instant};

use crate::exec::make_cmd_executable;
use crate::paths::{read_log_tail, write_log, AppPaths};

const PORT_CLOSE_TIMEOUT: Duration = Duration::from_secs(5);

pub fn start(paths: &AppPaths) -> Result<(), String> {
    let bin = paths.fastapp_binary();
    if !bin.is_file() {
        return Err("fastapp 运行时未安装".into());
    }
    make_cmd_executable(paths);
    ensure_ports_free(paths)?;
    let log = paths.runtime_dir().join("hyperf.log");
    let log_file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log)
        .map_err(|e| e.to_string())?;
    let mut cmd = fastapp_cmd(paths);
    cmd.arg("start")
        .current_dir(&paths.root)
        .stdout(Stdio::from(log_file.try_clone().map_err(|e| e.to_string())?))
        .stderr(Stdio::from(log_file))
        .stdin(Stdio::null());
    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        const CREATE_NO_WINDOW: u32 = 0x08000000;
        cmd.creation_flags(CREATE_NO_WINDOW);
    }
    let mut child = cmd.spawn().map_err(|e| e.to_string())?;
    write_log(paths, "hyperf start spawned");
    std::thread::sleep(Duration::from_millis(500));
    if let Ok(Some(status)) = child.try_wait() {
        return Err(hyperf_exit_error(paths, &format!("exit={status}")));
    }
    Ok(())
}

/// 启停：graceful（限时）→ pid → 端口。安装替换须先 stop，勿在运行中覆盖 SFX。
pub fn stop(paths: &AppPaths) {
    graceful_stop(paths);
    kill_from_pid_file(paths);
    if any_port_open(paths) {
        kill_port_listeners(paths);
    }
    wait_ports_closed(paths);
    let pid_file = paths.runtime_dir().join("hyperf.pid");
    let _ = fs::remove_file(pid_file);
    if any_port_open(paths) {
        let ports = paths.app_ports();
        write_log(
            paths,
            &format!(
                "hyperf stop warning: ports {} / {} still open",
                ports[0], ports[1]
            ),
        );
    } else {
        write_log(paths, "hyperf stopped");
    }
}

pub fn wait_ready(paths: &AppPaths, max_sec: u64) -> Result<(), String> {
    let port = paths.app_port();
    let start = Instant::now();
    while start.elapsed().as_secs() < max_sec {
        if tcp_open(port) {
            return Ok(());
        }
        std::thread::sleep(Duration::from_secs(1));
    }
    Err(hyperf_timeout_error(paths, port))
}

fn ensure_ports_free(paths: &AppPaths) -> Result<(), String> {
    if !any_port_open(paths) {
        return Ok(());
    }
    write_log(paths, "hyperf ports occupied, reclaiming");
    stop(paths);
    if any_port_open(paths) {
        let ports = paths.app_ports();
        return Err(format!(
            "端口 {} / {} 仍被占用，无法启动 Hyperf。请查看 AppData logs/desktop.log 与 runtime/hyperf.log",
            ports[0], ports[1]
        ));
    }
    Ok(())
}

fn graceful_stop(paths: &AppPaths) {
    let bin = paths.fastapp_binary();
    if !bin.is_file() {
        return;
    }
    let mut cmd = fastapp_cmd(paths);
    cmd.arg("stop")
        .current_dir(&paths.root)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null());
    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        const CREATE_NO_WINDOW: u32 = 0x08000000;
        cmd.creation_flags(CREATE_NO_WINDOW);
    }
    let Ok(mut child) = cmd.spawn() else {
        return;
    };
    const STOP_TIMEOUT: Duration = Duration::from_secs(3);
    let start = Instant::now();
    loop {
        match child.try_wait() {
            Ok(Some(_)) => return,
            Ok(None) if start.elapsed() < STOP_TIMEOUT => {
                std::thread::sleep(Duration::from_millis(100));
            }
            _ => {
                let _ = child.kill();
                let _ = child.wait();
                write_log(paths, "hyperf stop timed out, forcing");
                return;
            }
        }
    }
}

fn fastapp_cmd(paths: &AppPaths) -> Command {
    let mut cmd = Command::new(paths.fastapp_binary());
    cmd.arg("-d")
        .arg("swoole.use_shortname=Off")
        .arg("--self");
    cmd
}

fn kill_from_pid_file(paths: &AppPaths) {
    let pid_file = paths.runtime_dir().join("hyperf.pid");
    if !pid_file.is_file() {
        return;
    }
    if let Ok(pid_s) = fs::read_to_string(&pid_file) {
        if let Ok(pid) = pid_s.trim().parse::<i32>() {
            kill_pid(pid, false);
            std::thread::sleep(Duration::from_millis(300));
            if process_alive(pid) {
                kill_pid(pid, true);
            }
        }
    }
}

fn kill_port_listeners(paths: &AppPaths) {
    for port in paths.app_ports() {
        for pid in pids_on_port(port) {
            kill_pid(pid, false);
        }
    }
    std::thread::sleep(Duration::from_millis(300));
    for port in paths.app_ports() {
        if tcp_open(port) {
            for pid in pids_on_port(port) {
                kill_pid(pid, true);
            }
        }
    }
}

fn wait_ports_closed(paths: &AppPaths) {
    let start = Instant::now();
    while start.elapsed() < PORT_CLOSE_TIMEOUT {
        if !any_port_open(paths) {
            return;
        }
        std::thread::sleep(Duration::from_millis(200));
    }
}

fn any_port_open(paths: &AppPaths) -> bool {
    paths.app_ports().iter().any(|&p| tcp_open(p))
}

fn process_alive(pid: i32) -> bool {
    #[cfg(unix)]
    {
        Command::new("kill")
            .args(["-0", &pid.to_string()])
            .status()
            .map(|s| s.success())
            .unwrap_or(false)
    }
    #[cfg(windows)]
    {
        Command::new("tasklist")
            .args(["/FI", &format!("PID eq {pid}")])
            .output()
            .map(|o| {
                let out = String::from_utf8_lossy(&o.stdout);
                out.contains(&pid.to_string())
            })
            .unwrap_or(false)
    }
}

fn pids_on_port(port: u16) -> Vec<i32> {
    #[cfg(unix)]
    {
        let output = Command::new("lsof")
            .args(["-ti", &format!(":{port}")])
            .output();
        match output {
            Ok(o) if o.status.success() => String::from_utf8_lossy(&o.stdout)
                .lines()
                .filter_map(|line| line.trim().parse::<i32>().ok())
                .collect(),
            _ => Vec::new(),
        }
    }
    #[cfg(windows)]
    {
        let output = Command::new("netstat")
            .args(["-ano"])
            .output();
        let Ok(o) = output else {
            return Vec::new();
        };
        let text = String::from_utf8_lossy(&o.stdout);
        let needle = format!(":{port}");
        let mut pids = Vec::new();
        for line in text.lines() {
            if !line.contains("LISTENING") || !line.contains(&needle) {
                continue;
            }
            if let Some(pid_s) = line.split_whitespace().last() {
                if let Ok(pid) = pid_s.parse::<i32>() {
                    if pid > 0 {
                        pids.push(pid);
                    }
                }
            }
        }
        pids.sort_unstable();
        pids.dedup();
        pids
    }
}

fn hyperf_log_path(paths: &AppPaths) -> std::path::PathBuf {
    paths.runtime_dir().join("hyperf.log")
}

fn hyperf_exit_error(paths: &AppPaths, reason: &str) -> String {
    let log_path = hyperf_log_path(paths);
    let tail = read_log_tail(paths, "hyperf", 20);
    format!(
        "Hyperf 进程已退出 ({reason})。日志：{}\n{tail}",
        log_path.display()
    )
}

fn hyperf_timeout_error(paths: &AppPaths, port: u16) -> String {
    let log_path = hyperf_log_path(paths);
    let tail = read_log_tail(paths, "hyperf", 20);
    format!(
        "Hyperf {port} 启动超时。日志：{}\n{tail}",
        log_path.display()
    )
}

fn tcp_open(port: u16) -> bool {
    TcpStream::connect_timeout(
        &format!("127.0.0.1:{port}").parse().unwrap(),
        Duration::from_millis(500),
    )
    .is_ok()
}

fn kill_pid(pid: i32, force: bool) {
    #[cfg(unix)]
    {
        let sig = if force { "-KILL" } else { "-TERM" };
        let _ = Command::new("kill").args([sig, &pid.to_string()]).status();
    }
    #[cfg(windows)]
    {
        let mut cmd = Command::new("taskkill");
        cmd.args(["/PID", &pid.to_string()]);
        if force {
            cmd.arg("/F");
        }
        let _ = cmd.status();
    }
}
