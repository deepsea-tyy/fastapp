pub mod hyperf;

use std::sync::atomic::{AtomicBool, Ordering};

use crate::paths::AppPaths;

static STOPPING: AtomicBool = AtomicBool::new(false);

pub fn start_all(paths: &AppPaths) -> Result<(), String> {
    let db = paths.storage_dir().join("fastapp.sqlite");
    if !db.is_file() {
        return Err(format!(
            "数据库未初始化: {}\n请删除 AppData 后重试，或重新安装。",
            db.display()
        ));
    }
    // 启动管线第 2 步：ensure free → start → wait 8501（navigate 在 commands::start_services）
    hyperf::start(paths)?;
    hyperf::wait_ready(paths, 60)?;
    Ok(())
}

pub fn stop_all(paths: &AppPaths) {
    if STOPPING.swap(true, Ordering::SeqCst) {
        return;
    }
    hyperf::stop(paths);
    STOPPING.store(false, Ordering::SeqCst);
}
