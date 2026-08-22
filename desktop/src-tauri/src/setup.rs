use std::fs;
use std::io::{Read, Seek, SeekFrom};

use crate::paths::AppPaths;

const SERVER_ENV: &str = r#"APP_NAME=fastapp
APP_ENV=prod
APP_DEBUG=false
APP_PORT=9501
APP_WS_PORT=9502
DB_DRIVER=sqlite
WS_STORE_DRIVER=cache
APP_URL=http://127.0.0.1:9501
JWT_TTL=3600
JWT_REFRESH_TTL=7200
JWT_SECRET=fastapp-desktop-secret
JWT_API_SECRET=fastapp-desktop-secret
SCHEDULER_URL=http://127.0.0.1:8312
ffmpeg='/../cmd'
"#;

pub fn write_server_env_if_missing(paths: &AppPaths) {
    let env = paths.server_env();
    if env.is_file() {
        return;
    }
    let _ = fs::write(env, SERVER_ENV);
}

pub fn write_tools_env(paths: &AppPaths, hf_token: &str) {
    let mut content = String::from("BIND_HOST=127.0.0.1\n");
    if !hf_token.is_empty() {
        content.push_str(&format!("HF_TOKEN={hf_token}\n"));
    }
    let _ = fs::write(paths.tools_env(), content);
}

pub fn read_log_tail(paths: &AppPaths, name: &str, lines: usize) -> String {
    let file = match name {
        "hyperf" => paths.server.join("runtime/hyperf.log"),
        "scheduler" => paths.tools.join("runtime/logs/scheduler.log"),
        _ => paths.logs.join("desktop.log"),
    };
    if !file.is_file() {
        return String::new();
    }
    tail_file(&file, lines).unwrap_or_default()
}

fn tail_file(path: &std::path::Path, max_lines: usize) -> Result<String, std::io::Error> {
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
