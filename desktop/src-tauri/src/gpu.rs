use std::sync::atomic::{AtomicBool, Ordering};

use serde::{Deserialize, Serialize};
use tauri::{AppHandle, Emitter};

static GPU_LOCKED: AtomicBool = AtomicBool::new(false);

#[derive(Debug, Clone, Serialize)]
pub struct GpuSlots {
    pub full: bool,
    pub gpu: bool,
    pub cpu: bool,
}

#[derive(Debug, Deserialize)]
struct CapabilitiesResponse {
    active_slots: Option<ActiveSlots>,
}

#[derive(Debug, Deserialize)]
struct ActiveSlots {
    full: Option<Vec<String>>,
    gpu: Option<Vec<String>>,
    cpu: Option<Vec<String>>,
}

pub fn is_locked() -> bool {
    GPU_LOCKED.load(Ordering::Relaxed)
}

pub fn fetch_slots() -> GpuSlots {
    let url = "http://127.0.0.1:8312/v1/scheduler/capabilities";
    let resp = reqwest::blocking::get(url);
    let mut slots = GpuSlots {
        full: false,
        gpu: false,
        cpu: false,
    };
    if let Ok(r) = resp {
        if let Ok(body) = r.json::<CapabilitiesResponse>() {
            if let Some(a) = body.active_slots {
                slots.full = a.full.map(|v| !v.is_empty()).unwrap_or(false);
                slots.gpu = a.gpu.map(|v| !v.is_empty()).unwrap_or(false);
                slots.cpu = a.cpu.map(|v| !v.is_empty()).unwrap_or(false);
            }
        }
    }
    slots
}

pub fn spawn_poller(app: AppHandle) {
    std::thread::spawn(move || {
        loop {
            let slots = fetch_slots();
            let locked = slots.full || slots.gpu;
            let prev = GPU_LOCKED.swap(locked, Ordering::Relaxed);
            if prev != locked {
                let _ = app.emit("gpu_locked", locked);
            }
            std::thread::sleep(std::time::Duration::from_secs(2));
        }
    });
}
