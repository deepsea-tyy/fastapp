use serde::{Deserialize, Serialize};

use crate::health;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum TierStatus {
    Ok,
    Limited,
    Unavailable,
}

#[derive(Debug, Clone, Serialize)]
pub struct LocalHardware {
    pub os: String,
    pub memory_gb: f64,
    pub gpu_name: Option<String>,
    pub gpu_vram_gb: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SchedulerProfile {
    pub platform: String,
    pub accelerator: String,
    pub memory_gb: Option<f64>,
}

#[derive(Debug, Clone, Serialize)]
pub struct FeatureTier {
    pub basic: TierStatus,
    pub sdxl: TierStatus,
    pub song_pro: TierStatus,
    pub message: String,
    pub suggested_downloads: Vec<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct HardwareReport {
    pub local: LocalHardware,
    pub scheduler_online: bool,
    pub profile: Option<SchedulerProfile>,
    pub tiers: FeatureTier,
}

#[derive(Debug, Deserialize)]
struct CapabilitiesResponse {
    profile: Option<SchedulerProfile>,
    capabilities: Option<Vec<SchedulerCapability>>,
}

#[derive(Debug, Deserialize)]
struct SchedulerCapability {
    capability: String,
    available: bool,
    tier: String,
    layer: String,
}

const BASIC_LAYERS: &[&str] = &["narrative", "voice", "music", "segment", "animate"];
const SDXL_LAYER: &str = "sdxl";
const SONG_LAYER: &str = "song";

const SDXL_MODEL_KEYS: &[&str] = &["juggernaut-xl", "illustrious-xl"];

pub fn probe_local() -> LocalHardware {
    let mut sys = sysinfo::System::new();
    sys.refresh_memory();
    let memory_gb = round1(sys.total_memory() as f64 / (1024.0 * 1024.0 * 1024.0));
    let os = if cfg!(target_os = "macos") {
        "darwin".into()
    } else if cfg!(target_os = "windows") {
        "windows".into()
    } else {
        "linux".into()
    };
    let (gpu_name, gpu_vram_gb) = probe_nvidia_gpu();
    LocalHardware {
        os,
        memory_gb,
        gpu_name,
        gpu_vram_gb,
    }
}

fn probe_nvidia_gpu() -> (Option<String>, Option<f64>) {
    let out = std::process::Command::new("nvidia-smi")
        .args([
            "--query-gpu=name,memory.total",
            "--format=csv,noheader,nounits",
        ])
        .output();
    let Ok(out) = out else {
        return (None, None);
    };
    if !out.status.success() {
        return (None, None);
    }
    let text = String::from_utf8_lossy(&out.stdout);
    let Some(line) = text.lines().next() else {
        return (None, None);
    };
    let line = line.trim();
    if line.is_empty() {
        return (None, None);
    }
    let mut parts = line.split(',').map(str::trim);
    let name = parts.next().map(String::from);
    let vram = parts.next().and_then(|s| s.parse::<f64>().ok()).map(round1);
    (name, vram)
}

fn round1(v: f64) -> f64 {
    (v * 10.0).round() / 10.0
}

fn tier_from_str(s: &str) -> TierStatus {
    match s {
        "recommended" | "ok" => TierStatus::Ok,
        "limited" => TierStatus::Limited,
        _ => TierStatus::Unavailable,
    }
}

fn merge_tier(current: TierStatus, next: TierStatus) -> TierStatus {
    if current == TierStatus::Unavailable || next == TierStatus::Unavailable {
        return TierStatus::Unavailable;
    }
    if current == TierStatus::Limited || next == TierStatus::Limited {
        return TierStatus::Limited;
    }
    TierStatus::Ok
}

fn aggregate_layer_tier(caps: &[SchedulerCapability], layers: &[&str]) -> TierStatus {
    let mut tier = TierStatus::Ok;
    let mut matched = false;
    for cap in caps {
        if !layers.contains(&cap.layer.as_str()) {
            continue;
        }
        matched = true;
        if !cap.available {
            return TierStatus::Unavailable;
        }
        tier = merge_tier(tier, tier_from_str(&cap.tier));
    }
    if !matched {
        return TierStatus::Unavailable;
    }
    tier
}

fn aggregate_sdxl_tier(caps: &[SchedulerCapability]) -> TierStatus {
    aggregate_layer_tier(caps, &[SDXL_LAYER])
}

fn aggregate_song_tier(caps: &[SchedulerCapability]) -> TierStatus {
    aggregate_layer_tier(caps, &[SONG_LAYER])
}

fn heuristic_tiers(local: &LocalHardware) -> FeatureTier {
    let mut basic = TierStatus::Ok;
    if local.memory_gb < 16.0 {
        basic = TierStatus::Limited;
    }

    let mut sdxl = TierStatus::Unavailable;
    if local.os == "darwin" {
        if local.memory_gb >= 32.0 {
            sdxl = TierStatus::Limited;
        }
    } else if local.gpu_vram_gb.unwrap_or(0.0) >= 12.0 {
        sdxl = TierStatus::Ok;
    } else if local.gpu_name.is_some() {
        sdxl = TierStatus::Limited;
    }

    let mut song_pro = TierStatus::Unavailable;
    if local.os == "darwin" && local.memory_gb >= 32.0 {
        song_pro = TierStatus::Limited;
    } else if local.gpu_vram_gb.unwrap_or(0.0) >= 24.0 {
        song_pro = TierStatus::Limited;
    }

    build_feature_tier(basic, sdxl, song_pro)
}

fn build_feature_tier(basic: TierStatus, sdxl: TierStatus, song_pro: TierStatus) -> FeatureTier {
    let mut suggested_downloads = vec![];
    if sdxl == TierStatus::Ok || sdxl == TierStatus::Limited {
        suggested_downloads.extend(SDXL_MODEL_KEYS.iter().map(|s| s.to_string()));
    }

    let basic_label = tier_label(&basic);
    let sdxl_label = tier_label(&sdxl);
    let message = if sdxl == TierStatus::Unavailable {
        format!(
            "基础功能：{}。SDXL 资产生图不可用（需 M1 Pro 32GB+ 或 RTX 3060 12GB+），仍可使用编辑器与音频功能。",
            basic_label
        )
    } else if sdxl == TierStatus::Limited {
        format!(
            "基础功能：{}。SDXL 资产生图：{}（速度可能较慢），可按需下载 SDXL 模型。",
            basic_label, sdxl_label
        )
    } else {
        format!(
            "基础功能：{}。SDXL 资产生图：{}，可按需下载 juggernaut-xl / illustrious-xl。",
            basic_label, sdxl_label
        )
    };

    let _ = song_pro;
    FeatureTier {
        basic,
        sdxl,
        song_pro,
        message,
        suggested_downloads,
    }
}

fn tier_label(t: &TierStatus) -> &'static str {
    match t {
        TierStatus::Ok => "可用",
        TierStatus::Limited => "可用（受限）",
        TierStatus::Unavailable => "不可用",
    }
}

fn fetch_scheduler_capabilities() -> Option<CapabilitiesResponse> {
    let url = "http://127.0.0.1:8312/v1/scheduler/capabilities";
    let resp = reqwest::blocking::get(url).ok()?;
    resp.json::<CapabilitiesResponse>().ok()
}

pub fn hardware_report() -> HardwareReport {
    let local = probe_local();
    let scheduler_online = health::tcp_open("127.0.0.1", 8312);

    if scheduler_online {
        if let Some(body) = fetch_scheduler_capabilities() {
            let caps = body.capabilities.unwrap_or_default();
            let basic = aggregate_layer_tier(&caps, BASIC_LAYERS);
            let sdxl = aggregate_sdxl_tier(&caps);
            let song_pro = aggregate_song_tier(&caps);
            let tiers = build_feature_tier(basic, sdxl, song_pro);
            return HardwareReport {
                local,
                scheduler_online: true,
                profile: body.profile,
                tiers,
            };
        }
    }

    let tiers = heuristic_tiers(&local);
    HardwareReport {
        local,
        scheduler_online,
        profile: None,
        tiers,
    }
}
