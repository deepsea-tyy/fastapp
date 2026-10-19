use std::fs;
use std::process::Command;

use crate::paths::AppPaths;

pub fn make_cmd_executable(paths: &AppPaths) {
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        for bin in [
            paths.fastapp_binary(),
            paths.ffmpeg_binary(),
            paths.cmd.join("ffprobe"),
        ] {
            if bin.is_file() {
                if let Ok(meta) = fs::metadata(&bin) {
                    let mut perm = meta.permissions();
                    perm.set_mode(0o755);
                    let _ = fs::set_permissions(&bin, perm);
                }
                #[cfg(target_os = "macos")]
                {
                    let _ = Command::new("xattr")
                        .args(["-d", "com.apple.quarantine"])
                        .arg(&bin)
                        .status();
                }
            }
        }
    }
}
