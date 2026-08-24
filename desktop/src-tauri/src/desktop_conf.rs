use std::fs;
use std::path::PathBuf;
use std::sync::OnceLock;

static DESKTOP: OnceLock<DesktopConf> = OnceLock::new();

#[derive(Debug, Clone)]
pub struct DesktopConf {
    pub product_name: String,
    pub data_dir: String,
    pub app_port: u16,
    pub app_ws_port: u16,
}

impl DesktopConf {
    fn load(path: &std::path::Path) -> Option<Self> {
        let raw = fs::read_to_string(path).ok()?;
        let v: serde_json::Value = serde_json::from_str(&raw).ok()?;
        let desktop = v.get("plugins")?.get("desktop")?;
        Some(Self {
            product_name: v["productName"].as_str()?.to_string(),
            data_dir: desktop["dataDir"].as_str()?.to_string(),
            app_port: desktop["appPort"].as_u64()? as u16,
            app_ws_port: desktop["appWsPort"].as_u64()? as u16,
        })
    }
}

pub fn init() {
    let path = conf_path();
    let cfg = DesktopConf::load(&path).unwrap_or_else(|| {
        panic!(
            "tauri.conf.json 未找到或无效：{}（请先执行 stage.sh dev/build）",
            path.display()
        )
    });
    let _ = DESKTOP.set(cfg);
}

fn conf_path() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tauri.conf.json")
}

pub fn config() -> &'static DesktopConf {
    DESKTOP.get().expect("desktop conf not initialized")
}

pub fn data_dir_name() -> String {
    config().data_dir.clone()
}

pub fn app_name() -> String {
    config().product_name.clone()
}

pub fn app_port() -> u16 {
    config().app_port
}

pub fn app_ws_port() -> u16 {
    config().app_ws_port
}
