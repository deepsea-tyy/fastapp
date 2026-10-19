pub fn dev_pkg_platform() -> &'static str {
    #[cfg(all(target_os = "macos", target_arch = "aarch64"))]
    {
        return "macArm";
    }
    #[cfg(all(target_os = "macos", target_arch = "x86_64"))]
    {
        return "macIntel";
    }
    #[cfg(target_os = "windows")]
    {
        return "win";
    }
    #[cfg(not(any(target_os = "macos", target_os = "windows")))]
    {
        compile_error!("desktop dev only supports macOS and Windows hosts");
    }
}
