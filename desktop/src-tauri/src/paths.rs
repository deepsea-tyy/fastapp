use std::fs;
use std::path::{Path, PathBuf};

use serde::Serialize;

#[derive(Clone, Debug, Serialize)]
pub struct AppPaths {
    pub root: PathBuf,
    pub server: PathBuf,
    pub ui: PathBuf,
    pub tools: PathBuf,
    pub cmd: PathBuf,
    pub logs: PathBuf,
}

impl AppPaths {
    pub fn resolve() -> Self {
        let root = dirs::data_dir()
            .unwrap_or_else(|| PathBuf::from("."))
            .join(env!("APP_DATA_DIR"));
        Self {
            server: root.join("server"),
            ui: root.join("ui"),
            tools: root.join("tools"),
            cmd: root.join("cmd"),
            logs: root.join("logs"),
            root,
        }
    }

    pub fn ensure_dirs(&self) {
        for p in [
            &self.root,
            &self.server,
            &self.server.join("storage"),
            &self.server.join("storage/uploads"),
            &self.server.join("runtime"),
            &self.ui,
            &self.cmd,
            &self.logs,
        ] {
            let _ = fs::create_dir_all(p);
        }
    }

    pub fn state_file(&self) -> PathBuf {
        self.root.join("state.json")
    }

    pub fn lock_file(&self) -> PathBuf {
        self.root.join("manifest.lock.json")
    }

    pub fn manifest_cache(&self) -> PathBuf {
        self.root.join("manifest.json")
    }

    pub fn server_binary(&self) -> PathBuf {
        let bin = self.server.join("fastapp");
        if bin.is_file() {
            return bin;
        }
        #[cfg(windows)]
        {
            let exe = self.server.join("fastapp.exe");
            if exe.is_file() {
                return exe;
            }
        }
        bin
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

    pub fn server_env(&self) -> PathBuf {
        self.server.join(".env")
    }

    pub fn tools_env(&self) -> PathBuf {
        self.tools.join(".env")
    }

    pub fn uv_binary(&self) -> PathBuf {
        let uv = self.cmd.join("uv");
        if uv.is_file() {
            return uv;
        }
        #[cfg(windows)]
        {
            let exe = self.cmd.join("uv.exe");
            if exe.is_file() {
                return exe;
            }
        }
        uv
    }

    pub fn component_dir(&self, name: &str) -> PathBuf {
        match name {
            "cmd" => self.cmd.clone(),
            "server" => self.server.clone(),
            "ui" => self.ui.clone(),
            "tools" => self.tools.clone(),
            _ => self.root.join(name),
        }
    }

    pub fn extract_root_for(&self, name: &str) -> PathBuf {
        match name {
            "cmd" | "server" | "ui" | "tools" => self.component_dir(name),
            _ => self.root.clone(),
        }
    }
}

pub fn platform_triple() -> String {
    let os = std::env::consts::OS;
    let arch = std::env::consts::ARCH;
    let arch_key = match arch {
        "aarch64" => "aarch64",
        "x86_64" => "x86_64",
        _ => arch,
    };
    let os_key = match os {
        "macos" => "darwin",
        "windows" => "windows",
        "linux" => "linux",
        _ => os,
    };
    format!("{os_key}-{arch_key}")
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
