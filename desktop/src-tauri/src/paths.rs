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
            .join("FastApp");
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
            self.server.join("storage"),
            self.server.join("runtime"),
            self.server.join("plugin"),
            &self.ui,
            &self.tools,
            self.tools.join("models"),
            self.tools.join("runtime"),
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

    pub fn php_binary(&self) -> PathBuf {
        let php = self.cmd.join("php");
        if php.is_file() {
            return php;
        }
        #[cfg(windows)]
        {
            let exe = self.cmd.join("php.exe");
            if exe.is_file() {
                return exe;
            }
        }
        php
    }

    pub fn phar_file(&self) -> PathBuf {
        self.server.join("fastapp.phar")
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
