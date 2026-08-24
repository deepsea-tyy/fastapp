use std::fs;
use std::io::{Read, Seek, SeekFrom};
use std::path::{Path, PathBuf};

use serde::Serialize;

use crate::desktop_conf;
use crate::platform;

#[derive(Clone, Debug, Serialize)]
pub struct AppPaths {
    pub root: PathBuf,
    pub ui: PathBuf,
    pub cmd: PathBuf,
    pub logs: PathBuf,
}

impl AppPaths {
    pub fn resolve() -> Self {
        let root = dirs::data_dir()
            .unwrap_or_else(|| PathBuf::from("."))
            .join(desktop_conf::data_dir_name());
        Self {
            ui: root.join("ui"),
            cmd: root.join("cmd"),
            logs: root.join("logs"),
            root,
        }
    }

    pub fn ensure_dirs(&self) {
        for p in [
            &self.root,
            &self.storage_dir(),
            &self.storage_dir().join("uploads"),
            &self.runtime_dir(),
            &self.ui,
            &self.cmd,
            &self.logs,
        ] {
            let _ = fs::create_dir_all(p);
        }
    }

    pub fn fastapp_binary(&self) -> PathBuf {
        let bin = self.root.join("fastapp");
        if bin.is_file() {
            return bin;
        }
        #[cfg(windows)]
        {
            let exe = self.root.join("fastapp.exe");
            if exe.is_file() {
                return exe;
            }
        }
        bin
    }

    pub fn storage_dir(&self) -> PathBuf {
        self.root.join("storage")
    }

    pub fn runtime_dir(&self) -> PathBuf {
        self.root.join("runtime")
    }

    pub fn ffmpeg_binary(&self) -> PathBuf {
        let bin = self.cmd.join("ffmpeg");
        if bin.is_file() {
            return bin;
        }
        #[cfg(windows)]
        {
            let exe = self.cmd.join("ffmpeg.exe");
            if exe.is_file() {
                return exe;
            }
        }
        bin
    }

    pub fn ui_index(&self) -> PathBuf {
        self.ui.join("index.html")
    }

    pub fn app_port(&self) -> u16 {
        desktop_conf::app_port()
    }

    pub fn app_ws_port(&self) -> u16 {
        desktop_conf::app_ws_port()
    }

    pub fn app_ports(&self) -> [u16; 2] {
        [self.app_port(), self.app_ws_port()]
    }
}

pub fn read_log_tail(paths: &AppPaths, name: &str, lines: usize) -> String {
    let file = match name {
        "hyperf" => paths.runtime_dir().join("hyperf.log"),
        _ => paths.logs.join("desktop.log"),
    };
    if !file.is_file() {
        return String::new();
    }
    tail_file(&file, lines).unwrap_or_default()
}

fn tail_file(path: &Path, max_lines: usize) -> Result<String, std::io::Error> {
    let mut f = fs::File::open(path)?;
    let len = f.metadata()?.len();
    let chunk = 4096u64.min(len);
    f.seek(SeekFrom::End(-(chunk as i64)))?;
    let mut buf = vec![0u8; chunk as usize];
    f.read_exact(&mut buf)?;
    let text = String::from_utf8_lossy(&buf);
    let lines: Vec<&str> = text.lines().collect();
    let start = lines.len().saturating_sub(max_lines);
    Ok(lines[start..].join("\n"))
}

pub fn write_log(paths: &AppPaths, line: &str) {
    let log = paths.logs.join("desktop.log");
    use std::io::Write;
    if let Ok(mut f) = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(log)
    {
        let _ = writeln!(f, "{line}");
    }
}

pub fn path_to_string(p: &Path) -> String {
    p.to_string_lossy().into_owned()
}

pub fn dev_build_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../build")
        .join(platform::dev_pkg_platform())
}
