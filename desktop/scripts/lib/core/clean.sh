# 分层 clean：按职责拆分，避免重建 admin 时误删 stage 产物。

desktop_clean_admin_dist() {
  echo "==> clean admin dist: $DESKTOP_ADMIN_DIST"
  rm -rf "$DESKTOP_ADMIN_DIST"
}

desktop_clean_stage_dir() {
  echo "==> clean stage dir: $DESKTOP_BUILD_DIR"
  rm -rf "$DESKTOP_BUILD_DIR"
}

desktop_clean_legacy_bundle() {
  local legacy_bundle="$DESKTOP_ROOT/bundle"
  if [ -d "$legacy_bundle" ]; then
    echo "==> clean legacy bundle: $legacy_bundle"
    rm -rf "$legacy_bundle"
  fi
}

desktop_clean_build_root() {
  local build_root="$DESKTOP_ROOT/build"
  echo "==> clean build root: $build_root"
  rm -rf "$build_root"
}

desktop_clean_tauri_target() {
  local rust_target_root="$DESKTOP_ROOT/src-tauri/target"
  echo "==> clean rust target: $rust_target_root"
  rm -rf "$rust_target_root"
}

desktop_clean_all() {
  desktop_clean_admin_dist
  desktop_clean_legacy_bundle
  desktop_clean_build_root
  desktop_clean_tauri_target
}
