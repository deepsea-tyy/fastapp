# admin dist 构建 + rsync → build/<platform>/ui/

desktop_stage_ui() {
  local admin_built=0

  desktop_sync_fonts || return 1

  if desktop_should_build "$DESKTOP_ADMIN_DIST/index.html"; then
    echo "    sync plugin web → admin"
    (cd "$REPO_ROOT/server" && php bin/hyperf.php plugin:sync-admin -a) || return 1

    desktop_load_branding_env || return 1
    desktop_clean_admin_dist
    admin_built=1
    desktop_sync_admin_branding || return 1
    # console：DESKTOP_STAGE_PROFILE=dev 保留，否则剥离（见 admin/vite.config.ts）
    echo "    build admin dist (profile=$DESKTOP_STAGE_PROFILE; VITE_APP_ROOT_BASE=/; VITE_APP_TITLE=$PRODUCT_NAME)"
    (
      cd "$REPO_ROOT/admin" &&
        VITE_APP_ROOT_BASE=/ \
          VITE_APP_TITLE="$PRODUCT_NAME" \
          VITE_APP_LOGO=/logo.png \
          pnpm build
    ) || return 1
  else
    echo "    skip admin build (profile=$DESKTOP_STAGE_PROFILE; DESKTOP_FORCE=1 to rebuild)"
  fi

  if [ ! -d "$DESKTOP_ADMIN_DIST" ]; then
    echo "admin/dist 不存在" >&2
    return 1
  fi

  if desktop_should_sync_ui "$admin_built"; then
    mkdir -p "$DESKTOP_UI_DIR"
    rsync -a --delete "$DESKTOP_ADMIN_DIST/" "$DESKTOP_UI_DIR/"
  else
    echo "    skip ui sync (profile=dev; ui present)"
  fi
}
