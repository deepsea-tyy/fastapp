pub mod hyperf;
pub mod tools;

use crate::paths::AppPaths;

pub fn start_all(paths: &AppPaths) -> Result<(), String> {
    hyperf::start(paths)?;
    hyperf::wait_ready(60)?;
    hyperf::migrate_if_needed(paths)?;
    if paths.tools.join("main.py").is_file() {
        tools::uv_sync(paths)?;
        tools::start_scheduler(paths)?;
        tools::wait_ready(30)?;
    }
    Ok(())
}

pub fn stop_all(paths: &AppPaths) {
    tools::stop_scheduler(paths);
    hyperf::stop(paths);
}
