use std::env;
use std::fs;
use std::path::PathBuf;

fn main() {
    let manifest_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"));
    let brand_path = manifest_dir.join("../brand.json");
    println!("cargo:rerun-if-changed={}", brand_path.display());

    let brand_raw = fs::read_to_string(&brand_path)
        .unwrap_or_else(|e| panic!("读取 brand.json 失败 (先运行 sync-brand 或 stage): {e}"));
    let brand: serde_json::Value = serde_json::from_str(&brand_raw)
        .unwrap_or_else(|e| panic!("解析 brand.json 失败: {e}"));

    let data_dir = brand["dataDir"]
        .as_str()
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| panic!("brand.json 缺少 dataDir"));

    println!("cargo:rustc-env=APP_DATA_DIR={data_dir}");

    tauri_build::build()
}
