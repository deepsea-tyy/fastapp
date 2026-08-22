pub mod hyperf;
pub mod tools;

use crate::paths::AppPaths;

pub fn start_all(paths: &AppPaths) -> Result<(), String> {
    hyperf::migrate_if_needed(paths)?;
    hyperf::start(paths)?;
    hyperf::wait_ready(60)?;
    Ok(())
}

pub fn stop_all(paths: &AppPaths) {
    hyperf::stop(paths);
}
